/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
     Author:         Paul Lucas
     Company:        Salesforce
     Description:    qsydModal
     Date:           30-Apr-2020
    
     TODO:

 */

import {LightningElement, api} from 'lwc';

const CSS_CLASS = 'modal-hidden';

export default class Modal extends LightningElement {
	_header;

	hasHeaderString = false;
	showModal = false;

	@api
	set header(value) {
		this.hasHeaderString = value !== '';
		this._header = value;
	}

	get header() {
		return this._header;
	}

	@api show() {
		this.showModal = true;
	}

	@api hide() {
		this.showModal = false;
	}

	handleDialogClose() {
		this.dispatchEvent(new CustomEvent('modaldialogclose'));
		this.hide();
	}

	handleSlotTaglineChange() {
		const tagline = this.template.querySelector('p');

		if (tagline) {
			tagline.classList.remove(CSS_CLASS);
		}
	}

	handleSlotFooterChange() {
		const footer = this.template.querySelector('footer');

		if (footer) {
			footer.classList.remove(CSS_CLASS);
		}
	}
}