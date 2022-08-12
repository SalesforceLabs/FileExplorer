/**
 * @File Name          : qsydFileExplorerSearch.js
 * @Author             : Paul Lucas, Jiun Ryu, Elly Zhu, Derrick Vuong
 * @Last Modified By   : Derrick Vuong
 * @Last Modified On   : 4/30/2020, 4:14:27 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0       4/23/2020       PL, JR, EZ, DV         Initial Version
 **/
import {LightningElement, api} from 'lwc';
import {CONSTANTS} from 'c/qsydFileExplorerCommon';

export default class QsydFileExplorerSearch extends LightningElement {
	@api searchText;
	@api results;

	CONSTANTS = CONSTANTS;
	displayItems;
	fileType;
	isLoading = false;
	timeout;

	get searchRequested() {
		if (this.results) {
			if (!this.displayItems) {
				this.handleDisplayItems('files');
			}
			return true;
		} else {
			this.displayItems = null;
			return false;
		}
	}

	get filesLabel() { return this.results.files.length + ' ' + CONSTANTS.SEARCH_CATEGORY.FILES; }

	get foldersLabel() { return this.results.folders.length + ' ' + CONSTANTS.SEARCH_CATEGORY.FOLDERS; }

	get tagsLabel() { return this.results.tags.length + ' ' + CONSTANTS.SEARCH_CATEGORY.TAGGED; }

	get displayItemsAvailable() {
		return this.displayItems && this.displayItems.length > 0 ? true : false;
	}

	connectedCallback() {

	}

	renderedCallback() {

	}

	handleSearchKeyUp(e) {
		if (e.keyCode === 13) {
			this.handleSearchChange(e);
		}
	}

	handleSearchFocus(e) {
		let searchText = e.target.value;
		if (searchText && searchText != '' &&
			(!this.results || this.results.type == 'Contents')) {
			this.handleSearchChange(e);
		}
	}

	handleSearchChange(e) {
		let searchText = this.searchText = e.target.value;
		let searchTimeout = this.timeout;

		if (searchTimeout) {
			clearTimeout(searchTimeout);
		}

		if (searchText != '' && searchText != null) {
			this.isLoading = true;

			this.timeout = setTimeout(() => {
				this.displayItems = null; // Reset Results
				this.resetFilterItemFocus();

				this.dispatchEvent(
					new CustomEvent('searchrequest', {detail: searchText}),
				);

				this.isLoading = false;
				this.timeout = null;
			}, 250);
		} else {
			this.results = null;
			this.isLoading = false;
			this.dispatchEvent(
				new CustomEvent('searchrequest', {detail: null}),
			);
		}
	}

	handleFilterItemClick(e) {
		let target = e.currentTarget;
		let filterName = target.dataset.filterName;

		this.resetFilterItemFocus();
		target.classList.add('active-filter-item');
		this.handleDisplayItems(filterName);
	}

	handleClick(e) {
		this.dispatchEvent(
			new CustomEvent('itemclick', {
				detail: e.detail,
			}),
		);
	}

	// #### HELPER FUNCTIONS
	handleDisplayItems(filterName) {
		if (filterName == 'folders') {
			this.fileType = 'folder';
		} else if (filterName == 'tags') {
			this.fileType = 'tag';
		} else {
			this.fileType = 'file';
		}

		this.displayItems = this.results[filterName];
	}

	resetFilterItemFocus() {
		let filterItems = this.template.querySelectorAll(
			'li.active-filter-item');

		if (filterItems.length > 0) {
			filterItems.forEach(listItem => {
				listItem.classList.remove('active-filter-item');
			});
		}
	}
}