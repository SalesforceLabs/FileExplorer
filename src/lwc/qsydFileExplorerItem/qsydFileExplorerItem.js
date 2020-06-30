import {LightningElement, api} from 'lwc';
import {item} from 'c/qsydFileExplorerCommon';
import formFactor from '@salesforce/client/formFactor';
import {NavigationMixin} from 'lightning/navigation';

export default class QsydFileExplorerItem extends NavigationMixin(
	LightningElement) {
	@api item;
	@api selectedItemId;
	@api type;

	get itemClass() {
		return 'itemContainer ' +
			(this.item.id == this.selectedItemId ? 'itemSelected' : '');
	}

	handleClick(e) {
		this.dispatchEvent(
			new CustomEvent('itemclick', {
				detail: this.item,
			}),
		);

		if (formFactor != 'Large' && this.item.documentId) {
			// this.navigateToFilePreviewPage();
		}
	}

	get itemIcon() {
		if (this.type == 'folder') {
			return 'doctype:folder';
		} else {
			let fileType = this.item.type.toLowerCase();

			switch (fileType) {
				case 'jpg':
					return 'doctype:image';
				case 'jpeg':
					return 'doctype:image';
				case 'png':
					return 'doctype:image';
				case 'gif':
					return 'doctype:image';
				case 'csv':
					return 'doctype:csv';
				case 'excel_x':
					return 'doctype:excel';
				case 'xls':
					return 'doctype:excel';
				case 'word_x':
					return 'doctype:gdoc';
				case 'doc':
					return 'doctype:gdoc';
				case 'docx':
					return 'doctype:gdoc';
				case 'pdf':
					return 'doctype:pdf';
				case 'power_point_x':
					return 'doctype:ppt';
				case 'ppt':
					return 'doctype:ppt';
				case 'pptx':
					return 'doctype:ppt';
				case 'xml':
					return 'doctype:xml';
				case 'txt':
					return 'doctype:txt';
				case 'js':
					return 'doctype:html';
				case 'css':
					return 'doctype:html';
				case 'html':
					return 'doctype:html';
				case 'php':
					return 'doctype:html';
				case 'zip':
					return 'doctype:zip';
				case 'rar':
					return 'doctype:zip';
				case '7zip':
					return 'doctype:zip';
				default:
					return 'doctype:unknown';
			}
			// return 'doctype:unknown';
		}
	}
}