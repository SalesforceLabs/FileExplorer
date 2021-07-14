/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_IItem
    Date:           20-Apr-2020

    TODO:
 */

public interface qsyd_IItem {
    String getSubClass();
    String getFolder();
    Boolean isFile();
    qsyd_IItem load(qsyd_Item item);
    qsyd_IItem convertToCanonical();
    qsyd_IItem save();
    qsyd_IItem remove();
}