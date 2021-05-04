/**
 Author:         Paul Lucas
 Company:        Salesforce
 Description:    LightningConfettiCmpController.js
 Date:           06-Sep-2019

 History:
 When           Who                 What

 TODO:

 */
({
	/**
	 * handleAfterScriptsLoaded
	 *
	 * @param component
	 * @param event
	 * @param helper
	 */
	handleAfterScriptsLoaded: function (component, event, helper) {
		helper.addListeners(component, event, helper);
		helper.celebrate(component, event, helper);
	},

	/**
	 * handleInit
	 *
	 * @param component
	 * @param event
	 * @param helper
	 */
	handleInit: function (component, event, helper) {
	},

	/**
	 * handleCelebration
	 *
	 * @param component
	 * @param event
	 * @param helper
	 */
	handleCelebration: function (component, event, helper) {
		helper.bindEffects(component, event, helper);
		helper.celebrate(component, event, helper);
	},
})