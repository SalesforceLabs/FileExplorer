/**
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    ContentDocumentTrigger
    Date:           13-Apr-2020

    TODO:
 */

trigger ContentDocumentTrigger on ContentDocument (after update, after delete) {
    new qsyd_ContentDocumentTriggerHandler().run();
}