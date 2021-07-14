/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
import {LightningElement, api, track, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getLatestContentVersion
	from '@salesforce/apex/qsydFileExplorerController.getLatestContentVersion';
import updateTags from '@salesforce/apex/qsydFileExplorerController.updateTags';
import isCommunity
	from '@salesforce/apex/qsydFileExplorerController.isCommunity';
import getCommunityPrefix
	from '@salesforce/apex/qsydFileExplorerController.getCommunityPrefix';

import {CONSTANTS} from 'c/qsydFileExplorerCommon';

export default class QsydFileExplorerDetail extends NavigationMixin(
	LightningElement) {

	_error;
	_item;
	_contentVersion;
	_tagInput;
	_tags;
	_modalTags;
	_newtags;

	currentPagePrefix = '';
	redraw = false;
	showModal = false;
	showPreview = true;

	constructor() {
		super();
	}

	@api
	get tags() {
		if (this._tags && this._tags.length != 0) {
			return this._tags;
		} else {
			let tags = this._item.tags;
			if (tags) {
				this._tags = tags.split(';').sort(function(a, b) {
					return a.localeCompare(b);
				});
			} else {
				this._tags = [];
			}
			return this._tags;
		}
	}

	set tags(value) {

	}

	get _modalTags() {
		return this._modalTags;
	}

	set _modalTags(value) {
		this._modalTags = value;
	}

	@api
	get item() {
		return this._item;
	}

	set item(value) {
		//console.log('--Details item-->' + JSON.stringify(value));
		this._item = value;
		this._contentVersion = null;
		this._tags = null;
		this._navigate = 0;
		if (this._item && this._item.documentId) {
			this.getLatestContentVersion();
		}

	}

	get isContentVersionReady() {
		return (this._contentVersion);
	}

	get isFile() {
		return (this._item && this._item.documentId);
	}

	get previewImageSrc() {
		if (this._contentVersion) {

			return this.currentPagePrefix +
				'/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' +
				this._contentVersion.Id + '&operationContext=CHATTER';
		} else {
			return 'https://qsyd-perma-bucket.s3-ap-southeast-2.amazonaws.com/file-explorer/images/file200x200.png';
		}
	}

	get downloadLink() {
		return this.currentPagePrefix +
			'/sfc/servlet.shepherd/document/download/' +
			this._item.documentId;
	}

	get filetype() {
		return this._item.type;
	}

	get fileowner() {
		return this._item.owner;
	}

	get filename() {
		return this._item.text;
	}

	get filesize() {
		if (this._item.size == 0 || this._item.size == null ||
			isNaN(this._item.size)) {
			return '0.00 B';
		}
		let e = Math.floor(Math.log(this._item.size) / Math.log(1024));
		return (this._item.size / Math.pow(1024, e)).toFixed(2) + ' ' +
			' KMGTP'.charAt(e) + 'B';
	}

	get lastModifiedDate() {
		let dtParse = Date.parse(this._contentVersion.LastModifiedDate);
		let dt = new Date(dtParse);
		let dtString = dt.toLocaleString();

		return dtString;
	}

	get tagInput() {
		return this._tagInput || '';
	}

	set tagInput(value) {
		this._tagInput = value;
	}

	get modalTagsJson() {
		return JSON.stringify(this._modalTags);
	}

	get previewImageClass() {
		if (this._contentVersion) {
			return 'previewImgContainer';
		} else {
			return 'previewImgContainer previewImgBackground';
		}
	}

	get showPreview() {
		return this.showPreview;
	}

	connectedCallback() {
		// initialize component
		this.environmentCheck();
	}

	renderedCallback() {}

	environmentCheck() {
		isCommunity().then(result => {
			this.showPreview = !result;
		}).catch(error => {
			this.error = error;
		});

		getCommunityPrefix().then(result => {
			if (result != null) {
				this.currentPagePrefix = result;
			}
		}).catch(error => {
			this._error = error;
		});

	}

	getLatestContentVersion() {
		if (this._contentVersion != null) {
			return;
		}
		getLatestContentVersion({
			contentDocumentId: this._item.documentId,
		}).then(result => {
			let res = JSON.parse(result);
			if (res) {
				this._contentVersion = res;
			}
		}).catch(error => {
			this._error = error;
		});
	}

	show() {
		this.showModal = true;
	}

	hide() {
		this.showModal = false;
	}

	initModalTags() {
		if (this._tags) {
			this._modalTags = (this._tags.map(tag => ({
				name: tag,
				label: tag,
			})));
		}
	}

	handleImgError(e) {
		if (e && e.target) {
			e.target.src = 'https://qsyd-perma-bucket.s3-ap-southeast-2.amazonaws.com/file-explorer/images/file200x200.png';
		}
	}

	handleDialogOpen() {
		this.show();
		this.redraw = true;
		this.redraw = false;
		this.initModalTags();
		setTimeout(() => {
			this.redraw = true;
		}, 0);
	}

	handleKeyUp(e) {
		this._tagInput = e.target.value;
		if (e && e.keyCode === 13) {
			e.preventDefault();
			this.handleInsertTag();
		}
	}

	handleAddButtonClick(e) {
		this.handleInsertTag();
	}

	handleInsertTag() {
		if (!this._tagInput || this._tagInput.trim().length == 0) {
			return;
		}
		this.redraw = false;
		if (!this._modalTags) {
			this.initModalTags();
		}
		this._tagInput = this._tagInput.replace(/;/g, '');
		if ((this._modalTags.some(
			modalTag => modalTag.name === this._tagInput)) == false) {
			this._modalTags.push({
				name: this._tagInput,
				label: this._tagInput,
			});
		}
		setTimeout(() => {
			this.redraw = true;
		}, 0);
		this._tagInput = '';
	}

	handleTagRemove(event) {
		this.redraw = false;
		const name = event.detail.item.name;
		this._modalTags = this._modalTags.filter(function(value, index, arr) {
			return (value.name != name);
		});
		setTimeout(() => {
			this.redraw = true;
		}, 0);
	}

	handleTagsSave() {
		this._newtags = this._modalTags.map(x => x.name);
		let fileId = this._item.id;
		let tags = this._newtags.sort().join(';') || '';
		let oldTags = this._tags.sort().join(';') || '';
		if (tags == oldTags) {
			this.handleTagsCancel();
		} else {
			this.insertTagsServerSide(fileId, tags);
		}

	}

	insertTagsServerSide(fileId, tags) {
		updateTags({
			fileId: fileId,
			tags: tags,
		}).then(result => {
			let res = JSON.parse(result);
			if (res) {
				this._tags = [...this._newtags];
				this.showToast(
					'Success',
					'Record Updated',
					'',
					'success',
					'dismissable');
				this.hide();

				this.dispatchEvent(
					new CustomEvent(
						CONSTANTS.CUSTOM_DOM_EVENT_TYPES.EXPLORER_MANAGEMENT_CLOSE,
						{
							'detail': {
								'action': CONSTANTS.ACTION_TYPES.UPDATE_FILE,
								'item': {
									'id': this.item.id,
								},
							},
						}),
				);
			} else {
				this.showToast(
					'Error',
					'Failed to update the record',
					'',
					'error',
					'dismissable');
				this.handleTagsCancel();
			}
		}).catch(error => {
			this._error = error;
		});
	}

	handleTagsCancel() {
		this._tagInput = '';
		this._newtags = [];
		this.hide();
		this.initModalTags();
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

	navigateToFilePreviewPage() {
		this[NavigationMixin.Navigate]({
			type: 'standard__namedPage',
			attributes: {
				pageName: 'filePreview',
			},
			state: {
				recordIds: this._item.documentId,
				selectedRecordId: this._item.documentId,
			},
		});
	}

	navigateToFileRecordPage() {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: this._item.documentId,
				actionName: 'view',
			},
		});
	}
}