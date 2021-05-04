/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


/**
    @author         Paul Lucas
    @company        Salesforce
    @description    qsyd_IItemList
    @date           26-Apr-2020

    TODO:
*/

public interface qsyd_IItemList {
    /**
     * @description Populate a list of qsyd_Items
     *
     * @param items
     *
     * @return A concrete list of qsyd_IItems
     */
    qsyd_IItemList load(List<qsyd_Item> items);

    /**
     * @description Populate a list of qsyd_Items
     *
     * @return A list of qsyd_Items (system objects)
     */
    List<qsyd_Item> getLogicalList();

    /**
     * @description Return a list of SObjects
     *
     * @return A list of qsyd_Items (business objects)
     */
    List<SObject> getCanonicalList();

    /**
     * @description Converts from system to business objects
     *
     * @return A list of qsyd_IItems (business objects)
     */
    qsyd_IItemList convertToLogical();

    /**
     * @description Converts from business to system objects
     *
     * @return A list of qsyd_IItems (system objects)
     */
    qsyd_IItemList convertToCanonical();
}