import {LightningElement, api, track, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getLatestContentVersion from '@salesforce/apex/qsydFileExplorerController.getLatestContentVersion';
import updateTags from '@salesforce/apex/qsydFileExplorerController.updateTags';
import isCommunity from '@salesforce/apex/qsydFileExplorerController.isCommunity';
import getCommunityPrefix from '@salesforce/apex/qsydFileExplorerController.getCommunityPrefix';
import userId from '@salesforce/user/Id';

import {CONSTANTS, reduceErrors, showToast} from 'c/qsydFileExplorerCommon';

const FILE_PLACEHOLDER = 'https://qsyd-perma-bucket.s3-ap-southeast-2.amazonaws.com/file-explorer/images/file200x200.png';
const FILE_PREVIEW = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&operationContext=CHATTER&versionId=';
const FILE_DOWNLOAD = '/sfc/servlet.shepherd/document/download/';

export default class QsydFileExplorerDetail extends NavigationMixin(LightningElement) {

	_error;
	_item;
	_contentVersion;
	_tagInput;
	_tags;
	_modalTags;
	_newTags;

	CONSTANTS = CONSTANTS;
	currentPagePrefix = '';
	redraw = false;
	showModal = false;
	showPreview = true;
	version = '';

	constructor() {
		super();
	}

	@api get tags() {
		if (this._tags && this._tags.length != 0) {
			return this._tags;
		} else {
			let tags = this._item.tags;
			if (tags) {
				this._tags = tags.split(';').sort(function (a, b) {
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

	get modalTags() {
		return this._modalTags;
	}

	set modalTags(value) {
		this._modalTags = value;
	}

	@api get item() {
		return this._item;
	}

	set item(value) {
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
			return this.currentPagePrefix + FILE_PREVIEW + this._contentVersion.Id;
		}

		return FILE_PLACEHOLDER;
	}

	get downloadLink() {
		return this.currentPagePrefix + FILE_DOWNLOAD + this._item.documentId;
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
		if (this._item.size == 0 || this._item.size == null || isNaN(this._item.size)) {
			return '0.00 B';
		}
		let e = Math.floor(Math.log(this._item.size) / Math.log(1024));
		return (this._item.size / Math.pow(1024, e)).toFixed(2) + ' ' + ' KMGTP'.charAt(e) + 'B';
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
		return JSON.stringify(this.modalTags);
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

	get canDelete() {
		debugger;
		return this._item.canDelete(userId);
		// return this._item.ownerId == userId;
	}

	connectedCallback() {
		this.environmentCheck();
	}

	renderedCallback() {
	}

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
			this.modalTags = (this._tags.map(tag => ({
				name: tag, label: tag,
			})));
		}
	}

	handleImgError(e) {
		if (e && e.target) {
			e.target.src = FILE_PLACEHOLDER;
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
		if (!this.modalTags) {
			this.initModalTags();
		}
		this._tagInput = this._tagInput.replace(/;/g, '');
		if ((this.modalTags.some(modalTag => modalTag.name === this._tagInput)) == false) {
			this.modalTags.push({
				name: this._tagInput, label: this._tagInput,
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
		this.modalTags = this.modalTags.filter(function (value, index, arr) {
			return (value.name != name);
		});
		setTimeout(() => {
			this.redraw = true;
		}, 0);
	}

	handleTagsSave() {
		this._newTags = this.modalTags.map(x => x.name);
		let fileId = this._item.id;
		let tags = this._newTags.sort().join(';') || '';
		let oldTags = this._tags.sort().join(';') || '';
		if (tags == oldTags) {
			this.handleTagsCancel();
		} else {
			this.insertTagsServerSide(fileId, tags);
		}
	}

	insertTagsServerSide(fileId, tags) {
		updateTags({
			fileId: fileId, tags: tags,
		}).then(result => {
			let res = JSON.parse(result);
			if (res) {
				this._tags = [...this._newTags];

				showToast(this, this.CONSTANTS.TOAST_MESSAGE_TYPES.SUCCESS, this.CONSTANTS.ACTION_SUCCESS_MESSAGES.EDIT_TAGS, '', this.CONSTANTS.TOAST_THEMES.SUCCESS, this.CONSTANTS.TOAST_MODE.STICKY);

				this.hide();

				this.dispatchEvent(new CustomEvent(CONSTANTS.CUSTOM_DOM_EVENT_TYPES.EXPLORER_MANAGEMENT_CLOSE, {
					'detail': {
						'action': CONSTANTS.ACTION_TYPES.UPDATE_FILE, 'item': {
							'id': this.item.id,
						},
					},
				}),);
			} else {
				showToast(this, this.CONSTANTS.TOAST_MESSAGE_TYPES.ERROR, 'Failed to update the record', '', this.CONSTANTS.TOAST_THEMES.ERROR, this.CONSTANTS.TOAST_MODE.STICKY);
				this.handleTagsCancel();
			}
		}).catch(error => {
			this._error = error;
		});
	}

	handleTagsCancel() {
		this._tagInput = '';
		this._newTags = [];
		this.hide();
		this.initModalTags();
	}

	navigateToFilePreviewPage() {
		this[NavigationMixin.Navigate]({
			type: this.CONSTANTS.NAVIGATION_TYPES.NAMED_PAGE, attributes: {
				pageName: 'filePreview',
			}, state: {
				recordIds: this._item.documentId, selectedRecordId: this._item.documentId,
			},
		});
	}

	navigateToFileRecordPage() {
		this[NavigationMixin.Navigate]({
			type: this.CONSTANTS.NAVIGATION_TYPES.RECORD_PAGE, attributes: {
				recordId: this._item.documentId, actionName: this.CONSTANTS.NAVIGATION_ACTIONS.VIEW,
			},
		});
	}

	previewImageClick(event) {
		this.navigateToFilePreviewPage();
	}

	previewImageTitleClick(event) {
		this.navigateToFileRecordPage();
	}

	handleFileDelete(event) {
		this.dispatchEvent(new CustomEvent(CONSTANTS.CUSTOM_DOM_EVENT_TYPES.ITEM_ACTION, {
			detail: CONSTANTS.ACTION_TYPES.DELETE_FILE,
		}),);
	}
}