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

    private Map<Id, qsyd_FE__FileExplorerFile__c> fileExplorerFilesMap;
    private List<qsyd_Item> files;

    global qsyd_FileList() {
        this.fileExplorerFilesMap = new Map<Id, qsyd_FE__FileExplorerFile__c>();
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

        this.fileExplorerFilesMap = new Map<Id, qsyd_FE__FileExplorerFile__c>([
                SELECT qsyd_FE__Folder__c,
                        qsyd_FE__Label__c,
                        qsyd_FE__ContentDocumentId__c,
                        qsyd_FE__LinkedEntityId__c,
                        qsyd_FE__FileType__c,
                        qsyd_FE__FileExtension__c,
                        qsyd_FE__FileOwner__c,
                        qsyd_FE__FileOwner__r.Name,
                        qsyd_FE__Tags__c,
                        qsyd_FE__ContentSize__c
                FROM qsyd_FE__FileExplorerFile__c
                WHERE qsyd_FE__LinkedEntityId__c = :recordId
                WITH SECURITY_ENFORCED
                ORDER BY qsyd_FE__Label__c
        ]);

        this.fileExplorerFilesMap.putAll((List<qsyd_FE__FileExplorerFile__c>) Security.stripInaccessible(AccessType.READABLE, this.fileExplorerFilesMap.values()).getRecords());

        return this;
    }

    global qsyd_FileList convertToLogical() {

        for (qsyd_FE__FileExplorerFile__c f : this.fileExplorerFilesMap.values()) {
            this.files.add(new qsyd_File(f.Id, f.qsyd_FE__Folder__c, f.qsyd_FE__Label__c, f.qsyd_FE__ContentDocumentId__c, f.qsyd_FE__LinkedEntityId__c, f.qsyd_FE__FileType__c, f.qsyd_FE__FileExtension__c, f.qsyd_FE__FileOwner__r.Name, f.qsyd_FE__Tags__c, f.qsyd_FE__ContentSize__c, null));
        }

        return this;
    }

    global qsyd_FileList convertToCanonical() {
        for (qsyd_Item f : this.files) {
            this.fileExplorerFilesMap.put(f.id, new qsyd_FE__FileExplorerFile__c(Id = f.id, qsyd_FE__Folder__c = f.folder));
        }
        return this;
    }

    global List<qsyd_Item> getLogicalList() {
        return this.files;
    }

    global List<qsyd_FE__FileExplorerFile__c> getCanonicalList() {
        return this.fileExplorerFilesMap.values();
    }
}