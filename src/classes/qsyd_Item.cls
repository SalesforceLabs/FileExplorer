/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


/**
    @author         Paul Lucas
    @company        Salesforce
    @description    qsyd_Item
    @date           26-Apr-2020

    History:
    When           Who                 What

    TODO:
*/

global virtual class qsyd_Item {
    protected SObjectAccessDecision accessDecision;

    /**
     * @description File or folder id
     */
    @AuraEnabled
    global String id { get; set; }

    /**
     * @description File or folder text label
     */
    @AuraEnabled
    global String text { get; set; }

    /**
     * @description Parent folder
     */
    @AuraEnabled
    global String folder { get; set; }

    /**
     * @description List of child items
     */
    @AuraEnabled
    global List<qsyd_Item> children { get; set; }

    /**
     * @description Salesforce document id
     */
    @AuraEnabled
    global String documentId { get; set; }

    /**
     * @description Salesforce linked entity id
     */
    @AuraEnabled
    global String entityId { get; set; }

    /**
     * @description File type
     */
    @AuraEnabled
    global String type { get; set; }

    /**
     * @description File extension
     */
    @AuraEnabled
    global String ext { get; set; }

    /**
     * @description Salesforce owner user id
     */
    @AuraEnabled
    global String owner { get; set; }

    /**
     * @description Descriptor tags
     */
    @AuraEnabled
    global String tags { get; set; }

    /**
     * @description File size
     */
    @AuraEnabled
    global Decimal size { get; set; }

    /**
     * @description File icon
     */
    @AuraEnabled
    global String icon { get; set; }

    /**
     * @description Constructor
     */
    global qsyd_Item() {
    }

    /**
     * @description Constructor
     *
     * @param id
     * @param folder
     * @param label
     * @param entityId
     */
    global qsyd_Item(String id, String folder, String label, String entityId) {
        this(id, folder, label, entityId, null);
    }

    /**
     * @description Constructor
     *
     * @param id
     * @param folder
     * @param label
     * @param entityId
     * @param children
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
     * @description Returns true if this item is a file
     *
     * @return True if this item is a file, otherwise return false
     */
    global Boolean isFile() {
        return !String.isBlank(this.documentId);
    }

    /**
     * @description Returns the subclass for this item
     *
     * @return Either "qsyd_File" or "qsyd_Folder"
     */
    global String getSubClass() {
        return this.isFile() ? qsyd_File.class.getName() : qsyd_Folder.class.getName();
    }

    /**
     * @description Returns the folder id for this item
     *
     * @return A folder id
     */
    global Id getFolder() {
        return this.folder;
    }

    /**
     * @description Adds a child item.
     *
     * @param item The item to add
     */
    public void addItem(Object item) {
        if (item != null) {
            this.children.add((qsyd_Item) item);
        }
    }

    /**
     * @description Object security checks
     *
     * @param objectType
     * @param checkType
     *
     * @return True if action is allowed, otherwise return false
     */
    global static Boolean checkObjectSecurity(DescribeSObjectResult objectType, String checkType) {
        Boolean ret = false;
        checkType = checkType?.toLowerCase();

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