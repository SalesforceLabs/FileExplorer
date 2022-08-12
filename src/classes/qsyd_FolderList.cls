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

    /**
     * Constructor
     */
    global qsyd_FolderList() {
        this.fileExplorerFoldersMap = new Map<Id, FileExplorerFolder__c>();
        this.folders = new List<qsyd_Folder>();
    }

    /**
     * Constructor
     *
     * @param items
     */
    global qsyd_FolderList(List<qsyd_Item> items) {
        this.fileExplorerFoldersMap = new Map<Id, FileExplorerFolder__c>();
        this.folders = items;
    }

    /**
     * Populate a list of qsyd_Item
     *
     * @param items
     *
     * @return a qsyd_FolderList
     */
    global qsyd_FolderList load(List<qsyd_Item> items) {
        this.folders = items;

        return this;
    }

    /**
     * Retrieve file explorer folder records
     *
     * @param recordId
     *
     * @return a qsyd_FolderList
     */
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

    /**
     * Converts from file explorer folders to a list of qsyd_Folders
     *
     * @return a qsyd_FolderList
     */
    global qsyd_FolderList convertToLogical() {

        for (FileExplorerFolder__c f : this.fileExplorerFoldersMap.values()) {
            this.folders.add(new qsyd_Folder(f.Id, f.Folder__c, f.Label__c, f.LinkedEntityId__c));
        }

        return this;
    }

    /**
     * Converts from qsyd_Item to file explorer folders
     *
     * @return a qsyd_FolderList
     */
    global qsyd_FolderList convertToCanonical() {

        for (qsyd_Item f : this.folders) {
            this.fileExplorerFoldersMap.put(f.id, new FileExplorerFolder__c(Id = f.id, Folder__c = f.folder, Label__c = f.text, LinkedEntityId__c = f.entityId));
        }

        return this;
    }

    /**
     * Get a list of qsyd_Items
     *
     * @return a list of qsyd_Items
     */
    global List<qsyd_Item> getLogicalList() {
        return this.folders;
    }

    /**
     * Get a list of file explorer folders
     *
     * @return a list of file explorer folders
     */
    global List<FileExplorerFolder__c> getCanonicalList() {
        return this.fileExplorerFoldersMap.values();
    }
}