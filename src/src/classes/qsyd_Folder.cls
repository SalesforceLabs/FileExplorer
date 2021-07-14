/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_Folder
    Date:           21-Apr-2020

    History:
    When           Who                 What

    TODO:
 */

global virtual inherited sharing class qsyd_Folder extends qsyd_Item {
    public static final String FOLDERS_KEY = 'folders';

    private qsyd_FE__FileExplorerFolder__c fileExplorerFolder;

    global qsyd_Folder() {
    }

    global qsyd_Folder(Id id, String folder, String label, String entityId) {
        super(id, folder, label, entityId);
    }

    global qsyd_Folder(Id id, String folder, String label, String entityId, List<qsyd_Item> items) {
        super(id, folder, label, entityId, items);
    }

    global qsyd_Folder load(qsyd_Item item) {
        this.id = item.id;
        this.text = item.text;
        this.folder = item.folder;
        this.entityId = item.entityId;

        return this;
    }

    global qsyd_Folder convertToCanonical() {
        this.fileExplorerFolder = new qsyd_FE__FileExplorerFolder__c(Id = this.id, qsyd_FE__Label__c = this.text, qsyd_FE__Folder__c = this.folder, qsyd_FE__LinkedEntityId__c = this.entityId);

        return this;
    }

    global qsyd_Folder save() {

        this.fileExplorerFolder = (qsyd_FE__FileExplorerFolder__c) Security.stripInaccessible(AccessType.UPSERTABLE,
                new List<qsyd_FE__FileExplorerFolder__c>{
                        fileExplorerFolder
                }).getRecords()[0];

        try {
            UPSERT this.fileExplorerFolder;
            this.id = this.fileExplorerFolder.Id;

        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        return this;
    }

    global qsyd_Folder remove() {
        List<qsyd_FE__FileExplorerFolder__c> childFolders;
        List<qsyd_FE__FileExplorerFile__c> childFiles;

        childFolders = [
                SELECT qsyd_FE__Folder__c
                FROM qsyd_FE__FileExplorerFolder__c
                WHERE qsyd_FE__LinkedEntityId__c = :this.entityId
                AND qsyd_FE__Folder__c = :this.id
                AND Id != :this.id
                WITH SECURITY_ENFORCED
        ];

        childFolders = (List<qsyd_FE__FileExplorerFolder__c>) Security.stripInaccessible(AccessType.READABLE, childFolders).getRecords();

        for (qsyd_FE__FileExplorerFolder__c f : childFolders) {
            f.qsyd_FE__Folder__c = this.folder;
        }

        childFiles = [
                SELECT qsyd_FE__Folder__c
                FROM qsyd_FE__FileExplorerFile__c
                WHERE qsyd_FE__LinkedEntityId__c = :this.entityId
                AND qsyd_FE__Folder__c = :this.id
                WITH SECURITY_ENFORCED
        ];

        childFiles = (List<qsyd_FE__FileExplorerFile__c>) Security.stripInaccessible(AccessType.READABLE, childFiles).getRecords();

        for (qsyd_FE__FileExplorerFile__c f : childFiles) {
            f.qsyd_FE__Folder__c = this.folder;
        }

        Savepoint sp = Database.setSavepoint();

        try {
            if (qsyd_Item.checkObjectSecurity(qsyd_FE__FileExplorerFolder__c.SObjectType.getDescribe(), 'delete')) {
                UPDATE Security.stripInaccessible(AccessType.UPDATABLE, childFolders).getRecords();
                UPDATE Security.stripInaccessible(AccessType.UPDATABLE, childFiles).getRecords();
                DELETE this.fileExplorerFolder;
            }
        } catch (Exception e) {
            if (sp != null) {
                Database.rollback(sp);
            }
            System.debug(Logginglevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        return this;
    }
}