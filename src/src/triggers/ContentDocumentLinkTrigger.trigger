/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    ContentDocumentLinkTrigger
    Date:           21-Apr-2020
    
    History:
    When           Who                 What
    
    TODO:
 */

trigger ContentDocumentLinkTrigger on ContentDocumentLink (after undelete) {

    /*System.debug('ContentDocumentLinkTrigger '.center(80));
    System.debug('---------------------------'.center(80));

    System.debug('>>>>> Trigger.operationType: ' + Trigger.operationType);
    System.debug('>>>>> Trigger.isAfter: ' + Trigger.isAfter);
    System.debug('>>>>> Trigger.isBefore: ' + Trigger.isBefore);

    System.debug('>>>>> ContentDocumentLinkTrigger.new list: ');
    System.debug(Trigger.new);

    System.debug('>>>>> ContentDocumentLinkTrigger.new keys');
    System.debug(Trigger.newMap.keySet());*/


//    ContentDocument cd = [
//            SELECT Title
//            FROM ContentDocument
//            WHERE ContentDocumentId IN :Trigger.newMap.keySet()
//    ];
//
//    System.debug('>>>>> ContentDocument: ');
//
//    System.debug(cd);

}