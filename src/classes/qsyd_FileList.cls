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

    /**
     * Constructor
     */
    global qsyd_FileList() {
        this.fileExplorerFilesMap = new Map<Id, FileExplorerFile__c>();
        this.files = new List<qsyd_File>();
    }

    /**
     * Constructor
     *
     * @param items
     */
    global qsyd_FileList(List<qsyd_Item> items) {
        this.fileExplorerFilesMap = new Map<Id, FileExplorerFile__c>();
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

        List<ContentDocumentLink> cdlList = [
            SELECT 
                ContentDocumentId
            FROM ContentDocumentLink
            WHERE ContentDocument.IsDeleted = FALSE
            AND IsDeleted = FALSE
            AND LinkedEntityId = :recordId
        ];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink cdl : (List<ContentDocumentLink>)Security.stripInaccessible(AccessType.READABLE, cdlList).getRecords()) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        List<ContentVersion> contentVersionList = [ 
            SELECT 
                Id, 
                ContentDocumentId 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :contentDocumentIds
        ];
        contentDocumentIds.clear();
        for (ContentVersion contentVersion : (List<ContentVersion>)Security.stripInaccessible(AccessType.READABLE, contentVersionList).getRecords()) {
            contentDocumentIds.add(contentVersion.ContentDocumentId);
        }


        this.fileExplorerFilesMap = new Map<Id, FileExplorerFile__c>([
                SELECT Folder__c,
                        Label__c,
                        ContentDocumentId__c,
                        LinkedEntityId__c,
                        FileType__c,
                        FileExtension__c,
                        FileOwner__c,
                        FileOwner__r.Name,
                        FileOwner__r.UserType,
                        Tags__c,
                        ContentSize__c
                FROM FileExplorerFile__c
                WHERE 
                    ContentDocumentId__c IN :contentDocumentIds AND
                    LinkedEntityId__c = :recordId
                WITH SECURITY_ENFORCED
                ORDER BY Label__c
        ]);

        this.fileExplorerFilesMap.putAll((List<FileExplorerFile__c>) Security.stripInaccessible(AccessType.READABLE, this.fileExplorerFilesMap.values()).getRecords());

        return this;
    }

    /**
     * Converts from file explorer files to a list of qsyd_Files
     *
     * @return a qsyd_FileList
     */
    global qsyd_FileList convertToLogical() {

        for (FileExplorerFile__c f : this.fileExplorerFilesMap.values()) {
            this.files.add(new qsyd_File(f.Id, f.Folder__c, f.Label__c, f.ContentDocumentId__c, f.LinkedEntityId__c, f.FileType__c, f.FileExtension__c, f.FileOwner__c, f.FileOwner__r.Name, f.FileOwner__r.UserType, f.Tags__c, f.ContentSize__c, null));
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
            this.fileExplorerFilesMap.put(f.id, new FileExplorerFile__c(Id = f.id, Folder__c = f.folder));
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
    global List<FileExplorerFile__c> getCanonicalList() {
        return this.fileExplorerFilesMap.values();
    }
}