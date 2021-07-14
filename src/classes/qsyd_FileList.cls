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

    /**
     * Constructor
     */
    global qsyd_FileList() {
        this.fileExplorerFilesMap = new Map<Id, qsyd_FE__FileExplorerFile__c>();
        this.files = new List<qsyd_File>();
    }

    /**
     * Constructor
     *
     * @param items
     */
    global qsyd_FileList(List<qsyd_Item> items) {
        this.fileExplorerFilesMap = new Map<Id, qsyd_FE__FileExplorerFile__c>();
        this.files = items;
    }

    /**
     * Populate a list of qsyd_Item
     *
     * @param items
     *
     * @return a qsyd_FileList
     */
    global qsyd_FileList load(List<qsyd_Item> items) {
        this.files = items;
        return this;
    }

    /**
     * Retrieve file explorer file records
     *
     * @param recordId
     *
     * @return a qsyd_FileList
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
     * Converts from file explorer files to a list of qsyd_Files
     *
     * @return a qsyd_FileList
     */
    global qsyd_FileList convertToLogical() {

        for (qsyd_FE__FileExplorerFile__c f : this.fileExplorerFilesMap.values()) {
            this.files.add(new qsyd_File(f.Id, f.qsyd_FE__Folder__c, f.qsyd_FE__Label__c, f.qsyd_FE__ContentDocumentId__c, f.qsyd_FE__LinkedEntityId__c, f.qsyd_FE__FileType__c, f.qsyd_FE__FileExtension__c, f.qsyd_FE__FileOwner__r.Name, f.qsyd_FE__Tags__c, f.qsyd_FE__ContentSize__c, null));
        }

        return this;
    }

    /**
     * Converts from qsyd_Item to file explorer files
     *
     * @return a qsyd_FileList
     */
    global qsyd_FileList convertToCanonical() {
        for (qsyd_Item f : this.files) {
            this.fileExplorerFilesMap.put(f.id, new qsyd_FE__FileExplorerFile__c(Id = f.id, qsyd_FE__Folder__c = f.folder));
        }
        return this;
    }

    /**
     * Get a list of qsyd_Items
     *
     * @return a list of qsyd_Items
     */
    global List<qsyd_Item> getLogicalList() {
        return this.files;
    }

    /**
     * Get a list of file explorer files
     *
     * @return a list of file explorer files
     */
    global List<qsyd_FE__FileExplorerFile__c> getCanonicalList() {
        return this.fileExplorerFilesMap.values();
    }
}