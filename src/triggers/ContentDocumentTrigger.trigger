/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    ContentDocumentTrigger
    Date:           13-Apr-2020
    
    History:
    When           Who                 What
    
    TODO:
 */

trigger ContentDocumentTrigger on ContentDocument (after update, after delete) {

    new qsyd_ContentDocumentTriggerHandler().run();
}