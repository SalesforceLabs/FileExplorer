/**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_Folder
    Date:           21-Apr-2020

    History:
    When           Who                 What

    TODO:
 */

global virtual inherited sharing class qsyd_Folder extends qsyd_Item implements qsyd_IItem {

    public static final String FOLDERS_KEY = 'folders';

    private FileExplorerFolder__c fileExplorerFolder;

    /**
     * Constructor
     */
    global qsyd_Folder() {
    }

    /**
     * Constructor
     *
     * @param id
     * @param folder
     * @param label
     * @param entityId
     */
    global qsyd_Folder(Id id, String folder, String label, String entityId) {
        super(id, folder, label, entityId);
    }

    /**
     * Constructor
     *
     * @param id
     * @param folder
     * @param label
     * @param entityId
     * @param items
     */
    global qsyd_Folder(Id id, String folder, String label, String entityId, List<qsyd_Item> items) {
        super(id, folder, label, entityId, items);
    }

    /**
     * Populates an instance of qsyd_Folder
     *
     * @param item
     *
     * @return an instance of qsyd_Folder
     */
    global qsyd_Folder load(qsyd_Item item) {
        this.id = (Id) item.id;
        this.text = item.text.trim();
        this.folder = item.folder;
        this.entityId = (Id) item.entityId;

        return this;
    }

    /**
     * Converts from qsyd_Folder to File Explorer Folder
     *
     * @return an instance of qsyd_Folder
     */
    global qsyd_Folder convertToCanonical() {
        this.fileExplorerFolder = new FileExplorerFolder__c(Id = this.id, Label__c = this.text, Folder__c = this.folder, LinkedEntityId__c = this.entityId);

        return this;
    }

    /**
     * Saves a File Explorer Folder record
     *
     * @return an instance of qsyd_Folder
     */
    global qsyd_Folder save() {

        // Ideally, this would be in it's own method however, cannot add new final methods to virtual or abstract classes
        if ([
                SELECT COUNT()
                FROM FileExplorerFolder__c
                WHERE Label__c = :this.text
                AND LinkedEntityId__c = :this.entityId
                AND Folder__c = :this.folder
                WITH SECURITY_ENFORCED
                LIMIT 1
        ] > 0) {
            throw new AuraHandledException(System.Label.Action_Error_Messages_Duplicate_folder);
        }

        this.fileExplorerFolder = (FileExplorerFolder__c) Security.stripInaccessible(AccessType.UPSERTABLE,
                new List<FileExplorerFolder__c>{
                        fileExplorerFolder
                }).getRecords()[0];

        try {
            UPSERT this.fileExplorerFolder;
            this.id = this.fileExplorerFolder.Id;

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());

            throw new AuraHandledException(e.getMessage());
        }

        return this;
    }

    /**
     * Deletes a File Explorer Folder record. Re-references any child items
     *
     * @return an instance of qsyd_Folder
     */
    global qsyd_Folder remove() {
        List<FileExplorerFolder__c> childFolders;
        List<FileExplorerFile__c> childFiles;
        Set<String> childFolderNames = new Set<String>();

        childFolders = [
                SELECT Folder__c, Label__c
                FROM FileExplorerFolder__c
                WHERE LinkedEntityId__c = :this.entityId
                AND Folder__c = :this.id
                AND Id != :this.id
                WITH SECURITY_ENFORCED
        ];

        childFolders = (List<FileExplorerFolder__c>) Security.stripInaccessible(AccessType.READABLE, childFolders).getRecords();

        for (FileExplorerFolder__c f : childFolders) {
            f.Folder__c = this.folder;
            childFolderNames.add(f.Label__c);
        }

        // Ideally, this would be in it's own method however, cannot add new final methods to virtual or abstract classes
        if ([
                SELECT COUNT()
                FROM FileExplorerFolder__c
                WHERE Label__c IN :childFolderNames
                AND LinkedEntityId__c = :this.entityId
                AND Folder__c = :this.folder
                AND Id != :this.id
                WITH SECURITY_ENFORCED
                LIMIT 1
        ] > 0) {
            throw new AuraHandledException(System.Label.Action_Error_Messages_Duplicate_folder);
        }

        childFiles = [
                SELECT Folder__c
                FROM FileExplorerFile__c
                WHERE LinkedEntityId__c = :this.entityId
                AND Folder__c = :this.id
                WITH SECURITY_ENFORCED
        ];

        childFiles = (List<FileExplorerFile__c>) Security.stripInaccessible(AccessType.READABLE, childFiles).getRecords();

        for (FileExplorerFile__c f : childFiles) {
            f.Folder__c = this.folder;
        }

        Savepoint sp = Database.setSavepoint();
        try {
            if (qsyd_Item.checkObjectSecurity(FileExplorerFolder__c.SObjectType.getDescribe(), 'delete')) {
                UPDATE Security.stripInaccessible(AccessType.UPDATABLE, childFolders).getRecords();
                UPDATE Security.stripInaccessible(AccessType.UPDATABLE, childFiles).getRecords();
                DELETE this.fileExplorerFolder;
            }
        } catch (Exception e) {
            if (sp != null) {
                Database.rollback(sp);
            }
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());

            throw new AuraHandledException(e.getMessage());
        }

        return this;
    }
}