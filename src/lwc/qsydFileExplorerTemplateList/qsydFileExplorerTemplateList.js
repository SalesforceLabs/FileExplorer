/**
     Author:         Paul Lucas
     Company:        Salesforce
     Description:    qsydFileExplorerTemplateList
     Date:           01-Aug-2020
    
     TODO:

 */

import {LightningElement, track, api, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import CLIENT_FORM_FACTOR from '@salesforce/client/formFactor';
import {CONSTANTS, reduceErrors, showToast} from 'c/qsydFileExplorerCommon';
import getTemplates
	from '@salesforce/apex/qsydFileExplorerController.getTemplates';

import TEMPLATE_NAME_FIELD
	from '@salesforce/schema/FileExplorerFolderTemplate__c.Name';
import TEMPLATE_LABEL_FIELD
	from '@salesforce/schema/FileExplorerFolderTemplate__c.Label__c';
import TEMPLATE_DESCRIPTION_FIELD
	from '@salesforce/schema/FileExplorerFolderTemplate__c.Description__c';
import TEMPLATE_LAST_MODIFIED_DATE_FIELD
	from '@salesforce/schema/FileExplorerFolderTemplate__c.LastModifiedDate';

const ACTIONS = [
	{
		label: CONSTANTS.ACTION_LABELS.EDIT_TEMPLATE,
		name: 'edit',
	},
];

const COLUMNS = [
	{
		label: CONSTANTS.ACTION_LABELS.TEMPLATE_NAME_HEADER,
		fieldName: TEMPLATE_NAME_FIELD.fieldApiName,
		type: 'text',
		sortable: true,
		sortedBy: TEMPLATE_NAME_FIELD.fieldApiName,
		initialWidth: 140,
	},
	{
		label: CONSTANTS.ACTION_LABELS.TEMPLATE_LABEL_HEADER,
		fieldName: TEMPLATE_LABEL_FIELD.fieldApiName,
		type: 'text',
		sortable: true,
		sortedBy: TEMPLATE_LABEL_FIELD.fieldApiName,
		initialWidth: 280,
	},
	{
		label: CONSTANTS.ACTION_LABELS.TEMPLATE_DESCRIPTION_HEADER,
		fieldName: TEMPLATE_DESCRIPTION_FIELD.fieldApiName,
		type: 'text',
		sortable: false,
		sortedBy: TEMPLATE_DESCRIPTION_FIELD.fieldApiName,
	},
	{
		label: CONSTANTS.ACTION_LABELS.TEMPLATE_MODIFIED_DATE_HEADER,
		fieldName: TEMPLATE_LAST_MODIFIED_DATE_FIELD.fieldApiName,
		type: 'date',
		sortable: true,
		sortedBy: TEMPLATE_LAST_MODIFIED_DATE_FIELD.fieldApiName,
		initialWidth: 200,
		typeAttributes: {
			year: 'numeric',
			month: 'short',
			day: '2-digit',
			hour: '2-digit',
			minute: '2-digit',
		},
	},
	{
		type: 'action',
		typeAttributes: {
			rowActions: ACTIONS,
			menuAlignment: 'right',
		},
	},
];

const PAGINATED_FOLDER_TEMPLATES = {
	records: [null],
	pageOffset: 0,
	filter: '',
};

const TABLE_HEIGHT = '290px';
const PAGE_SIZE = 20;
const LOADING_TIMEOUT = 250;
const DEBOUNCE_TIMEOUT = 400;

export default class QSydFileExplorerTemplateList extends NavigationMixin(
	LightningElement) {
	/**
	 * Internal properties
	 */
	@track _templateData = PAGINATED_FOLDER_TEMPLATES;
	_error;
	_queryTimeout = null;
	_isLoading;
	_pageOffset = 0;
	_filter = '';
	_sortBy = TEMPLATE_LABEL_FIELD.fieldApiName;

	/**
	 * Private properties
	 */
	CONSTANTS = CONSTANTS;
	columns = COLUMNS;
	records = [];

	get hostStyle() {
		return this.template.host.style;
	}

	get error() {
		return this._error;
	}

	set error(value) {
		this._error = value;

		if (this._error) {
			showToast(
				this,
				CONSTANTS.TOAST_MESSAGE_TYPES.ERROR,
				reduceErrors(this._error).join(', '),
				'',
				CONSTANTS.TOAST_THEMES.ERROR,
				CONSTANTS.TOAST_MODE.STICKY);
		}
	}

	get isLoading() {
		return this._isLoading;
	}

	set isLoading(value) {
		this._isLoading = value;

		if (this.tableData) {
			this.tableData.isLoading = value;
		}

		if (this.searchInput) {
			this.searchInput.disabled = value;
		}
	}

	get queryTimeout() {
		return this._queryTimeout;
	}

	set queryTimeout(value) {
		this._queryTimeout = value;
	}

	get searchInput() {
		return this.template.querySelector('lightning-input.search');
	}

	get recordsExist() {
		return (this._templateData.records.length > 0);
	}

	get showTable() {
		return (this.recordsExist && !this.error);
	}

	get showMessage() {
		return (!this.recordsExist && !this.error);
	}

	/**
	 * Public properties
	 */
	@api recordId;
	@api objectApiName;
	@api selectedTemplate;
	@api tableHeight;

	@api
	get templateData() {
		return this._templateData;
	}

	set templateData(value) {
		this._templateData = (value)
			? JSON.parse(value)
			: PAGINATED_FOLDER_TEMPLATES;

		this.records = this.records.concat(this._templateData.records);
		this._pageOffset = this._templateData.pageOffset;
	}

	@api
	get tableData() {
		return this.template.querySelector('lightning-datatable.table');
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
		this.hostStyle.setProperty('--table-height', this.getTableHeight());

		this.initialise().
			catch(error => {
				console.log('>>>>> Error in connectedCallback: ' + error);
				this.error = error;
			});
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

	// render(){}

	/**
	 * renderedCallback: Called after every render of the component. This lifecycle hook is specific to
	 * Lightning Web Components, it isn’t from the HTML custom elements specification. This hook flows from child to parent.
	 */
	renderedCallback() {
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
	}

	getTableHeight() {
		return this.tableHeight
			? this.tableHeight
			: TABLE_HEIGHT;
	}

	resetSearch() {
		this.error = null;
		this._pageOffset = 0;
		this.records.length = 0;
	}

	/**
	 *
	 * @returns {Promise<void>}
	 */
	async initialise() {
		try {
			this.resetSearch();
			await this.getNextPage();
		} catch (error) {
			this.error = error;
			console.error('>>>>> Error in initialise: ');
			console.error(error);
		} finally { }
	}

	async getNextPage() {
		try {
			this.loading();
			this.templateData = await getTemplates({
				filter: this._filter,
				sortBy: this._sortBy,
				pageSize: PAGE_SIZE,
				pageOffset: this._pageOffset,
			});
		} catch (error) {
			this.error = error;
			console.error('>>>>> Error in getNextPage: ');
			console.error(error);
		} finally {
			window.setTimeout(this.loaded.bind(this), LOADING_TIMEOUT);
		}
	}

	handleLoadMore(e) {
		if (this._pageOffset != -1) {
			this.getNextPage().catch();
		}
	}

	loading() {
		this.isLoading = true;
	}

	loaded() {
		this.isLoading = false;
		window.setTimeout(this.handleSearchInputFocus.bind(this),
			LOADING_TIMEOUT);
	}

	handleSearchInputFocus() {
		this.searchInput.focus();
	}

	handleColumnSort(e) {
		let fieldName = e.detail.fieldName;
		let sortDirection = e.detail.sortDirection;

		if (!this.isLoading) {
			this.tableData.sortedBy = fieldName;
			this.tableData.sortedDirection = sortDirection;
			this._sortBy = `${fieldName} ${sortDirection}`;
			this.resetSearch();
			this.handleLoadMore();
		}
	}

	handleAddTemplateClick() {
		this[NavigationMixin.Navigate]({
			type: this.CONSTANTS.NAVIGATION_TYPES.OBJECT_PAGE,
			attributes: {
				objectApiName: this.CONSTANTS.FILE_EXPLORER_OBJECT_API_NAMES.FOLDER_TEMPLATE,
				actionName: this.CONSTANTS.NAVIGATION_ACTIONS.LIST,
			},
		});
	}

	handleSearchKeyUp(e) {
		if (e.keyCode === this.CONSTANTS.KEY_CODES.ENTER) {
			this.handleSearchChange(e);
		}
	}

	handleSearchChange(e) {
		let query = e.target.value ? e.target.value.trim() : '';

		if (this.queryTimeout) {
			window.clearTimeout(this.queryTimeout);
		}

		if (this._filter !== query) {
			this._filter = query;
			this.resetSearch();
			this.queryTimeout = window.setTimeout(
				this.handleLoadMore.bind(this), DEBOUNCE_TIMEOUT);
		}
	}

	handleRowAction(e) {
		const action = e.detail.action;
		const row = e.detail.row;

		switch (action.name) {
			case 'edit':
				this[NavigationMixin.Navigate]({
					type: this.CONSTANTS.NAVIGATION_TYPES.RECORD_PAGE,
					attributes: {
						recordId: row.Id,
						actionName: this.CONSTANTS.NAVIGATION_ACTIONS.VIEW,
					},
				});
				break;
		}
	}
}