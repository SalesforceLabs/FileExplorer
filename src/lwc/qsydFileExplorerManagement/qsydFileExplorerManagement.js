/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**
     Author:         Paul Lucas
     Company:        Salesforce
     Description:    qsydFileExplorerManagement
     Date:           01-May-2020
    
     TODO:

 */

import {LightningElement, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {loadScript, loadStyle} from 'lightning/platformResourceLoader';
import jquery from '@salesforce/resourceUrl/jquery_350';
import jstree from '@salesforce/resourceUrl/jstree_339';
import jstree339 from '@salesforce/resourceUrl/jstree339';
import {
	CONSTANTS,
	item,
	listToTree,
	clone, dictionaryToList,
	reduceErrors,
} from 'c/qsydFileExplorerCommon';
import setFolder from '@salesforce/apex/qsydFileExplorerController.setFolder';
import save
	from '@salesforce/apex/qsydFileExplorerController.postItem';
import remove
	from '@salesforce/apex/qsydFileExplorerController.deleteItem';

const CSS_CLASS = 'modal-hidden';

export default class QSydFileExplorerManagement extends LightningElement {
	/**
	 * Internal properties
	 */
	_error;
	_resourcesLoaded = false;
	_tree;
	_$tree;
	_$treeInstance;
	_selectedItem;
	_targetItem;
	_action;

	/**
	 * Private properties
	 */
	isLoading = true;
	files;
	folders;
	dataDictionary;
	dataTree;
	uploadedFiles;
	hasHeaderString = false;

	get selectedItemLabel() {
		return this._selectedItem.text;
	}

	get moveItem() {
		return (this._action === CONSTANTS.ACTION_TYPES.MOVE_FILE ||
			this._action === CONSTANTS.ACTION_TYPES.MOVE_FOLDER);
	}

	get addFile() {
		return this._action === CONSTANTS.ACTION_TYPES.ADD_FILE;
	}

	get addFolder() {
		return this._action === CONSTANTS.ACTION_TYPES.ADD_FOLDER;
	}

	get renameFolder() {
		return this._action === CONSTANTS.ACTION_TYPES.RENAME_FOLDER;
	}

	get deleteFolder() {
		return this._action === CONSTANTS.ACTION_TYPES.DELETE_FOLDER;
	}

	/**
	 * Public properties
	 */
	@api recordId;
	@api objectApiName;
	@api folderId;
	@api showModal = false;

	@api
	get dictionaryData() {
		return this.dataDictionary;
	}

	set dictionaryData(value) {
		this.dataDictionary = clone(value);

		if (value) {
			this.files = this.dataDictionary.files;
			this.folders = this.dataDictionary.folders;
			this.dataTree = listToTree(this.folders);
		}
	}

	@api
	get selectedItem() {
		return this._selectedItem;
	}

	set selectedItem(value) {
		this._selectedItem = new item(value);
	}

	@api
	get targetItem() {
		return this._targetItem;
	}

	set targetItem(value) {
		this._targetItem = new item(value);
	}

	@api
	get header() {
		return this._header;
	}

	set header(value) {
		this.hasHeaderString = value !== '';
		this._header = value;
	}

	get addFileHeading() {
		if (this._selectedItem.isRoot()) {
			return 'Add files to Home folder:';
		}
		return 'Add files to folder "' + this._selectedItem.text + '":';
	}

	@api
	show(action) {
		this._action = action;
		this.showModal = true;
	}

	@api
	hide() {
		this.showModal = false;
		this._resourcesLoaded = false;
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
	// }

	/**
	 * renderedCallback: Called after every render of the component. This lifecycle hook is specific to
	 * Lightning Web Components, it isn’t from the HTML custom elements specification. This hook flows from child to parent.
	 */
	renderedCallback() {
		if (this.showModal) {
			if (this._resourcesLoaded) {
				return true;
			}
			this._resourcesLoaded = true;

			Promise.all([
				loadScript(this, jquery),
				// loadScript(this, jstree + '/jstree.3.3.9.js'),
				loadScript(this, jstree339),
				loadStyle(this, jstree + '/themes/default/style.css'),
			]).then(() => {
				this.initialiseTree();
			}).catch(error => {
				console.log('>>>>> Error initialising tree');
				console.log(error);
			});
		}
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
				'plugins': ['sort'],
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

		// Expand
		this._$treeInstance.open_all(null, 0, $);
	}

	handleTreeChange(e, data) {
		this.targetItem = data.node.original;
		this.targetItem.parents = data.node.parents;

		this.template.querySelector('div.tree-home').
			classList.
			remove('item-selected');
	}

	handleHomeClick(e) {
		this.targetItem = new item({parents: []});
		this._$treeInstance.deselect_all(true);
		e.currentTarget.classList.add('item-selected');
	}

	handleUploadFinished(e) {
		this.uploadedFiles = e.detail.files;
		let folderId = (this.folderId == 'root' ? null : this.folderId);
		const documentIds = this.uploadedFiles.map(file => file.documentId);
		const numDocuments = documentIds.length;
		const message = numDocuments + ' File' + (numDocuments > 1 ? 's' : '') +
			' Successfully Added!';

		setFolder({contentDocumentIds: documentIds, folderId: folderId}).
			then(result => {
				this.showToast(
					CONSTANTS.TOAST_MESSAGE_TYPES.SUCCESS,
					message,
					'',
					CONSTANTS.TOAST_THEMES.SUCCESS,
					CONSTANTS.TOAST_MODE.DISMISSABLE);

				this.handleDialogClose({
					action: this._action,
				});
			}).
			catch(error => {
				this.showToast(
					CONSTANTS.TOAST_MESSAGE_TYPES.ERROR,
					reduceErrors(error).join(', '),
					'',
					CONSTANTS.TOAST_THEMES.ERROR,
					CONSTANTS.TOAST_MODE.DISMISSABLE);
			});
	}

	handleDialogClose(data) {
		this.dispatchEvent(
			new CustomEvent(
				CONSTANTS.CUSTOM_DOM_EVENT_TYPES.EXPLORER_MANAGEMENT_CLOSE, {
					detail: data,
				}),
		);

		this.hide();
	}

	showToast(title, message, messageData, variant, mode) {
		this.dispatchEvent(new ShowToastEvent({
			'title': title.charAt(0).toUpperCase() +
				title.substr(1).toLowerCase(),
			'message': message,
			'messageData': messageData,
			'variant': variant,
			'mode': mode,
		}));
	}

	handleSlotTaglineChange() {
		const tagline = this.template.querySelector('p');

		if (tagline) {
			tagline.classList.remove(CSS_CLASS);
		}
	}

	handleCancelClick(e) {
		this.hide();
	}

	handleAcceptClick(e) {
		let deltaItem,
			selector = CONSTANTS.SELECTORS.CLASS_SPECIFIER + this._action,
			element = this.template.querySelector(selector);

		// Avoid multiple submissions
		e.target.disabled = true;

		switch (this._action) {
			case CONSTANTS.ACTION_TYPES.ADD_FILE:
				break;
			case CONSTANTS.ACTION_TYPES.MOVE_FILE:
				if (this.targetItem) {
					if (this.targetItem.id === this.selectedItem.folder) {
						this.showToast(
							CONSTANTS.TOAST_MESSAGE_TYPES.WARNING,
							CONSTANTS.ACTION_ERROR_MESSAGES.MOVE_FILE_SAME_SOURCE_AND_TARGET,
							'',
							CONSTANTS.TOAST_THEMES.WARNING,
							CONSTANTS.TOAST_MODE.DISMISSABLE);
						e.target.disabled = false;
						break;
					}

					deltaItem = Object.assign({}, this.selectedItem);
					deltaItem.folder = this.targetItem.id;
					this.saveItem(deltaItem);
				}
				break;

			case CONSTANTS.ACTION_TYPES.ADD_FOLDER:
				if (element.reportValidity()) {
					deltaItem = new item({});
					deltaItem.entityId = this.recordId;
					deltaItem.text = element.value;
					deltaItem.folder = this.selectedItem.isRoot()
						? null
						: this.selectedItem.id;
					this.saveItem(deltaItem);
				} else {
					e.target.disabled = false;
				}
				break;

			case CONSTANTS.ACTION_TYPES.MOVE_FOLDER:

				if (this.targetItem) {
					if (this.targetItem.parents.includes(
						this.selectedItem.id)) {
						this.showToast(
							CONSTANTS.TOAST_MESSAGE_TYPES.WARNING,
							CONSTANTS.ACTION_ERROR_MESSAGES.MOVE_FOLDER_DESCENDANT,
							'',
							CONSTANTS.TOAST_THEMES.WARNING,
							CONSTANTS.TOAST_MODE.DISMISSABLE);
						e.target.disabled = false;
						break;
					}

					if (this.targetItem.id === this.selectedItem.id) {
						this.showToast(
							CONSTANTS.TOAST_MESSAGE_TYPES.WARNING,
							CONSTANTS.ACTION_ERROR_MESSAGES.MOVE_FOLDER_CIRCULAR_DEPENDENCY,
							'',
							CONSTANTS.TOAST_THEMES.WARNING,
							CONSTANTS.TOAST_MODE.DISMISSABLE);
						e.target.disabled = false;
						break;
					}

					if (this.targetItem.id === this.selectedItem.folder) {
						this.showToast(
							CONSTANTS.TOAST_MESSAGE_TYPES.WARNING,
							CONSTANTS.ACTION_ERROR_MESSAGES.MOVE_FOLDER_SAME_SOURCE_AND_TARGET,
							'',
							CONSTANTS.TOAST_THEMES.WARNING,
							CONSTANTS.TOAST_MODE.DISMISSABLE);
						e.target.disabled = false;
						break;
					}

					deltaItem = Object.assign({}, this.selectedItem);
					deltaItem.folder = this.targetItem.id;
					this.saveItem(deltaItem);
				}
				break;

			case CONSTANTS.ACTION_TYPES.RENAME_FOLDER:
				if (element.reportValidity()) {
					deltaItem = Object.assign({}, this.selectedItem);
					deltaItem.text = element.value;
					this.saveItem(deltaItem);
				} else {
					e.target.disabled = false;
				}
				break;

			case CONSTANTS.ACTION_TYPES.DELETE_FOLDER:
				deltaItem = Object.assign({}, this.selectedItem);
				this.removeItem(deltaItem);
				break;

			default:
				break;
		}
	}

	saveItem(deltaItem, e) {
		save(
			{
				serializedItem: JSON.stringify(deltaItem),
			}).
			then((result) => {
				this.showToast(
					CONSTANTS.TOAST_MESSAGE_TYPES.SUCCESS,
					CONSTANTS.ACTION_SUCCESS_MESSAGES[this._action.toUpperCase()],
					'',
					CONSTANTS.TOAST_THEMES.SUCCESS,
					CONSTANTS.TOAST_MODE.DISMISSABLE);

				this.handleDialogClose({
					action: this._action,
					// item: this.selectedItem
					item: {id: JSON.parse(result).id},
				});
			}).
			catch(error => {
				this._error = error;
				this.showToast(
					CONSTANTS.TOAST_MESSAGE_TYPES.ERROR,
					reduceErrors(error).join(', '),
					'',
					CONSTANTS.TOAST_THEMES.ERROR,
					CONSTANTS.TOAST_MODE.DISMISSABLE);

				this.handleDialogClose({
					action: this._action,
					item: {},
				});
			});
	}

	removeItem(deltaItem) {
		remove(
			{
				serializedItem: JSON.stringify(deltaItem),
			}).
			then(result => {

				this.showToast(
					CONSTANTS.TOAST_MESSAGE_TYPES.SUCCESS,
					CONSTANTS.ACTION_SUCCESS_MESSAGES[this._action.toUpperCase()],
					'',
					CONSTANTS.TOAST_THEMES.SUCCESS,
					CONSTANTS.TOAST_MODE.DISMISSABLE);

				this.handleDialogClose({
					action: this._action,
					item: {id: this.selectedItem.folder}, // New selected item should be the parent folder
				});
			}).
			catch(error => {
				this._error = error;

				this.showToast(
					CONSTANTS.TOAST_MESSAGE_TYPES.ERROR,
					reduceErrors(error).join(', '),
					'',
					CONSTANTS.TOAST_THEMES.ERROR,
					CONSTANTS.TOAST_MODE.DISMISSABLE);

				this.handleDialogClose({
					action: this._action,
					item: {},
				});
			});
	}
}