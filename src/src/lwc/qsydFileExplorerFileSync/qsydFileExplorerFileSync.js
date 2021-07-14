/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
import {LightningElement, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import checkSyncStatus
	from '@salesforce/apex/qsydFileExplorerController.checkSyncStatus';
import syncFiles from '@salesforce/apex/qsydFileExplorerController.syncFiles';
import {CONSTANTS, reduceErrors} from 'c/qsydFileExplorerCommon';

export default class QsydSyncReminder extends LightningElement {

	_addedFilesJSON;
	_needSync;
	_error;

	@api recordId;
	@api objectApiName;

	constructor() {
		super();
	}

	connectedCallback() {
		this.callServerGetSyncStatus();
	}

	renderedCallback() {

	}

	disconnectedCallback() {

	}

	@api
	callServerGetSyncStatus() {
		checkSyncStatus({
			recordId: this.recordId,
		}).then(result => {
			this._needSync = !result;
		}).catch(error => {
			this._error = error;
			this.showToast(
				CONSTANTS.TOAST_MESSAGE_TYPES.ERROR,
				reduceErrors(error).join(', '),
				'',
				CONSTANTS.TOAST_THEMES.ERROR,
				CONSTANTS.TOAST_MODE.DISMISSABLE);
		});
	}

	@api
	callServerSync() {
		syncFiles({
			recordId: this.recordId,
		}).then(result => {
			if (result) {
				this._addedFilesJSON = result;
				debugger
				this.showToast(
					CONSTANTS.TOAST_MESSAGE_TYPES.SUCCESS,
					CONSTANTS.ACTION_SUCCESS_MESSAGES.SYNCHRONISE,
					'',
					CONSTANTS.TOAST_THEMES.SUCCESS,
					CONSTANTS.TOAST_MODE.DISMISSABLE);

				this.dispatchEvent(
					new CustomEvent(
						CONSTANTS.CUSTOM_DOM_EVENT_TYPES.DATA_REFRESH), {},
				);
				this.callServerGetSyncStatus();

			}
		}).catch(error => {
			this._error = error;

			this.showToast(
				CONSTANTS.TOAST_MESSAGE_TYPES.ERROR,
				reduceErrors(error).join(', '),
				'',
				CONSTANTS.TOAST_THEMES.ERROR,
				CONSTANTS.TOAST_MODE.DISMISSABLE);
		});
	}

	handleSync() {
		this.callServerSync();
	}

	showToast(title, message, messageData, variant, mode) {
		const event = new ShowToastEvent({
			'title': title,
			'message': message,
			'messageData': messageData,
			'variant': variant,
			'mode': mode,
		});
		this.dispatchEvent(event);
	}

	get needSync() {
		return this._needSync;
	}
}