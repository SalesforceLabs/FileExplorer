/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
import {LightningElement, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {
	CONSTANTS,
	item,
} from 'c/qsydFileExplorerCommon';

export default class QsydFileExplorerActions extends LightningElement {
	/**
	 * Constants
	 */
	ACTION_ITEMS = {
		'File': [
			{
				id: CONSTANTS.ACTION_TYPES.ADD_FILE,
				label: CONSTANTS.ACTION_LABELS.ADD_FILE,
				value: CONSTANTS.ACTION_TYPES.ADD_FILE,
				disabled: false,
				prefixIconName: 'utility:add',
				isDisabled: function(item, context) {
					return false;
				},
			},
			{
				id: CONSTANTS.ACTION_TYPES.MOVE_FILE,
				label: CONSTANTS.ACTION_LABELS.MOVE_FILE,
				value: CONSTANTS.ACTION_TYPES.MOVE_FILE,
				disabled: false,
				prefixIconName: 'utility:move',
				isDisabled: function(item, context) {
					return (!context.isFile());
				},
			},
		],
		'Folder': [
			{
				id: CONSTANTS.ACTION_TYPES.ADD_FOLDER,
				label: CONSTANTS.ACTION_LABELS.ADD_FOLDER,
				value: CONSTANTS.ACTION_TYPES.ADD_FOLDER,
				disabled: false,
				prefixIconName: 'utility:add',
				isDisabled: function(item, context) {
					return (context.isFile());
				},
			},
			{
				id: CONSTANTS.ACTION_TYPES.MOVE_FOLDER,
				label: CONSTANTS.ACTION_LABELS.MOVE_FOLDER,
				value: CONSTANTS.ACTION_TYPES.MOVE_FOLDER,
				disabled: false,
				prefixIconName: 'utility:move',
				isDisabled: function(item, context) {
					return (context.isFile() || context.isRoot());
				},
			},
			{
				id: CONSTANTS.ACTION_TYPES.RENAME_FOLDER,
				label: CONSTANTS.ACTION_LABELS.RENAME_FOLDER,
				value: CONSTANTS.ACTION_TYPES.RENAME_FOLDER,
				disabled: false,
				prefixIconName: 'utility:edit',
				isDisabled: function(item, context) {
					return (context.isFile() || context.isRoot());
				},
			},
			{
				id: CONSTANTS.ACTION_TYPES.DELETE_FOLDER,
				label: CONSTANTS.ACTION_LABELS.DELETE_FOLDER,
				value: CONSTANTS.ACTION_TYPES.DELETE_FOLDER,
				disabled: false,
				prefixIconName: 'utility:delete',
				isDisabled: function(item, context) {
					return (context.isFile() || context.isRoot());
				},
			},
		],
		'General': [
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
		const explorerManagement = this.template.querySelector(
			'c-qsyd-file-explorer-management');

		this.dispatchEvent(
			new CustomEvent(CONSTANTS.CUSTOM_DOM_EVENT_TYPES.ITEM_ACTION, {
				detail: e.detail.value,
			}),
		);
	}

	resolveMenuItems() {
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

	showToast(title, message, messageData, variant, mode) {
		this.dispatchEvent(new ShowToastEvent({
			'title': title,
			'message': message,
			'messageData': messageData,
			'variant': variant,
			'mode': mode,
		}));
	}
}