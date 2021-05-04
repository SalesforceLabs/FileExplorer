/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


 /**
    @author         Paul Lucas
    @company        Salesforce
    @description    qsyd_ItemList
    @date           26-Apr-2020
        
    TODO:
        - Deprecate, no longer required

 */

global class qsyd_ItemList {

    global static final String SUFFIX = 'List';

    global qsyd_ItemList() {
    }

    /**
     * @description Returns an qsyd_ItemList
     *
     * @param className The class to instantiate
     *
     * @return A concrete qsyd_IItemList instance
     */
    public qsyd_IItemList newItemList(String className) {
        Type itemListType = Type.forName(className);
        if (itemListType == null) {
            return null;
        }

        return (qsyd_IItemList) itemListType.newInstance();
    }
}