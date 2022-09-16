import {LightningElement, api} from 'lwc';
import userId from '@salesforce/user/Id';

import {
	CONSTANTS,
	item,
} from 'c/qsydFileExplorerCommon';

export default class QsydFileExplorerActions extends LightningElement {

	/**
	 * Constants
	 */
	ACTION_ITEMS = {
		[CONSTANTS.ACTION_LABELS.FILE_HEADER] : [
			{
				id: CONSTANTS.ACTION_TYPES.ADD_FILE,
				label: CONSTANTS.ACTION_LABELS.ADD_FILE,
				value: CONSTANTS.ACTION_TYPES.ADD_FILE,
				disabled: false,
				prefixIconName: 'utility:add',
				isDisabled: function(item, context) {
					return context.isTemplate();
				},
			},
			{
				id: CONSTANTS.ACTION_TYPES.MOVE_FILE,
				label: CONSTANTS.ACTION_LABELS.MOVE_FILE,
				value: CONSTANTS.ACTION_TYPES.MOVE_FILE,
				disabled: false,
				prefixIconName: 'utility:move',
				isDisabled: function(item, context) {
					return !context.isFile();
				},
			},
			{
				id: CONSTANTS.ACTION_TYPES.DELETE_FILE,
				label: CONSTANTS.ACTION_LABELS.DELETE_FILE,
				value: CONSTANTS.ACTION_TYPES.DELETE_FILE,
				disabled: false,
				prefixIconName: 'utility:delete',
				isDisabled: function(item, context) {
					return !context.isFile() || !context.canDelete(userId);
				},
			},
		],
		[CONSTANTS.ACTION_LABELS.FOLDER_HEADER]: [
			{
				id: CONSTANTS.ACTION_TYPES.ADD_FOLDER,
				label: CONSTANTS.ACTION_LABELS.ADD_FOLDER,
				value: CONSTANTS.ACTION_TYPES.ADD_FOLDER,
				disabled: false,
				prefixIconName: 'utility:add',
				isDisabled: function(item, context) {
					return context.isFile();
				},
			},
			{
				id: CONSTANTS.ACTION_TYPES.MOVE_FOLDER,
				label: CONSTANTS.ACTION_LABELS.MOVE_FOLDER,
				value: CONSTANTS.ACTION_TYPES.MOVE_FOLDER,
				disabled: false,
				prefixIconName: 'utility:move',
				isDisabled: function(item, context) {
					return context.isFile() || context.isRoot();
				},
			},
			{
				id: CONSTANTS.ACTION_TYPES.RENAME_FOLDER,
				label: CONSTANTS.ACTION_LABELS.RENAME_FOLDER,
				value: CONSTANTS.ACTION_TYPES.RENAME_FOLDER,
				disabled: false,
				prefixIconName: 'utility:edit',
				isDisabled: function(item, context) {
					return context.isFile() || context.isRoot();
				},
			},
			{
				id: CONSTANTS.ACTION_TYPES.DELETE_FOLDER,
				label: CONSTANTS.ACTION_LABELS.DELETE_FOLDER,
				value: CONSTANTS.ACTION_TYPES.DELETE_FOLDER,
				disabled: false,
				prefixIconName: 'utility:delete',
				isDisabled: function(item, context) {
					return context.isFile() || context.isRoot();
				},
			},
			{
				id: CONSTANTS.ACTION_TYPES.TEMPLATE_FOLDER,
				label: CONSTANTS.ACTION_LABELS.TEMPLATE_FOLDER,
				value: CONSTANTS.ACTION_TYPES.TEMPLATE_FOLDER,
				disabled: false,
				prefixIconName: 'utility:layers',
				isDisabled: function(item, context) {
					return context.isFile();
				},
			},
		],
		[CONSTANTS.ACTION_LABELS.GENERAL_HEADER]: [
			{
				id: CONSTANTS.ACTION_TYPES.REFRESH,
				label: CONSTANTS.ACTION_LABELS.REFRESH,
				value: CONSTANTS.ACTION_TYPES.REFRESH,
				disabled: false,
				prefixIconName: 'utility:refresh',
				isDisabled: function(item, context) {
					return false;
				},
			},
		],
	};

	/**
	 * Internal properties
	 */
	_error;
	_selectedItem;

	/**
	 * Private properties
	 */
	menuItems = [];

	/**
	 * Public properties
	 */
	@api recordId;
	@api objectApiName;
	@api folderId;

	@api
	get selectedItem() {
		return this._selectedItem;
	}

	set selectedItem(value) {
		// TODO: Refactor, type all items during init
		this._selectedItem = new item(value);
		this._selectedItem.objectApiName = this.objectApiName;
		this.resolveMenuItems();
	}

	connectedCallback() {
	}

	constructor() {
		super();
	}

	connectedCallback() {
	}

	disconnectedCallback() {
	}

	renderedCallback() {

	}

	@api
	isSelectedItemMenuActionEnabled(action) {
		let itemType = this.selectedItem.getType();

		itemType = itemType.charAt(0).toUpperCase() +
			itemType.substr(1).toLowerCase();

		if (this.menuItems) {
			return !this.menuItems.find(t => t.key === itemType).
				value.
				find(a => a.id === action).disabled;
		}

		return false;
	}

	@api
	handleMenuItemSelect(e) {
		this.dispatchEvent(
			new CustomEvent(CONSTANTS.CUSTOM_DOM_EVENT_TYPES.ITEM_ACTION, {
				detail: e.detail.value,
			}),
		);
	}

	resolveMenuItems() {

		// Expected config

		// this.menuItems = [
		// 	{
		// 		'key': 'File',
		// 		'value': [
		// 			{
		// 				'id': 'add_file',
		// 				'label': 'Add',
		// 				'value': 'add_file',
		// 				'disabled': false,
		// 				'prefixIconName': 'utility:add',
		// 			},
		// 			{
		// 				'id': 'move_file',
		// 				'label': 'Move',
		// 				'value': 'move_file',
		// 				'disabled': true,
		// 				'prefixIconName': 'utility:move',
		// 			}],
		// 	},
		// 	{
		// 		'key': 'Folder',
		// 		'value': [
		// 			{
		// 				'id': 'add_folder',
		// 				'label': 'Add',
		// 				'value': 'add_folder',
		// 				'disabled': false,
		// 				'prefixIconName': 'utility:add',
		// 			},
		// 			{
		// 				'id': 'move_folder',
		// 				'label': 'Move',
		// 				'value': 'move_folder',
		// 				'disabled': false,
		// 				'prefixIconName': 'utility:move',
		// 			},
		// 			{
		// 				'id': 'rename_folder',
		// 				'label': 'Rename',
		// 				'value': 'rename_folder',
		// 				'disabled': false,
		// 				'prefixIconName': 'utility:edit',
		// 			},
		// 			{
		// 				'id': 'delete_folder',
		// 				'label': 'Delete',
		// 				'value': 'delete_folder',
		// 				'disabled': false,
		// 				'prefixIconName': 'utility:delete',
		// 			}],
		// 	},
		// 	{
		// 		'key': 'General',
		// 		'value': [
		// 			{
		// 				'id': 'refresh',
		// 				'label': 'Refresh',
		// 				'value': 'refresh',
		// 				'disabled': false,
		// 				'prefixIconName': 'utility:refresh',
		// 			}],
		// 	}];

		if (this.selectedItem) {
			this.menuItems = Object.entries(this.ACTION_ITEMS).
				map(item => {
					return {
						key: item[0],
						value: item[1].map(
							function(item) {
								return Object.assign(item,
									{disabled: item.isDisabled(item, this)});
							}, this.selectedItem),
					};
				});
		}
	}

	handleRefreshDataClick(e) {
		const refreshButtonIcon = e.target.querySelector('.slds-button__icon');
		refreshButtonIcon.classList.toggle('refreshRotate');

		this.retrieveFileExplorerItemMap();

		// Re-animate
		window.setTimeout((refreshButtonIcon) => {
			refreshButtonIcon.classList.toggle('refreshRotate');
		}, 1000, refreshButtonIcon);
	}
}