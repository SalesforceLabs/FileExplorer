/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**
 * @File Name          : qsydFileExplorerSearch.js
 * @Description        :
 * @Author             : Paul Lucas, Jiun Ryu, Elly Zhu, Derrick Vuong
 **/
import {LightningElement, api} from 'lwc';

export default class QsydFileExplorerSearch extends LightningElement {
	@api searchText;
	@api results;

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

	get filesLabel() { return this.results.files.length + ' Files'; }

	get foldersLabel() { return this.results.folders.length + ' Folders'; }

	get tagsLabel() { return this.results.tags.length + ' Tagged'; }

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