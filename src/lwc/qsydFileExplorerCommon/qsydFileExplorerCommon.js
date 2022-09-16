/**
     Author:         Paul Lucas
     Company:        Salesforce
     Description:    qsydFileExplorerCommon - Common File Explorer logic
     Date:           30-Apr-2020

     TODO:
        - Modularise

 */
import ACTION_ERROR_MESSAGES__MOVE_FOLDER_DESCENDANT
	from '@salesforce/label/c.Action_Error_Messages_Move_folder_descendant';
import ACTION_ERROR_MESSAGES__MOVE_FILE_SAME_SOURCE_AND_TARGET
	from '@salesforce/label/c.Action_Error_Messages_Move_file_same_source_and_target';
import ACTION_ERROR_MESSAGES__MOVE_FOLDER_CIRCULAR_DEPENDENCY
	from '@salesforce/label/c.Action_Error_Messages_Move_folder_circular_dependency';
import ACTION_ERROR_MESSAGES__MOVE_FOLDER_SAME_SOURCE_AND_TARGET
	from '@salesforce/label/c.Action_Error_Messages_Move_folder_same_source_and_target';
import ACTION_ERROR_MESSAGES__FAILED_TO_RETRIEVE_TEMPLATES
	from '@salesforce/label/c.Action_Error_Messages_Failed_to_retrieve_templates';

import ACTION_HEADERS__ADD_FILE
	from '@salesforce/label/c.Action_Headers_Add_file';
import ACTION_HEADERS__ADD_FOLDER
	from '@salesforce/label/c.Action_Headers_Add_folder';
import ACTION_HEADERS__DELETE_FILE
	from '@salesforce/label/c.Action_Headers_Delete_file';
import ACTION_HEADERS__DELETE_FOLDER
	from '@salesforce/label/c.Action_Headers_Delete_folder';
import ACTION_HEADERS__MOVE_FILE
	from '@salesforce/label/c.Action_Headers_Move_file';
import ACTION_HEADERS__MOVE_FOLDER
	from '@salesforce/label/c.Action_Headers_Move_folder';
import ACTION_HEADERS__REFRESH
	from '@salesforce/label/c.Action_Headers_Refresh';
import ACTION_HEADERS__RENAME_FOLDER
	from '@salesforce/label/c.Action_Headers_Rename_folder';
import ACTION_HEADERS__TEMPLATE_FOLDER
	from '@salesforce/label/c.Action_Headers_Template_folder';
import ACTION_HEADERS__EDIT_TAGS
	from '@salesforce/label/c.Action_Headers_Edit_tags';

import TREE_LABELS__HOME
	from '@salesforce/label/c.Tree_Labels_Home';

import ACTION_LABELS__FILE_HEADER
	from '@salesforce/label/c.Action_Labels_File_header';
import ACTION_LABELS__FOLDER_HEADER
	from '@salesforce/label/c.Action_Labels_Folder_header';
import ACTION_LABELS__GENERAL_HEADER
	from '@salesforce/label/c.Action_Labels_General_header';
import ACTION_LABELS__ADD_FILE
	from '@salesforce/label/c.Action_Labels_Add_file';
import ACTION_LABELS__ADD_FOLDER
	from '@salesforce/label/c.Action_Labels_Add_folder';
import ACTION_LABELS__DELETE_FILE
	from '@salesforce/label/c.Action_Labels_Delete_file';
import ACTION_LABELS__DELETE_FOLDER
	from '@salesforce/label/c.Action_Labels_Delete_folder';
import ACTION_LABELS__MOVE_FILE
	from '@salesforce/label/c.Action_Labels_Move_file';
import ACTION_LABELS__MOVE_FOLDER
	from '@salesforce/label/c.Action_Labels_Move_folder';
import ACTION_LABELS__ADD_TEMPLATE
	from '@salesforce/label/c.Action_Labels_Add_template';
import ACTION_LABELS__TEMPLATE_FOLDER
	from '@salesforce/label/c.Action_Labels_Template_folder';
import ACTION_LABELS__REFRESH from '@salesforce/label/c.Action_Labels_Refresh';
import ACTION_LABELS__TAG_NAME
	from '@salesforce/label/c.Action_Labels_Tag_name';
import ACTION_LABELS__RENAME_FOLDER
	from '@salesforce/label/c.Action_Labels_Rename_folder';
import ACTION_LABELS__EXPAND from '@salesforce/label/c.Action_Labels_Expand';
import ACTION_LABELS__COLLAPSE
	from '@salesforce/label/c.Action_Labels_Collapse';
import ACTION_LABELS__CANCEL from '@salesforce/label/c.Action_Labels_Cancel';
import ACTION_LABELS__CONFIRM from '@salesforce/label/c.Action_Labels_Confirm';
import ACTION_LABELS__FOLDER_NAME
	from '@salesforce/label/c.Action_Labels_Folder_name';
import ACTION_LABELS__FOLDER_NAME_PLACEHOLDER
	from '@salesforce/label/c.Action_Labels_Folder_name_placeholder';
import ACTION_LABELS__EDIT_TEMPLATE
	from '@salesforce/label/c.Action_Labels_Edit_template';
import ACTION_LABELS__TEMPLATE_DESCRIPTION_HEADER
	from '@salesforce/label/c.Action_Labels_Template_description_header';
import ACTION_LABELS__TEMPLATE_LABEL_HEADER
	from '@salesforce/label/c.Action_Labels_Template_label_header';
import ACTION_LABELS__TEMPLATE_MODIFIED_DATE_HEADER
	from '@salesforce/label/c.Action_Labels_Template_modified_date_header';
import ACTION_LABELS__TEMPLATE_NAME_HEADER
	from '@salesforce/label/c.Action_Labels_Template_name_header';


import ACTION_VALIDATIONS__FOLDER_NAME_VALIDATION
	from '@salesforce/label/c.Action_Validations_Folder_name_validation';
import ACTION_VALIDATIONS__TAG_NAME_VALIDATION
	from '@salesforce/label/c.Action_Validations_Tag_name_validation';

import ACTION_MESSAGES__DELETE_FILE
	from '@salesforce/label/c.Action_Messages_Delete_file';
import ACTION_MESSAGES__DELETE_FOLDER
	from '@salesforce/label/c.Action_Messages_Delete_folder';
import ACTION_MESSAGES__NO_PERMISSION_SET
	from '@salesforce/label/c.Action_Messages_No_permission_set';
import ACTION_MESSAGES__SYNCHRONISATION_REQUIRED
	from '@salesforce/label/c.Action_Messages_Synchronisation_required';
import ACTION_MESSAGES__NO_TEMPLATES
	from '@salesforce/label/c.Action_Messages_No_templates';
import ACTION_MESSAGES__SELECT_TEMPLATE_FOLDER
	from '@salesforce/label/c.Action_Messages_Select_template_folder';

import ACTION_SUCCESS_MESSAGES__ADD_FILE
	from '@salesforce/label/c.Action_Success_Messages_Add_file';
import ACTION_SUCCESS_MESSAGES__ADD_FOLDER
	from '@salesforce/label/c.Action_Success_Messages_Add_folder';
import ACTION_SUCCESS_MESSAGES__DELETE_FILE
	from '@salesforce/label/c.Action_Success_Messages_Delete_file';
import ACTION_SUCCESS_MESSAGES__DELETE_FOLDER
	from '@salesforce/label/c.Action_Success_Messages_Delete_folder';
import ACTION_SUCCESS_MESSAGES__MOVE_FILE
	from '@salesforce/label/c.Action_Success_Messages_Move_file';
import ACTION_SUCCESS_MESSAGES__MOVE_FOLDER
	from '@salesforce/label/c.Action_Success_Messages_Move_folder';
import ACTION_SUCCESS_MESSAGES__REFRESH
	from '@salesforce/label/c.Action_Success_Messages_Refresh';
import ACTION_SUCCESS_MESSAGES__RENAME_FOLDER
	from '@salesforce/label/c.Action_Success_Messages_Rename_folder';
import ACTION_SUCCESS_MESSAGES__SYNCHRONISE
	from '@salesforce/label/c.Action_Success_Messages_Synchronise';
import ACTION_SUCCESS_MESSAGES__EDIT_TAGS
	from '@salesforce/label/c.Action_Success_Messages_Edit_tags';
import ACTION_SUCCESS_MESSAGES__TEMPLATE_FOLDER
	from '@salesforce/label/c.Action_Success_Messages_Template_folder';

import SEARCH__NO_RESULTS_FOR_CATEGORY
	from '@salesforce/label/c.Search_No_results_for_category';
import SEARCH__PLACEHOLDER from '@salesforce/label/c.Search_Placeholder';
import SEARCH__RESULTS from '@salesforce/label/c.Search_Results';

import SEARCH_CATEGORY__FILES from '@salesforce/label/c.Search_Category_Files';
import SEARCH_CATEGORY__FOLDERS
	from '@salesforce/label/c.Search_Category_Folders';
import SEARCH_CATEGORY__TAGGED
	from '@salesforce/label/c.Search_Category_Tagged';

import DETAIL_LABELS__DOWNLOAD
	from '@salesforce/label/c.Detail_Labels_Download';
import DETAIL_LABELS__EDIT_TAGS
	from '@salesforce/label/c.Detail_Labels_Edit_Tags';
import DETAIL_LABELS__LAST_MODIFIED
	from '@salesforce/label/c.Detail_Labels_Last_modified';
import DETAIL_LABELS__OPEN_FILE
	from '@salesforce/label/c.Detail_Labels_Open_file';
import DETAIL_LABELS__OWNER from '@salesforce/label/c.Detail_Labels_Owner';
import DETAIL_LABELS__PREVIEW from '@salesforce/label/c.Detail_Labels_Preview';
import DETAIL_LABELS__SIZE from '@salesforce/label/c.Detail_Labels_Size';
import DETAIL_LABELS__TAGS from '@salesforce/label/c.Detail_Labels_Tags';
import DETAIL_LABELS__TYPE from '@salesforce/label/c.Detail_Labels_Type';

import DETAIL_MESSAGES__SELECT_FILE
	from '@salesforce/label/c.Detail_Messages_Select_File';
import DETAIL_MESSAGES__VERSION
	from '@salesforce/label/c.Detail_Messages_Version';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';

/**
 * Enumerations
 */
const CONSTANTS = {
	USERTYPES: {
		AUTOMATEDPROCESS: 'AutomatedProcess'
	},

	SYSTEM_ERRORS: {
		NO_ACCESS_TO_APEX_CLASS: "You do not have access to the Apex class named 'qsyd_FileExplorerCommon'.",
	},

	USER_ERRORS: {
		NO_ACCESS_TO_APEX_CLASS: ACTION_MESSAGES__NO_PERMISSION_SET,
	},

	FILE_EXPLORER_OBJECT_API_NAMES: {
		FILE: 'FileExplorerFile__c',
		FOLDER: 'FileExplorerFolder__c',
		FOLDER_TEMPLATE: 'FileExplorerFolderTemplate__c',
	},

	NAVIGATION_ACTIONS: {
		NEW: 'new',
		VIEW: 'view',
		EDIT: 'edit',
		LIST: 'list',
		HOME: 'home',
	},

	NAVIGATION_TYPES: {
		OBJECT_PAGE: 'standard__objectPage',
		RECORD_PAGE: 'standard__recordPage',
		NAMED_PAGE: 'standard__namedPage',
		NAV_ITEM_PAGE: 'standard__navItemPage',
		RECORD_RELATIONSHIP_PAGE: 'standard__recordRelationshipPage',
		COMPONENT: 'standard__component',
		WEB_PAGE: 'standard__webPage',
	},

	TOAST_MESSAGE_TYPES: {
		ALERT: 'alert',
		CONFIRM: 'confirm',
		ERROR: 'error',
		SUCCESS: 'success',
		TICKER: 'ticker',
		TOAST: 'toast',
		WARNING: 'warning',
		FAILURE: 'Failure',
	},

	TOAST_THEMES: {
		DEFAULT: 'default',
		SUCCESS: 'success',
		ERROR: 'error',
		WARNING: 'warning',
		INFORMATION: 'info',
		OFFLINE: 'offline',
	},

	TOAST_MODE: {
		DISMISSABLE: 'dismissable',
		PESTER: 'pester',
		STICKY: 'sticky',
	},

	ACTION_RESPONSE_STATES: {
		ERROR: 'error',
		SUCCESS: 'success',
		WARNING: 'warning',
		INFORMATION: 'information',
		INCOMPLETE: 'incomplete',
	},

	CUSTOM_DOM_EVENT_TYPES: {
		DATA_REFRESH: 'datarefresh',
		DATA_LOADED: 'dataloaded',
		EXPLORER_LOADED: 'explorerloaded',
		EXPLORER_MANAGEMENT_OPEN: 'explorermanagementopen',
		EXPLORER_MANAGEMENT_CLOSE: 'explorermanagementclose',
		ITEM_CLICK: 'itemclick',
		ITEM_ACTION: 'itemaction',
		ITEM_CHANGE: 'itemchange',
		KEY_DOWN: 'keydown',

		// ACTION_ADD_FILE: 'actionaddfile',
		// ACTION_MOVE_FILE: 'actionmovefile',
		// ACTION_ADD_FOLDER: 'actionaddfolder',
		// ACTION_MOVE_FOLDER: 'actionmovefolder',
		// ACTION_RENAME_FOLDER: 'actionrenamefolder',
		// ACTION_DELETE_FOLDER: 'actiondeletefolder',
		// ACTION_DATA_REFRESH: 'actiondatarefresh',
	},

	ACTION_TYPES: {
		ADD_FILE: 'add_file',
		MOVE_FILE: 'move_file',
		UPDATE_FILE: 'update_file',
		DELETE_FILE: 'delete_file',
		ADD_FOLDER: 'add_folder',
		MOVE_FOLDER: 'move_folder',
		RENAME_FOLDER: 'rename_folder',
		DELETE_FOLDER: 'delete_folder',
		TEMPLATE_FOLDER: 'template_folder',
		REFRESH: 'refresh',
	},

	ACTION_TYPES_KEY_MAP: {
		a: 'add',
		m: 'move',
		r: 'rename',
		d: 'delete',
	},

	TREE_LABELS: {
		HOME: TREE_LABELS__HOME,
	},

	ACTION_LABELS: {
		FILE_HEADER: ACTION_LABELS__FILE_HEADER,
		ADD_FILE: ACTION_LABELS__ADD_FILE,
		MOVE_FILE: ACTION_LABELS__MOVE_FILE,
		DELETE_FILE: ACTION_LABELS__DELETE_FILE,
		FOLDER_HEADER: ACTION_LABELS__FOLDER_HEADER,
		ADD_FOLDER: ACTION_LABELS__ADD_FOLDER,
		MOVE_FOLDER: ACTION_LABELS__MOVE_FOLDER,
		RENAME_FOLDER: ACTION_LABELS__RENAME_FOLDER,
		DELETE_FOLDER: ACTION_LABELS__DELETE_FOLDER,
		ADD_TEMPLATE: ACTION_LABELS__ADD_TEMPLATE,
		TEMPLATE_FOLDER: ACTION_LABELS__TEMPLATE_FOLDER,
		GENERAL_HEADER: ACTION_LABELS__GENERAL_HEADER,
		REFRESH: ACTION_LABELS__REFRESH,
		EXPAND: ACTION_LABELS__EXPAND,
		COLLAPSE: ACTION_LABELS__COLLAPSE,
		CANCEL: ACTION_LABELS__CANCEL,
		CONFIRM: ACTION_LABELS__CONFIRM,
		FOLDER_NAME: ACTION_LABELS__FOLDER_NAME,
		FOLDER_NAME_PLACEHOLDER: ACTION_LABELS__FOLDER_NAME_PLACEHOLDER,
		TAG_NAME: ACTION_LABELS__TAG_NAME,
		TEMPLATE_DESCRIPTION_HEADER: ACTION_LABELS__TEMPLATE_DESCRIPTION_HEADER,
		TEMPLATE_LABEL_HEADER: ACTION_LABELS__TEMPLATE_LABEL_HEADER,
		TEMPLATE_MODIFIED_DATE_HEADER: ACTION_LABELS__TEMPLATE_MODIFIED_DATE_HEADER,
		TEMPLATE_NAME_HEADER: ACTION_LABELS__TEMPLATE_NAME_HEADER,
		EDIT_TEMPLATE: ACTION_LABELS__EDIT_TEMPLATE,
	},

	ACTION_HEADERS: {
		ADD_FILE: ACTION_HEADERS__ADD_FILE,
		MOVE_FILE: ACTION_HEADERS__MOVE_FILE,
		DELETE_FILE: ACTION_HEADERS__DELETE_FILE,
		ADD_FOLDER: ACTION_HEADERS__ADD_FOLDER,
		MOVE_FOLDER: ACTION_HEADERS__MOVE_FOLDER,
		RENAME_FOLDER: ACTION_HEADERS__RENAME_FOLDER,
		TEMPLATE_FOLDER: ACTION_HEADERS__TEMPLATE_FOLDER,
		DELETE_FOLDER: ACTION_HEADERS__DELETE_FOLDER,
		REFRESH: ACTION_HEADERS__REFRESH,
		EDIT_TAGS: ACTION_HEADERS__EDIT_TAGS,
	},

	ACTION_SUCCESS_MESSAGES: {
		ADD_FILE: ACTION_SUCCESS_MESSAGES__ADD_FILE,
		MOVE_FILE: ACTION_SUCCESS_MESSAGES__MOVE_FILE,
		DELETE_FILE: ACTION_SUCCESS_MESSAGES__DELETE_FILE,
		ADD_FOLDER: ACTION_SUCCESS_MESSAGES__ADD_FOLDER,
		MOVE_FOLDER: ACTION_SUCCESS_MESSAGES__MOVE_FOLDER,
		RENAME_FOLDER: ACTION_SUCCESS_MESSAGES__RENAME_FOLDER,
		DELETE_FOLDER: ACTION_SUCCESS_MESSAGES__DELETE_FOLDER,
		TEMPLATE_FOLDER: ACTION_SUCCESS_MESSAGES__TEMPLATE_FOLDER,
		REFRESH: ACTION_SUCCESS_MESSAGES__REFRESH,
		SYNCHRONISE: ACTION_SUCCESS_MESSAGES__SYNCHRONISE,
		EDIT_TAGS: ACTION_SUCCESS_MESSAGES__EDIT_TAGS,
	},

	ACTION_ERROR_MESSAGES: {
		MOVE_FILE_SAME_SOURCE_AND_TARGET: ACTION_ERROR_MESSAGES__MOVE_FILE_SAME_SOURCE_AND_TARGET,
		MOVE_FOLDER_CIRCULAR_DEPENDENCY: ACTION_ERROR_MESSAGES__MOVE_FOLDER_CIRCULAR_DEPENDENCY,
		MOVE_FOLDER_DESCENDANT: ACTION_ERROR_MESSAGES__MOVE_FOLDER_DESCENDANT,
		MOVE_FOLDER_SAME_SOURCE_AND_TARGET: ACTION_ERROR_MESSAGES__MOVE_FOLDER_SAME_SOURCE_AND_TARGET,
		FAILED_TO_RETRIEVE_TEMPLATES: ACTION_ERROR_MESSAGES__FAILED_TO_RETRIEVE_TEMPLATES,
	},

	ACTION_MESSAGES: {
		DELETE_FILE: ACTION_MESSAGES__DELETE_FILE,
		DELETE_FOLDER: ACTION_MESSAGES__DELETE_FOLDER,
		NO_PERMISSION_SET: ACTION_MESSAGES__NO_PERMISSION_SET,
		SYNCHRONISATION_REQUIRED: ACTION_MESSAGES__SYNCHRONISATION_REQUIRED,
		NO_TEMPLATES: ACTION_MESSAGES__NO_TEMPLATES,
		SELECT_TEMPLATE_FOLDER: ACTION_MESSAGES__SELECT_TEMPLATE_FOLDER,
	},

	ACTION_VALIDATIONS: {
		FOLDER_NAME_VALIDATION: ACTION_VALIDATIONS__FOLDER_NAME_VALIDATION,
		TAG_NAME_VALIDATION: ACTION_VALIDATIONS__TAG_NAME_VALIDATION,
	},

	DETAIL_LABELS: {
		DOWNLOAD: DETAIL_LABELS__DOWNLOAD,
		EDIT_TAGS: DETAIL_LABELS__EDIT_TAGS,
		LAST_MODIFIED: DETAIL_LABELS__LAST_MODIFIED,
		OPEN_FILE: DETAIL_LABELS__OPEN_FILE,
		OWNER: DETAIL_LABELS__OWNER,
		PREVIEW: DETAIL_LABELS__PREVIEW,
		SIZE: DETAIL_LABELS__SIZE,
		TAGS: DETAIL_LABELS__TAGS,
		TYPE: DETAIL_LABELS__TYPE,
	},

	DETAIL_MESSAGES: {
		SELECT_FILE: DETAIL_MESSAGES__SELECT_FILE,
		VERSION: `<a href='https://salesforce.quip.com/M45zATwr2795' target="_blank">${DETAIL_MESSAGES__VERSION}</a>`,
	},

	SEARCH: {
		NO_RESULTS_FOR_CATEGORY: SEARCH__NO_RESULTS_FOR_CATEGORY,
		PLACEHOLDER: SEARCH__PLACEHOLDER,
		RESULTS: SEARCH__RESULTS,
	},

	SEARCH_CATEGORY: {
		FILES: SEARCH_CATEGORY__FILES,
		FOLDERS: SEARCH_CATEGORY__FOLDERS,
		TAGGED: SEARCH_CATEGORY__TAGGED,
	},

	SELECTORS: {
		CLASS_SPECIFIER: '.',
	},

	KEY_CODES: {
		ENTER: 13,
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
	hostFolderLabel: CONSTANTS.TREE_LABELS.HOME,
	folder: null,
	icon: null,
	id: null,
	ownerId: null,
	owner: null,
	userType: null,
	objectApiName: null,
	size: 0,
	tags: null,
	text: CONSTANTS.TREE_LABELS.HOME,
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

	isTemplate() {
		return (this.objectApiName ===
			CONSTANTS.FILE_EXPLORER_OBJECT_API_NAMES.FOLDER_TEMPLATE);
	}

	isOwnedByAnAutomatedProcessUser(){
		return this.userType === CONSTANTS.USERTYPES.AUTOMATEDPROCESS;
	}
	canDelete(userId) {
		return userId === this.ownerId || this.isOwnedByAnAutomatedProcessUser();
	}

	setHostFolderLabel(folders) {
		let folder;

		switch (this.isFile()) {
			case true:
				folder = folders.find(f => f.id === this.folder);
				this.hostFolderLabel = folder
					? folder.text
					: this.hostFolderLabel;
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
		'title': title.charAt(0).toUpperCase() +
			title.substr(1).toLowerCase(),
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
const reduceErrors = (errors, translate = true) => {
	if (!Array.isArray(errors)) {
		errors = [errors];
	}

	// TODO: Cycle through SYSTEM_ERRORS and find corresponding USER_ERRORS
	return errors.filter(Boolean).map((error) => {
		if (Array.isArray(error.body)) {
			return error.body.map((b) => b.message.replace(CONSTANTS.SYSTEM_ERRORS.NO_ACCESS_TO_APEX_CLASS, CONSTANTS.USER_ERRORS.NO_ACCESS_TO_APEX_CLASS));
		} else if (error.body && isString(error.body.message)) {
			return error.body.message.replace(CONSTANTS.SYSTEM_ERRORS.NO_ACCESS_TO_APEX_CLASS, CONSTANTS.USER_ERRORS.NO_ACCESS_TO_APEX_CLASS);
		} else if (isString(error.message)) {
			return error.message.replace(CONSTANTS.SYSTEM_ERRORS.NO_ACCESS_TO_APEX_CLASS, CONSTANTS.USER_ERRORS.NO_ACCESS_TO_APEX_CLASS);
		}

		// Default to statusText property
		return error.statusText;
	}).reduce((prev, curr) => prev.concat(curr.replace(/(<([^>]+)>)/gi, '')),
		[]).filter(Boolean);
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