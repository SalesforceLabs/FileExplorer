/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**
 * @File Name          : qsydFileExplorer.js
 * @Description        :
 * @Author             : Paul Lucas, Jiun Ryu, Elly Zhu, Derrick Vuong
 **/
import {LightningElement, api} from 'lwc';
import {
	CONSTANTS,
	dictionaryToList,
	listToTree,
	clone,
	item,
	showToast,
	reduceErrors,
	interpolate,
} from 'c/qsydFileExplorerCommon';
import retrieveItemMap
	from '@salesforce/apex/qsydFileExplorerController.retrieveItemMap';

/* Changes to these width should be done in qsydFileExplorer.css as well for consistency */
const treeMinWidth = '159', mainMinWidth = '285';

var dragging = false, startPos, treeContainerWidth, mainContainerWidth;

export default class QsydFileExplorerCmp extends LightningElement {

	/**
	 * Internal properties
	 */
		// _payload;
	_error;
	_action;

	/**
	 * Private properties
	 */
	results;
	typedownResults;
	shadowItem;
	item;
	dataSet;
	dataDictionary;
	dataTree;
	breadcrumbs;
	explorerManagementHeader = 'Manage File Explorer';

	get folderId() {
		if (this.item) {
			return this.item.documentId
				? this.item.folder
				: this.item.id;
		}
		return null;
	}

	get action() {
		return this._action;
	}

	set action(value) {
		this._action = value;
	}

	/**
	 * Public properties
	 */
	@api recordId;
	@api objectApiName;
	@api title;
	@api searchResultDisplayStyle = 'Console Results';

	constructor() {
		super();

		this.addEventListener('dataloaded', this.handleDataLoaded);
		// this.addEventListener('keydown', this.handleKeyDown);
	}

	connectedCallback() {
		this.retrieveFileExplorerItemMap();
	}

	renderedCallback() {
	}

	errorCallback(error, stack) {
		showToast(
			this,
			CONSTANTS.TOAST_MESSAGE_TYPES.ERROR,
			reduceErrors(error).join(', '),
			'',
			CONSTANTS.TOAST_THEMES.ERROR,
			CONSTANTS.TOAST_MODE.DISMISSABLE);
	}

	@api
	retrieveFileExplorerItemMap(e) {
		retrieveItemMap({recordId: this.recordId}).then(result => {
			this.dataDictionary = JSON.parse(result);
			this.dataSet = dictionaryToList(clone(this.dataDictionary));
			this.dataTree = listToTree(this.dataSet);
			this.results = this.findTreeItem(this.dataDictionary, 'Contents',
				null);
			this.breadcrumbs = this.buildBreadcrumbs(this.dataDictionary, null);

			this.dispatchEvent(
				new CustomEvent(CONSTANTS.CUSTOM_DOM_EVENT_TYPES.DATA_LOADED, {
					detail: this.dataDictionary,
				}),
			);
		}).catch(error => {
			this._error = error;
		});
	}

	findTreeItem(dictionary, type, folderId) {
		if (dictionary) {
			return {
				type: type,
				files: dictionary.files.filter(
					({folder}) => { return folder == folderId; }),
				folders: dictionary.folders.filter(
					({folder}) => { return folder == folderId; }),
			};
		}
		return null;
	}

	findItemInSet(item) {
		return this.dataSet.find(i => i.id === item.id);
	}

	buildBreadcrumbs(dictionary, item) {
		let breadcrumbs = [];
		if (item) {
			if (!item.documentId) {
				breadcrumbs.unshift(item);
			}
			let folderId = item.folder;
			while (folderId) {
				const folder = dictionary.folders.find(
					({id}) => id == folderId);
				if (folder) {
					breadcrumbs.unshift(folder);
					folderId = folder.folder;
				} else {
					folderId = null;
				}
			}
		}
		return breadcrumbs;
	}

	handleDataLoaded(e) {

		switch (this.action) {
			case CONSTANTS.ACTION_TYPES.ADD_FILE:
				this.results = this.findTreeItem(this.dataDictionary,
					'Contents',
					this.folderId);
				break;

			case CONSTANTS.ACTION_TYPES.UPDATE_FILE:
				this.item = this.findItemInSet(this.shadowItem) || new item();
				break;

			case CONSTANTS.ACTION_TYPES.ADD_FOLDER:
				this.item = this.findItemInSet(this.shadowItem) || new item();
				break;

			case CONSTANTS.ACTION_TYPES.MOVE_FOLDER:
				this.item = this.findItemInSet(this.shadowItem) || new item();
				break;

			case CONSTANTS.ACTION_TYPES.RENAME_FOLDER:
				this.item = this.findItemInSet(this.shadowItem) || new item();
				break;

			case CONSTANTS.ACTION_TYPES.DELETE_FOLDER:
				this.item = this.findItemInSet(this.shadowItem) || new item();
			default:
				break;
		}
	}

	// TODO: Implement keyboard shortcuts
	handleKeyDown({code}) {
		let itemType = new item(this.item).getType(),
			action = `${CONSTANTS.ACTION_TYPES_KEY_MAP[code.charAt(
				code.length - 1).toLowerCase()]}_${itemType}`;

		let explorerActions = this.template.querySelector(
			'c-qsyd-file-explorer-actions'),
			explorerManagement = this.template.querySelector(
				'c-qsyd-file-explorer-management');

		if (explorerActions && !explorerManagement.showModal) {
			if (explorerActions.isSelectedItemMenuActionEnabled(action)) {
				explorerActions.handleMenuItemSelect({
					detail: {
						value: action,
					},
				});
			}
		}
	}

	handleItemAction(e) {
		const explorerManagement = this.template.querySelector(
			'c-qsyd-file-explorer-management');

		switch (e.detail) {
			case CONSTANTS.ACTION_TYPES.REFRESH:
				this.retrieveFileExplorerItemMap();
				break;

			default:
				this.item = new item(this.item);
				this.item.setHostFolderLabel(this.dataDictionary.folders);
				this.explorerManagementHeader = interpolate(
					CONSTANTS.ACTION_HEADERS[e.detail.toString().
						toUpperCase()], this.item);

				explorerManagement.show(e.detail);
				break;
		}
	}

	handleItemChange(e) {
	}

	handleExplorerManagementClose(e) {
		if (e && e.detail && e.detail.action) {
			this.action = e.detail.action;
			this.shadowItem = e.detail.item;
			this.retrieveFileExplorerItemMap();
		}
	}

	// #### CLICK ITEM START
	handleItemClick(e) {
		// let mainContainer = this.template.querySelector(".file-main-container");
		// mainContainer.focus();

		this.item = e.detail;
		if (this.item.id != 'root') {
			this.results = this.findTreeItem(this.dataDictionary, 'Contents',
				this.folderId);
			this.breadcrumbs = this.buildBreadcrumbs(this.dataDictionary,
				this.item);
		} else {
			this.results = this.findTreeItem(this.dataDictionary, 'Contents',
				null);
			this.breadcrumbs = this.buildBreadcrumbs(this.dataDictionary, null);
		}
	}

	// #### CLICK ITEM END

	// #### SEARCH EVENT START
	handleSearch(e) {
		let searchText = e.detail;

		if (this.searchResultDisplayStyle == 'Typedown Results') {
			this.typedownResults = this.findMatchingResultsToText(
				this.dataDictionary,
				searchText);
		} else if (searchText !== null && searchText !== '') {
			this.results = this.findMatchingResultsToText(
				this.dataDictionary,
				searchText);
		} else {
			if (this.item.id != 'root') {
				this.results = this.findTreeItem(this.dataDictionary,
					'Contents',
					this.folderId);
				this.breadcrumbs = this.buildBreadcrumbs(this.dataDictionary,
					this.item);
			} else {
				this.results = this.findTreeItem(this.dataDictionary,
					'Contents',
					null);
				this.breadcrumbs = this.buildBreadcrumbs(this.dataDictionary,
					null);
			}
		}
	}

	// #### SEARCH EVENT END

	// #### DRAG RESIZE CONTAINER START
	dragBarMouseDown(e) {
		e.preventDefault();
		treeContainerWidth = this.template.querySelector(
			'.file-tree-container').offsetWidth;
		mainContainerWidth = this.template.querySelector(
			'.file-main-container').offsetWidth;
		startPos = e.pageX + 2;
		dragging = true;
	}

	dragMouseMove(e) {
		if (dragging && treeContainerWidth !== 0 && mainContainerWidth !== 0) {
			var currentPos = e.pageX + 2, posDiff = currentPos - startPos;
			var treeContainer = this.template.querySelector(
				'.file-tree-container');
			var mainContainer = this.template.querySelector(
				'.file-main-container');

			var newTreeWidth = treeContainerWidth + posDiff;
			var newMainWidth = mainContainerWidth - posDiff;

			if (newTreeWidth >= treeMinWidth && newMainWidth >= mainMinWidth) {
				var parentWidth = treeContainer.parentNode.offsetWidth;
				treeContainer.style = 'width: ' + (newTreeWidth / parentWidth) *
					100 + '%';
				mainContainer.style = 'width: ' + (newMainWidth / parentWidth) *
					100 + '%';
			}
		}
	}

	dragBarMouseUp(e) {
		if (dragging) {
			treeContainerWidth = 0;
			mainContainerWidth = 0;
			startPos = null;
			dragging = false;
		}
	}

	// #### DRAG RESIZE CONTAINER END

	// #### HELPER FUNCTIONS
	findMatchingResultsToText(data, searchText) {
		let results, folderTextMatches = [], fileTextMatches = [],
			fileTagMatches = [];
		let folders = data.folders, files = data.files;

		if (searchText) {
			const searchKey = RegExp(searchText, 'i');

			if (files && files.length > 0) {
				files.forEach(file => {
					if (file.text.match(searchKey)) {
						fileTextMatches.push(file);
					}

					if (file.tags && file.tags.match(searchKey)) {
						fileTagMatches.push(file);
					}
				});
			}

			if (folders && folders.length > 0) {
				folders.forEach(folder => {
					if (folder.text.match(searchKey)) {
						folderTextMatches.push(folder);
					}
				});
			}
			results = {
				'searchText': searchText,
				'type': 'Search',
				'files': fileTextMatches,
				'folders': folderTextMatches,
				'tags': fileTagMatches,
			};
		} else {
			results = null;
		}
		return results;
	}
}