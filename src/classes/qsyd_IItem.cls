/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


 /**
    @author         Paul Lucas
    @company        Salesforce
    @description    qsyd_IItem
    @date           26-Apr-2020

    TODO:
 */
public interface qsyd_IItem {
    /**
     * @description Returns the subclass for this item.
     *
     * @return Either "qsyd_File" or "qsyd_Folder"
     */
    String getSubClass();

    /**
     * @description Returns the folder id for this item.
     *
     * @return The folder id
     */
    String getFolder();

    /**
     * @description Returns true if this item is a file.
     *
     * @return True if instance is a file, otherwise return false
     */
    Boolean isFile();

    /**
     * @description Populates an instance of qsyd_File
     *
     * @param item
     *
     * @return A concrete qsyd_IItem instance
     */
    qsyd_IItem load(qsyd_Item item);

    /**
     * @description Converts from system to business object
     *
     * @return A concrete qsyd_IItem instance
     */
    qsyd_IItem convertToCanonical();

    /**
     * @description Save records
     *
     * @return A concrete qsyd_IItem instance
     */
    qsyd_IItem save();

    /**
     * @description Deletes records and perform any referential clean up
     *
     * @return A concrete qsyd_IItem instance
     */
    qsyd_IItem remove();
}