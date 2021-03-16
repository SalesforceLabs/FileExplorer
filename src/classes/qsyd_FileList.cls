/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


 /**
    @author         Paul Lucas
    @company        Salesforce
    @description    qsyd_FileList
    @date           20-Apr-2020
        
    TODO:
 */

global inherited sharing class qsyd_FileList implements qsyd_IItemList {

    private Map<Id, qsyd_FE__FileExplorerFile__c> fileExplorerFilesMap;
    private List<qsyd_Item> files;

    /**
     * @description Constructor
     */
    global qsyd_FileList() {
        this.fileExplorerFilesMap = new Map<Id, qsyd_FE__FileExplorerFile__c>();
        this.files = new List<qsyd_File>();
    }

    /**
     * @description Constructor
     *
     * @param items
     */
    global qsyd_FileList(List<qsyd_Item> items) {
        this.fileExplorerFilesMap = new Map<Id, qsyd_FE__FileExplorerFile__c>();
        this.files = items;
    }

    /**
     * @description Populate a list of qsyd_Item
     *
     * @param items
     *
     * @return A qsyd_FileList
     */
    global qsyd_FileList load(List<qsyd_Item> items) {
        this.files = items;
        return this;
    }

    /**
     * @description Retrieve file explorer file records
     *
     * @param recordId
     *
     * @return A qsyd_FileList
     */
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

    /**
     * @description Converts from file explorer files to a list of qsyd_Files
     *
     * @return A qsyd_FileList
     */
    global qsyd_FileList convertToLogical() {

        for (qsyd_FE__FileExplorerFile__c f : this.fileExplorerFilesMap.values()) {
            this.files.add(new qsyd_File(f.Id, f.qsyd_FE__Folder__c, f.qsyd_FE__Label__c, f.qsyd_FE__ContentDocumentId__c, f.qsyd_FE__LinkedEntityId__c, f.qsyd_FE__FileType__c, f.qsyd_FE__FileExtension__c, f.qsyd_FE__FileOwner__r.Name, f.qsyd_FE__Tags__c, f.qsyd_FE__ContentSize__c, null));
        }

        return this;
    }

    /**
     * @description Converts from qsyd_Item to file explorer files
     *
     * @return A qsyd_FileList
     */
    global qsyd_FileList convertToCanonical() {
        for (qsyd_Item f : this.files) {
            this.fileExplorerFilesMap.put(f.id, new qsyd_FE__FileExplorerFile__c(Id = f.id, qsyd_FE__Folder__c = f.folder));
        }
        return this;
    }

    /**
     * @description Get a list of qsyd_Items
     *
     * @return A list of qsyd_Items
     */
    global List<qsyd_Item> getLogicalList() {
        return this.files;
    }

    /**
     * @description Get a list of file explorer files
     *
     * @return A list of file explorer files
     */
    global List<qsyd_FE__FileExplorerFile__c> getCanonicalList() {
        return this.fileExplorerFilesMap.values();
    }
}