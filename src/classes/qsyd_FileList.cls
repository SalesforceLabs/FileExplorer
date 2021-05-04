/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_FileList
    Date:           26-Apr-2020
        
    TODO:
 */

global inherited sharing class qsyd_FileList implements qsyd_IItemList {

    private Map<Id, FileExplorerFile__c> fileExplorerFilesMap;
    private List<qsyd_Item> files;

    global qsyd_FileList() {
        this.fileExplorerFilesMap = new Map<Id, FileExplorerFile__c>();
        this.files = new List<qsyd_File>();
    }

    global qsyd_FileList(List<qsyd_Item> items) {
        this.files = items;
    }

    global qsyd_FileList load(List<qsyd_Item> items) {
        this.files = items;
        return this;
    }

    global qsyd_FileList retrieve(String recordId) {

        this.fileExplorerFilesMap = new Map<Id, FileExplorerFile__c>([
                SELECT Folder__c,
                        Label__c,
                        ContentDocumentId__c,
                        LinkedEntityId__c,
                        FileType__c,
                        FileExtension__c,
                        FileOwner__c,
                        FileOwner__r.Name,
                        Tags__c,
                        ContentSize__c
                FROM FileExplorerFile__c
                WHERE LinkedEntityId__c = :recordId
                WITH SECURITY_ENFORCED
                ORDER BY Label__c
        ]);

        this.fileExplorerFilesMap.putAll((List<FileExplorerFile__c>) Security.stripInaccessible(AccessType.READABLE, this.fileExplorerFilesMap.values()).getRecords());

        return this;
    }

    global qsyd_FileList convertToLogical() {

        for (FileExplorerFile__c f : this.fileExplorerFilesMap.values()) {
            this.files.add(new qsyd_File(f.Id, f.Folder__c, f.Label__c, f.ContentDocumentId__c, f.LinkedEntityId__c, f.FileType__c, f.FileExtension__c, f.FileOwner__r.Name, f.Tags__c, f.ContentSize__c, null));
        }

        return this;
    }

    global qsyd_FileList convertToCanonical() {
        for (qsyd_Item f : this.files) {
            this.fileExplorerFilesMap.put(f.id, new FileExplorerFile__c(Id = f.id, Folder__c = f.folder));
        }
        return this;
    }

    global List<qsyd_Item> getLogicalList() {
        return this.files;
    }

    global List<FileExplorerFile__c> getCanonicalList() {
        return this.fileExplorerFilesMap.values();
    }
}