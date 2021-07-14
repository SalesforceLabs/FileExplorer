/*******************************************************************************
 Author:         Q Branch - Sydney
 Company:        Salesforce
 Description:    Common JS library.
 Date:           10-Apr-2020

 TODO:
    - https://salesforce.stackexchange.com/questions/180007/examples-of-use-of-getvalueprovider?rq=1
    - CSS Ripple - https://codepen.io/pikey/pen/mvzPON

 ********************************************************************************/
(function(qJS) {
	qJS.debug = true;

	qJS.const = (function() {

		// Public API
		return {

			// Constants
			TOAST_DURATION: 30000,
			MESSAGE_BOX_TIMEOUT: 5000,
			MINIMUM_SEARCH_CHARACTERS: 3,
			DEBOUNCE_DELAY: 250,

			// Enumerations
			FORCE_EVENTS: {
				'CLOSE_QUICK_ACTION': 'e.force:closeQuickAction',
				'CREATE_RECORD': 'e.force:createRecord',
				'EDIT_RECORD': 'e.force:editRecord',
				'NAVIGATE_TO_COMPONENT': 'e.force:navigateToComponent',
				'NAVIGATE_TO_LIST': 'e.force:navigateToList',
				'NAVIGATE_TO_OBJECT_HOME': 'e.force:navigateToObjectHome',
				'NAVIGATE_TO_RELATED_LIST': 'e.force:navigateToRelatedList',
				'NAVIGATE_TO_SOBJECT': 'e.force:navigateToSObject',
				'NAVIGATE_TO_URL': 'e.force:navigateToURL',
				'RECORD_SAVE': 'e.force:recordSave',
				'RECORD_SAVE_SUCCESS': 'e.force:recordSaveSuccess',
				'REFRESH_VIEW': 'e.force:refreshView',
				'SHOW_TOAST': 'e.force:showToast',
			},

			LIGHTNING_EVENTS: {
				'OPEN_FILES': 'e.lightning:openFiles',
			},

			ALERT_MESSAGE_TYPES: {
				'ALERT': 'alert',
				'CONFIRM': 'confirm',
				'ERROR': 'error',
				'SUCCESS': 'success',
				'TICKER': 'ticker',
				'TOAST': 'toast',
				'WARNING': 'warning',
			},

			TOAST_MESSAGE_TYPES: {
				'ALERT': 'alert',
				'CONFIRM': 'confirm',
				'ERROR': 'error',
				'SUCCESS': 'success',
				'TICKER': 'ticker',
				'TOAST': 'toast',
				'WARNING': 'warning',
				'FAILURE': 'Failure',
			},

			ACTION_RESPONSE_STATES: {
				'ERROR': 'error',
				'SUCCESS': 'success',
				'WARNING': 'warning',
				'INFORMATION': 'information',
				'INCOMPLETE': 'incomplete',
			},

			TOAST_THEMES: {
				'DEFAULT': 'default',
				'SUCCESS': 'success',
				'ERROR': 'error',
				'WARNING': 'warning',
				'INFORMATION': 'info',
				'OFFLINE': 'offline',
			},

			URL_ACTIONS: {
				'PRIMARY_TAB': 'primary_tab',
				'SUB_TAB': 'sub_tab',
				'NEW_WINDOW': 'new_window',
				'MODAL': 'modal',
			},

			PROMPT_RESPONSE: {
				'YES': 'Yes',
				'NO': 'No',
			},
		};
	})();

	/**
	 *  Utility functions
	 */
	qJS.util = (function() {

		// Public API
		return {

			/**
			 * http://guid.us/GUID/JavaScript
			 *
			 * @returns {string}
			 */
			s4: function() {
				return (((1 + Math.random()) * 0x10000) | 0).toString(16).
					substring(1);
			},

			/**
			 * newId
			 *
			 * @returns {string}
			 */
			newId: function() {
				return ($qJS.util.s4() + $qJS.util.s4() + '-' + $qJS.util.s4() +
					'-4' + $qJS.util.s4().substr(0, 3) + '-' + $qJS.util.s4() +
					'-' + $qJS.util.s4() + $qJS.util.s4() +
					$qJS.util.s4()).toLowerCase();
			},

			/**
			 * https://github.com/ai/nanoid
			 *
			 * @param t
			 * @returns {string}
			 */
			nanoid: function(t = 21) {
				let e = '', r = crypto.getRandomValues(new Uint8Array(t));
				for (; t--;) {
					let n = 63 & r[t];
					e += n < 36 ? n.toString(36) : n < 62 ? (n - 26).toString(
						36).toUpperCase() : n < 63 ? '_' : '-';
				}
				return e;
			},
			
			/**
			 * parse
			 *
			 * @returns {string}
			 */
			parse: function(proxy) {
				return (proxy) ? JSON.parse(JSON.stringify(proxy)) : '';
			},

			/**
			 * getProp: Runtime safe property retrieval
			 *
			 * @returns {string}
			 */
			getProp: function(fn, defaultValue) {
				try {
					return fn();
				} catch (e) {
					return defaultValue;
				}
			},

			/**
			 * log
			 * @returns {string}
			 */
			log: function(component, obj) {

				if (!$qJS.debug) {
					return;
				}

				const JRc = 'at J.Rc';
				const reducer = (accumulator, currentValue) => {
					if (currentValue) {
						return accumulator + ' => ' + currentValue.slice(3);
					}
				};

				let stack = $qJS.util.callStack(2), // Remove last 2 function calls
					breadcrumb,
					c = component || $qJS.context.component,
					componentName = (c && c.getName)
						? c.getName()
						: '** Please pass component context as the first argument **';

				// Trim trailing stack
				stack.splice(stack.indexOf(JRc));

				// Log out message with interested call stack
				breadcrumb = componentName + ' => ' +
					stack.reverse().reduce(reducer, '').slice(3);

				if (typeof (obj) === 'string' || obj instanceof String) {
					console.log(breadcrumb + ' ==> ' + obj);
				} else {
					console.log(breadcrumb);

					// Attempt to unlockerify
					if (obj) {
						try {
							console.log($qJS.util.parse(obj));
						} catch (e) {
							console.log(obj);
						}
					}
				}
			},

			/**
			 * callStack
			 *
			 * @returns {RegExpMatchArray}
			 */
			callStack: function(splice) {
				// const caller = (new Error()).stack.match(/at (\S+)/g)[1].slice(3);
				const stack = (new Error()).stack.match(/at (\S+)/g);

				splice = (splice) ? splice : 0;
				stack.splice(0, splice);

				return stack;
			},

			/**
			 * forEachIn
			 *
			 * @param obj
			 * @param fn
			 */
			forEachIn: function(obj, fn) {
				let index = 0;

				for (let key in obj) {
					if (obj.hasOwnProperty(key)) {
						fn(obj[key], key, index++);
					}
				}
			},

			/**
			 * extend
			 */
			extend: function() {
				const result = {};

				for (let i = 0; i < arguments.length; i++) {
					$qJS.util.forEachIn(arguments[i],
						function(obj, key) {
							result[key] = obj;
						});
				}
				return result;
			},

			/**
			 * arrayRemoveElement: Remove an element from an array, returning a new array
			 *
			 * @param arr
			 * @param value
			 * @returns {*}
			 */
			arrayRemoveElement: function(arr, value) {

				return arr.filter(function(element) {
					return element !== value;
				});

			},

			/**
			 * timeZoneDesignator: Return the time zone designator for the client time zone offset
			 *
			 * @returns {*}
			 */
			timezoneDesignator: function() {

				const timezoneOffset = new Date().getTimezoneOffset(),
					absoluteOffset = Math.abs(timezoneOffset);

				// Return the time zone designator
				return (absoluteOffset < 0 ? '-' : '+') +
					('00' + Math.floor(absoluteOffset / 60)).slice(-2) + ':' +
					('00' + (absoluteOffset % 60)).slice(-2);
			},

			/**
			 * Post a message
			 */
			// postMessage: function (targetWindow, messageType, message) {
			//
			//     window.opener.postMessage("{'refresh': 'xxx'}", window.location.origin);
			//
			//     if (url && url.trim().length > 0) {
			//         window.opener.location.replace(url);
			//     }
			//     else {
			//         window.opener.location.reload();
			//     }
			// }
		};
	})();

})
(window.$qJS || (window.$qJS = {}));