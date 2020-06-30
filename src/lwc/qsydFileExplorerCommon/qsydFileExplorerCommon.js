/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**
     Author:         Paul Lucas
     Company:        Salesforce
     Description:    qsydFileExplorerCommon - Common File Explorer logic
     Date:           30-Apr2020

     TODO:
        - Modularise

 */
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

/**
 * Enumerations
 */
const CONSTANTS = {
	TOAST_MESSAGE_TYPES: {
		'ALERT': 'alert',
		'CONFIRM': 'confirm',
		'ERROR': 'error',
		'SUCCESS': 'success',
		'TICKER': 'ticker',
		'TOAST': 'toast',
		'WARNING': 'warning',
		'FAILURE': 'Failure',
	},

	TOAST_THEMES: {
		'DEFAULT': 'default',
		'SUCCESS': 'success',
		'ERROR': 'error',
		'WARNING': 'warning',
		'INFORMATION': 'info',
		'OFFLINE': 'offline',
	},

	TOAST_MODE: {
		'DISMISSABLE': 'dismissable',
		'PESTER': 'pester',
		'STICKY': 'sticky',
	},

	ACTION_RESPONSE_STATES: {
		'ERROR': 'error',
		'SUCCESS': 'success',
		'WARNING': 'warning',
		'INFORMATION': 'information',
		'INCOMPLETE': 'incomplete',
	},

	CUSTOM_DOM_EVENT_TYPES: {
		'ITEM_CLICK': 'itemclick',
		'ITEM_ACTION': 'itemaction',
		'ITEM_CHANGE': 'itemchange',
		'EXPLORER_MANAGEMENT_OPEN': 'explorermanagementopen',
		'EXPLORER_MANAGEMENT_CLOSE': 'explorermanagementclose',
		'DATA_REFRESH': 'datarefresh',
		'DATA_LOADED': 'dataloaded',
	},

	ACTION_TYPES: {
		'ADD_FILE': 'add_file',
		'MOVE_FILE': 'move_file',
		'UPDATE_FILE': 'update_file',
		'ADD_FOLDER': 'add_folder',
		'MOVE_FOLDER': 'move_folder',
		'RENAME_FOLDER': 'rename_folder',
		'DELETE_FOLDER': 'delete_folder',
		'REFRESH': 'refresh',
	},

	ACTION_TYPES_KEY_MAP: {
		'a': 'add',
		'm': 'move',
		'r': 'rename',
		'd': 'delete',
	},

	ACTION_LABELS: {
		'ADD_FILE': 'Add',
		'MOVE_FILE': 'Move',
		'ADD_FOLDER': 'Add',
		'MOVE_FOLDER': 'Move',
		'RENAME_FOLDER': 'Rename',
		'DELETE_FOLDER': 'Delete',
		'REFRESH': 'Refresh',
	},

	ACTION_HEADERS: {
		'ADD_FILE': 'Add file(s) to <strong>${hostFolderLabel}</strong> folder',
		'MOVE_FILE': 'Move file',
		'ADD_FOLDER': 'Add folder to <strong>${hostFolderLabel}</strong> folder',
		'MOVE_FOLDER': 'Move <strong>${hostFolderLabel}</strong> folder',
		'RENAME_FOLDER': 'Rename folder',
		'DELETE_FOLDER': 'Delete <strong>${hostFolderLabel}</strong> folder',
		'REFRESH': 'Refresh',
	},

	ACTION_SUCCESS_MESSAGES: {
		'ADD_FILE': 'A new file has been added!',
		'MOVE_FILE': 'The file has been moved!',
		'ADD_FOLDER': 'A new folder has been added!',
		'MOVE_FOLDER': 'The folder has been moved!',
		'RENAME_FOLDER': 'The folder has been renamed!',
		'DELETE_FOLDER': 'The folder has been deleted and any child items have been moved!',
		'REFRESH': 'File Explorer has been refreshed!',
		'SYNCHRONISE': 'File Explorer has been synchronised!',
	},

	ACTION_ERROR_MESSAGES: {
		'MOVE_FILE_SAME_SOURCE_AND_TARGET': 'Source and target folders need to be different.',
		'MOVE_FOLDER_CIRCULAR_DEPENDENCY': 'You cannot move a folder into itself.',
		'MOVE_FOLDER_DESCENDANT': 'You cannot move a folder that is part of its descendant path.',
		'MOVE_FOLDER_SAME_SOURCE_AND_TARGET': 'Source and target folders need to be different.',
	},

	SELECTORS: {
		'CLASS_SPECIFIER': '.',
	},
};

/**
 *
 * Tree item defaults
 */
const itemDefaults = {
	children: [],
	documentId: null,
	entityId: null,
	ext: null,
	hostFolderLabel: 'Home',
	folder: null,
	icon: null,
	id: null,
	owner: null,
	size: 0,
	tags: null,
	text: 'Home',
	type: null,
};

/**
 * A tree item
 */
class item {

	constructor(item) {
		Object.assign(this, itemDefaults, item);
	}

	getId() {
		return this.id;
	}

	getFolder() {
		return this.folder;
	}

	getDocumentId() {
		return this.documentId;
	}

	getType() {
		return this.isFile() ? 'file' : 'folder';
	}

	// TODO: Refactor id = 'root'
	isRoot() {
		return (!this.id || this.id === 'root');
	}

	isFile() {
		return (!!this.documentId);
	}

	setHostFolderLabel(folders) {
		let folder;

		switch (this.isFile()) {
			case true:
				folder = folders.find(f => f.id === this.folder);
				this.hostFolderLabel = folder ? folder.text : this.hostFolderLabel;
				break;

			case false:
				this.hostFolderLabel = this.text;

			default:
				break;
		}
	}
}

/**
 * Show a toast
 * @param caller
 * @param title
 * @param message
 * @param messageData
 * @param variant
 * @param mode
 */
const showToast = (caller, title, message, messageData, variant, mode) => {
	caller.dispatchEvent(new ShowToastEvent({
		'title': title,
		'message': message,
		'messageData': messageData,
		'variant': variant,
		'mode': mode,
	}));
};

/**
 * Convert a dictionary to a list
 * @param dictionary
 * @returns {[]}
 */
const dictionaryToList = (dictionary) => {
	// TODO: Check for object
	let items = Object.values(dictionary);

	// TODO: Type every item?
	return items.reduce((a, b) => a.concat(b)); // .map(i => new item(i));
};

/**
 * Convert a list to a tree hierarchy
 * @param dataset
 * @returns {[]}
 */
const listToTree = (dataset) => {
	let hashTable = Object.create(null),
		dataTree = [];

	hashTable = dataset.reduce(
		(obj, item) => (obj[item.id] = item, obj), hashTable);

	dataset.forEach(item => {
		if (item.folder) {
			hashTable[item.folder].children.push(hashTable[item.id]);
		} else {
			dataTree.push(hashTable[item.id]);
		}
	});

	return dataTree;
};

/**
 * Deep clone an array
 * @param a
 * @param fn
 * @returns {any[]}
 */
const cloneArray = (a, fn) => {
	let keys = Object.keys(a);
	let a2 = new Array(keys.length);

	for (let i = 0; i < keys.length; i++) {
		let k = keys[i];
		let cur = a[k];
		if (typeof cur !== 'object' || cur === null) {
			a2[k] = cur;
		} else if (cur instanceof Date) {
			a2[k] = new Date(cur);
		} else {
			a2[k] = fn(cur);
		}
	}
	return a2;
};

/**
 * Deep clone an object
 * @param o
 * @returns {{}|*[]|Date|*}
 */
const clone = (o) => {
	if (typeof o !== 'object' || o === null) return o;
	if (o instanceof Date) return new Date(o);
	if (Array.isArray(o)) return cloneArray(o, clone);
	let o2 = {};

	for (let k in o) {
		if (Object.hasOwnProperty.call(o, k) === false) continue;

		let cur = o[k];

		if (typeof cur !== 'object' || cur === null) {
			o2[k] = cur;
		} else if (cur instanceof Date) {
			o2[k] = new Date(cur);
		} else {
			o2[k] = clone(cur);
		}
	}
	return o2;
};

/**
 * Reduces one or more errors into a string[] of error messages.
 * @param {errorResponse|errorResponse[]} errors
 * @return {String[]} Error messages
 */
const reduceErrors = (errors) => {
	if (!Array.isArray(errors)) {
		errors = [errors];
	}

	return errors.filter(Boolean).map((error) => {
		if (Array.isArray(error.body)) {
			return error.body.map((b) => b.message);
		} else if (error.body && isString(error.body.message)) {
			return error.body.message;
		} else if (isString(error.message)) {
			return error.message;
		}

		// Fallback to status text
		return error.statusText;
	}).reduce((prev, curr) => prev.concat(curr), []).filter(Boolean);
};

/**
 * True if value is typeof string
 * @param value
 * @returns {boolean}
 */
const isString = (value) => {
	return typeof value === 'string';
};

/**
 * Dynamic string replacement
 * @param str
 * @param obj
 */
const interpolate = (str, obj) => {
	return str.replace(/\${(.*?)}/g, (match, captured) => obj[captured]);
};

export {
	CONSTANTS,
	item,
	showToast,
	dictionaryToList,
	listToTree,
	clone,
	cloneArray,
	reduceErrors,
	interpolate,
};