/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_IItemList
    Date:           26-Apr-2020
        
    TODO:
 */

public interface qsyd_IItemList {
    qsyd_IItemList load(List<qsyd_Item> items);
    List<qsyd_Item> getLogicalList();
    List<sObject> getCanonicalList();
    qsyd_IItemList convertToLogical();
    qsyd_IItemList convertToCanonical();
}