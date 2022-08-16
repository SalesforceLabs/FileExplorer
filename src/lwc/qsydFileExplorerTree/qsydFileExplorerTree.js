/**
 Author:         Paul Lucas
 Company:        Salesforce
 Description:    qsydFileExplorerTree
 Date:           19-Apr-2020

 TODO:

 */

import {LightningElement, api, wire} from 'lwc';
import {CONSTANTS, item} from 'c/qsydFileExplorerCommon';
import {loadScript, loadStyle} from 'lightning/platformResourceLoader';
import jquery from '@salesforce/resourceUrl/jquery_350';
import jstree from '@salesforce/resourceUrl/jstree_339';
import jstree339 from '@salesforce/resourceUrl/jstree339';
// import jstree339 from '@salesforce/resourceUrl/jstree_339_min';

export default class QSydFileExplorerTree extends LightningElement {
	/**
	 * Enumerations
	 */
	JSTREE_ACTIONS = {
		'SELECT_NODE': 'select_node',
		'SELECT_HOME': 'select_home',
		'DESELECT_ALL': 'deselect_all',
	};

	/**
	 * Internal properties
	 */
	_error;
	_resourcesLoaded = false;
	_tree;
	_$tree;
	_$treeInstance;
	_selectedItem;

	/**
	 * Private properties
	 */
	CONSTANTS = CONSTANTS;
	isLoading = true;
	files;
	folders;
	dataDictionary;
	dataTree;

	content = 'The modal content';
	header = 'The modal header';

	/**
	 * Public properties
	 */
	@api recordId;
	@api objectApiName;

	@api
	get selectedItem() {
		return this._selectedItem;
	}

	set selectedItem(value) {
		let selectedItems;
		this._selectedItem = value;

		if (this.treeReady()) {
			selectedItems = this._$treeInstance.get_selected(false);
			if (!selectedItems.includes(value.id)) {
				this._$treeInstance.refresh(true, true);
				this._$treeInstance.deselect_node(selectedItems, true);
				this._$treeInstance.select_node(value.id);
			}
		}
	}

	@api
	get dictionaryData() {
		return this.dataDictionary;
	}

	set dictionaryData(value) {
		this.dataDictionary = value;

		if (value) {
			this.files = [...value.files];
			this.folders = [...value.folders];
		}
	}

	@api
	get treeData() {
		return JSON.stringify(this.dataTree);
	}

	set treeData(value) {
		this.dataTree = value;

		if (this.treeReady()) {
			this._$treeInstance.settings.core.data = value;
			this._$treeInstance.refresh(); //.redraw(true);
		}
	}

	get haveResourcesLoaded() {
		if (this._resourcesLoaded) {
			return true;
		}

		this._resourcesLoaded = true;
		return false;
	}

	/**
	 * constructor: Called when the component is created. This hook flows from parent to child. You can’t access child
	 * elements in the component body because they don’t exist yet. Properties are not passed yet, either. Properties
	 * are assigned to the component after construction and before the connectedCallback() hook.
	 * You can access the host element with this.template.
	 */
	constructor() {
		super();
	}

	/**
	 * connectedCallBack: Called when the element is inserted into a document. This hook flows from parent to child.
	 * You can’t access child elements in the component body because they don’t exist yet.
	 * You can access the host element with this.template.
	 */
	connectedCallback() {
	}

	/**
	 * disconnectedCallback: Called when the element is removed from a document. This hook flows from parent to child.
	 */
	disconnectedCallback() {
	}

	/**
	 * render: For complex tasks like conditionally rendering a template or importing a custom one, use render()
	 * to override standard rendering functionality. This function gets invoked after connectedCallback() and must
	 * return a valid HTML template.
	 */

	// render(){
	// console.log('>>>>> disconnectedCallback');
	// }

	/**
	 * renderedCallback: Called after every render of the component. This lifecycle hook is specific to
	 * Lightning Web Components, it isn’t from the HTML custom elements specification. This hook flows from child to parent.
	 */
	renderedCallback() {

		if (this.haveResourcesLoaded) {
			return;
		}

		Promise.all([
			loadScript(this, jquery),
			loadScript(this, jstree339),
			loadStyle(this, jstree + '/themes/default/style.css'),
		]).then(() => {
			this.initialiseTree();
		}).catch(error => {
			console.log(error);
		});
	}

	/**
	 * errorCallback: Called when a descendant component throws an error in one of its lifecycle hooks.
	 * The error argument is a JavaScript native error object, and the stack argument is a string.
	 * This lifecycle hook is specific to Lightning Web Components, it isn’t from the HTML custom elements specification.
	 *
	 * @param error
	 * @param stack
	 */
	errorCallback(error, stack) {

		// TODO: Handle errors, check message...
		console.log('>>>>> errorCallback');
		console.log(error);
		console.log(stack);

		throw error;
	}

	treeReady() {
		return (this._$tree && this._$treeInstance);
	}

	addTreeListeners() {
		this._$tree.on('ready.jstree', this.handleTreeReady.bind(this));
		this._$tree.on('refresh.jstree', this.handleTreeReady.bind(this));
		this._$tree.on('changed.jstree', this.handleTreeChange.bind(this));
	}

	initialiseTree() {
		this._tree = this.template.querySelector('div.jstree');
		this._$tree = $(this._tree);
		this.bindTree(this.dataTree);
	}

	bindTree(data) {
		if (data) {
			this.addTreeListeners();
			this._$tree.jstree({
				'core': {
					'data': data,
					'check_callback': true,
					'themes': {
						'responsive': false,
						'variant': 'large',
						'stripes': false,
					},
				},
				'plugins': ['sort_ascending_folders_first'],
				'sort_ascending_folders_first': function(a, b) {
					let nodeA = this.get_node(a, false);
					let nodeB = this.get_node(b, false);

					if (!(nodeA.documentId)) {
						return 1;
					} else {
						return (nodeA.text.toLowerCase() >
							nodeB.text.toLowerCase()) ? 1 : -1;
					}
				},

				// 'lwc_host': this.template.host,
				'lwc_host': this._tree,
			});
		} else {
			window.setTimeout((data) => {
				this.bindTree(data);
			}, 1000, this.dataTree);
		}
	}

	handleTreeReady(e, data) {
		this._$treeInstance = this._$tree.jstree(true);
		this.isLoading = false;

		this.dispatchEvent(
			new CustomEvent(CONSTANTS.CUSTOM_DOM_EVENT_TYPES.EXPLORER_LOADED, {bubbles: true, composed: true}),
		);
	}

	handleTreeChange(e, data) {
		this._selectedItem = (data.node && data.node.original)
			? data.node.original
			: {};
		this.template.querySelector('div.tree-home').
			classList.
			remove('item-selected');

		this.propagateEvent(data.action);
	}

	propagateEvent(action) {
		let eventType,
			payload;

		switch (action) {
			case this.JSTREE_ACTIONS.SELECT_HOME:
				eventType = CONSTANTS.CUSTOM_DOM_EVENT_TYPES.ITEM_CLICK;
				payload = new item({id: 'root'});
				break;
			case this.JSTREE_ACTIONS.SELECT_NODE:
				eventType = CONSTANTS.CUSTOM_DOM_EVENT_TYPES.ITEM_CLICK;
				payload = this.selectedItem;
				break;
			case this.JSTREE_ACTIONS.DESELECT_ALL:
				eventType = null;
				payload = {};
				break;

			default:
				break;
		}

		// TODO: Event dispatch queue
		if (eventType) {
			this.dispatchEvent(
				new CustomEvent(eventType, {
					detail: payload,
				}),
			);
		}
	}

	handleExpandClick() {
		this._$treeInstance.open_all(null, 0, $);
	}

	handleCollapseClick() {
		this._$treeInstance.close_all(null, 0);
	}

	handleRefreshClick() {
		this.dispatchEvent(
			new CustomEvent(CONSTANTS.CUSTOM_DOM_EVENT_TYPES.ITEM_ACTION, {
				detail: CONSTANTS.ACTION_TYPES.REFRESH,
			}),
		);
	}

	handleHomeClick(e) {
		this._$treeInstance.deselect_all(true);
		e.currentTarget.classList.add('item-selected');
		this.propagateEvent(this.JSTREE_ACTIONS.SELECT_HOME);
	}
}