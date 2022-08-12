/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


/**
     @author        Paul Lucas
     @company       Salesforce
     @description   
     @date          19/9/21

     TODO:
 */

trigger UpdateContentDocumentLinkVisibilityOnInsert on ContentDocumentLink (before insert) {
    for (ContentDocumentLink cdl : Trigger.new) {
        cdl.ShareType = 'I';
        cdl.Visibility = 'AllUsers';
    }
}