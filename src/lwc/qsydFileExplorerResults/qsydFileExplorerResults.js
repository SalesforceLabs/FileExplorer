/* 
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**
 * @File Name          : qsydFileExplorerResults.js
 * @Description        :
 * @Author             : Paul Lucas, Jiun Ryu, Elly Zhu, Derrick Vuong
 **/
import {LightningElement, api} from 'lwc';

export default class QsydFileExplorerResults extends LightningElement {
	@api recordId;
	@api selectedItem;
	@api results;
	@api breadcrumbs;

	constructor() {
		super();
	}

	connectedCallback() {
	}

	renderedCallback() {
	}

	// #### CONTENT GETTERS
	get contentsRequested() {
		return this.results && this.results.type == 'Contents';
	}

	get selectedItemId() {
		return this.selectedItem ? this.selectedItem.id : null;
	}

	get folderId() {
		if (this.selectedItem) {
			return this.selectedItem.documentId
				? this.selectedItem.folder
				: this.selectedItem.id;
		}
		return null;
	}

	// #### SEARCH GETTERS
	get activeSections() {return ['Files', 'Folders', 'Tags']; }

	get searchRequested() {
		return this.results && this.results.type == 'Search';
	}

	get filesAvailable() { return this.results.files.length > 0; }

	get foldersAvailable() { return this.results.folders.length > 0; }

	get tagsAvailable() { return this.results.tags.length > 0; }

	get filesLabel() { return 'Files (' + this.results.files.length + ')'; }

	get foldersLabel() {
		return 'Folders (' + this.results.folders.length + ')';
	}

	get tagsLabel() { return 'Tagged (' + this.results.tags.length + ')'; }

	handleClick(e) {
		const selectedItem = e.detail;
		this.dispatchEvent(
			new CustomEvent('itemclick', {
				detail: selectedItem,
			}),
		);
	}
}