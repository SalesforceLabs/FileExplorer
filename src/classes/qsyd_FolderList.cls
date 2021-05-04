/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_FolderList
    Date:           26-Apr-2020
        
    TODO:
 */

global inherited sharing class qsyd_FolderList implements qsyd_IItemList {

    private Map<Id, FileExplorerFolder__c> fileExplorerFoldersMap;
    private List<qsyd_Item> folders;

    global qsyd_FolderList() {
        this.fileExplorerFoldersMap = new Map<Id, FileExplorerFolder__c>();
        this.folders = new List<qsyd_Folder>();
    }

    global qsyd_FolderList(List<qsyd_Item> items) {
        this.folders = items;
    }

    global qsyd_FolderList load(List<qsyd_Item> items) {
        this.folders = items;

        return this;
    }

    global qsyd_FolderList retrieve(String recordId) {

        this.fileExplorerFoldersMap = new Map<Id, FileExplorerFolder__c>([
                SELECT Label__c,
                        Folder__c,
                        LinkedEntityId__c
                FROM FileExplorerFolder__c
                WHERE LinkedEntityId__c = :recordId
                WITH SECURITY_ENFORCED
                ORDER BY Label__c
        ]);

        this.fileExplorerFoldersMap.putAll((List<FileExplorerFolder__c>) Security.stripInaccessible(AccessType.READABLE, this.fileExplorerFoldersMap.values()).getRecords());

        return this;
    }

    global qsyd_FolderList convertToLogical() {

        for (FileExplorerFolder__c f : this.fileExplorerFoldersMap.values()) {
            this.folders.add(new qsyd_Folder(f.Id, f.Folder__c, f.Label__c, f.LinkedEntityId__c));
        }

        return this;
    }

    global qsyd_FolderList convertToCanonical() {

        for (qsyd_Item f : this.folders) {
            this.fileExplorerFoldersMap.put(f.id, new FileExplorerFolder__c(Id = f.id, Folder__c = f.folder, Label__c = f.text, LinkedEntityId__c = f.entityId));
        }

        return this;
    }

    global List<qsyd_Item> getLogicalList() {
        return this.folders;
    }

    global List<FileExplorerFolder__c> getCanonicalList() {
        return this.fileExplorerFoldersMap.values();
    }
}