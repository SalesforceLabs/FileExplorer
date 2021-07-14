/**
     Author:         Paul Lucas
     Company:        Salesforce
     Description:    qsydMessagePanel
     Date:           05-Aug-2020
    
     TODO:

 */

import {LightningElement, track, api, wire} from 'lwc';
import {reduceErrors} from 'c/qsydFileExplorerCommon';

import errorIllustration from './templates/error.html';
import setupIllustration from './templates/setup.html';
import noDataIllustration from './templates/noData.html';
import unavailableIllustration from './templates/unavailable.html';
import noAccessIllustration from './templates/noAccess.html';
import previewIllustration from './templates/preview.html';
import inline from './templates/inline.html';

const MESSAGE_TEMPLATES = {
	inline: inline,
	error: errorIllustration,
	no_data: noDataIllustration,
	no_access: noAccessIllustration,
	unavailable: unavailableIllustration,
	setup: setupIllustration,
	preview: previewIllustration,
};

export default class QSydMessagePanel extends LightningElement {

	/**
	 * Internal properties
	 */
	_prop;

	/**
	 * Private properties
	 */
	viewDetails = false;

	/**
	 * Public properties
	 */
	@api recordId;
	@api objectApiName;
	@api errors;
	@api message = 'Error retrieving data';
	@api type = 'no_data';

	@api
	get errorMessages() {
		return reduceErrors(this.errors);
	}

	/**
	 * constructor: Called when the component is created. This hook flows from parent to child. You can’t access child
	 * elements in the component body because they don’t exist yet. Properties are not passed yet, either. Properties
	 * are assigned to the component after construction and before the connectedCallback() hook.
	 * You can access the host element with this.template.
	 */
	constructor() {
		super();
	}

	/**
	 * connectedCallBack: Called when the element is inserted into a document. This hook flows from parent to child.
	 * You can’t access child elements in the component body because they don’t exist yet.
	 * You can access the host element with this.template.
	 */
	connectedCallback() {
	}

	/**
	 * disconnectedCallback: Called when the element is removed from a document. This hook flows from parent to child.
	 */
	disconnectedCallback() {
	}

	/**
	 * render: For complex tasks like conditionally rendering a template or importing a custom one, use render()
	 * to override standard rendering functionality. This function gets invoked after connectedCallback() and must
	 * return a valid HTML template.
	 */

	render() {
		return MESSAGE_TEMPLATES[this.type] ? MESSAGE_TEMPLATES[this.type] : MESSAGE_TEMPLATES.no_data;
	}

	/**
	 * renderedCallback: Called after every render of the component. This lifecycle hook is specific to
	 * Lightning Web Components, it isn’t from the HTML custom elements specification. This hook flows from child to parent.
	 */
	renderedCallback() {
	}

	/**
	 * errorCallback: Called when a descendant component throws an error in one of its lifecycle hooks.
	 * The error argument is a JavaScript native error object, and the stack argument is a string.
	 * This lifecycle hook is specific to Lightning Web Components, it isn’t from the HTML custom elements specification.
	 *
	 * @param error
	 * @param stack
	 */
	errorCallback(error, stack) {
	}

	handleShowDetailsClick() {
		this.viewDetails = !this.viewDetails;
	}
}