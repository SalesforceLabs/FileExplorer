/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_ItemFactory
    Date:           24-Apr-2020
        
    TODO:
 */

global class qsyd_ItemFactory {

    global qsyd_ItemFactory() {
    }

    /**
     * Returns an instance of an item
     *
     * @param className: The class to instantiate
     *
    */
    public qsyd_IItem newInstance(String className) {
        Type itemType = Type.forName(className);
        if (itemType == null) {
            return null;
        }

        return (qsyd_IItem) itemType.newInstance();
    }
}