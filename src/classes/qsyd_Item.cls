/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_Item
    Date:           20-Apr-2020

    History:
    When           Who                 What

    TODO:
 */

global abstract class qsyd_Item implements qsyd_IItem {
    protected SObjectAccessDecision accessDecision;

    @AuraEnabled
    global String id { get; set; }

    @AuraEnabled
    global String text { get; set; }

    @AuraEnabled
    global String folder { get; set; }

    @AuraEnabled
    global List<qsyd_Item> children { get; set; }

    @AuraEnabled
    global String documentId { get; set; }

    @AuraEnabled
    global String entityId { get; set; }

    @AuraEnabled
    global String type { get; set; }

    @AuraEnabled
    global String ext { get; set; }

    @AuraEnabled
    global String owner { get; set; }

    @AuraEnabled
    global String tags { get; set; }

    @AuraEnabled
    global Decimal size { get; set; }

    @AuraEnabled
    global String icon { get; set; }

    /**
     * Default constructor.
     *
     */
    global qsyd_Item() {
    }

    /**
     * Constructor.
     *
     */
    global qsyd_Item(String id, String folder, String label, String entityId) {
        this(id, folder, label, entityId, null);
    }

    /**
     * Constructor.
     *
     */
    global qsyd_Item(Id id, Id folder, String label, String entityId, List<qsyd_Item> children) {
        this.id = id;
        this.text = label;
        this.folder = folder;
        this.entityId = entityId;

        if (children != null && children.size() > 0) {
            this.children = children;
        } else {
            this.children = new List<qsyd_Item>();
        }
    }

    /**
     * Returns true if this item is a file.
     *
     */
    global Boolean isFile() {
        return !String.isBlank(this.documentId);
    }

    /**
     * Returns the subclass for this item.
     *
     */
    global String getSubClass() {
        return this.isFile() ? qsyd_File.class.getName() : qsyd_Folder.class.getName();
    }

    /**
     * Returns the folder id for this item.
     *
     */
    global Id getFolder() {
        return this.folder;
    }

    /**
     * Adds a child item.
     *
     * @param item: The item to add
     *
     */
    public void addItem(Object item) {
        if (item != null) {
            this.children.add((qsyd_Item) item);
        }
    }

    /**
     *
    */
    global static boolean checkObjectSecurity(DescribeSObjectResult objectType, string checkType) {
        boolean ret = false;

        if (checkType == 'create') {
            ret = objectType.isCreateable();
        } else if (checkType == 'delete') {
            ret = objectType.isDeletable();
        } else if (checkType == 'update') {
            ret = objectType.isUpdateable();
        }
        return ret;
    }
}