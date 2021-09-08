/**
 * : File Explorer controller class
 *
 * @author : Paul Lucas, Jiun Ryu, Elly Zhu, Derrick Vuong
 **/
global with sharing class qsydFileExplorerController {
    static Map<String, List<qsyd_Item>> itemMap = new Map<String, List<qsyd_Item>>();
    static SObjectAccessDecision accessDecision;

    /**
     * Return the latest content version for a given content document
     *
     * @param contentDocumentId
     *
     * @return the latest content version record
     */
    @AuraEnabled(cacheable=true)
    public static String getLatestContentVersion(String contentDocumentId) {
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        try {
            contentVersionList = [
                    SELECT Id,
                            VersionNumber,
                            ReasonForChange,
                            LastModifiedDate
                    FROM ContentVersion
                    WHERE ContentDocumentId = :contentDocumentId
                    AND IsLatest = TRUE
                    WITH SECURITY_ENFORCED
                    ORDER BY VersionNumber DESC
            ];

            accessDecision = Security.stripInaccessible(AccessType.READABLE, contentVersionList);
            contentVersionList = (List<ContentVersion>) accessDecision.getRecords();

            if (contentVersionList.size() > 0) {
                return JSON.serialize(contentVersionList[0]);
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            return null;
        }
    }

    /**
     * Associates a content document with a file explorer folder
     *
     * @param contentDocumentIds
     * @param folderId
     */
    @AuraEnabled
    public static void setFolder(List<Id> contentDocumentIds, String folderId) {
        try {
            List<qsyd_FE__FileExplorerFile__c> files = [
                    SELECT Id, qsyd_FE__Folder__c
                    FROM qsyd_FE__FileExplorerFile__c
                    WHERE qsyd_FE__ContentDocumentId__c IN :contentDocumentIds
            ];

            accessDecision = Security.stripInaccessible(AccessType.READABLE, files);
            files = (List<qsyd_FE__FileExplorerFile__c>) accessDecision.getRecords();

            for (qsyd_FE__FileExplorerFile__c file : files) {
                file.qsyd_FE__Folder__c = folderId;
            }

            accessDecision = Security.stripInaccessible(AccessType.UPDATABLE, files);
            UPDATE accessDecision.getRecords();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Update a file explorer file's tags
     *
     * @param fileId
     * @param tags
     *
     * @return the updated tags
     */
    @AuraEnabled
    public static String updateTags(String fileId, String tags) {
        try {
            List<qsyd_FE__FileExplorerFile__c> files = [
                    SELECT Id, qsyd_FE__Tags__c
                    FROM qsyd_FE__FileExplorerFile__c
                    WHERE Id = :fileId
                    WITH SECURITY_ENFORCED
            ];

            accessDecision = Security.stripInaccessible(AccessType.READABLE, files);
            files = (List<qsyd_FE__FileExplorerFile__c>) accessDecision.getRecords();

            if (files.size() > 0) {
                files[0].qsyd_FE__Tags__c = tags;

                accessDecision = Security.stripInaccessible(AccessType.UPDATABLE, files);
                UPDATE accessDecision.getRecords();

                return JSON.serialize(files[0]);
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Determine if synchronisation is required
     *
     * @param recordId
     *
     * @return true if synchronisation is required, otherwise return false
     */
    @AuraEnabled
    public static Boolean checkSyncStatus(String recordId) {

        Integer countDocumentLink = 0, countFile = 0;
        try {
            countDocumentLink = database.countQuery('SELECT count() From ContentDocumentLink WHERE IsDeleted = FALSE AND LinkedEntityId = \'' + recordId + '\'');
            countFile = database.countQuery('SELECT count() From qsyd_FE__FileExplorerFile__c WHERE qsyd_FE__LinkedEntityId__c = \'' + recordId + '\'');

            return (countFile == countDocumentLink);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Synchronises a records existing content documents with file explorer files
     *
     * @param recordId
     *
     * @return a summary of synchronised file explorer files
     */
    @AuraEnabled
    public static String syncFiles(String recordId) {
        List<qsyd_FE__FileExplorerFile__c> insertFileList = new List<qsyd_FE__FileExplorerFile__c> ();
        List<qsyd_FE__FileExplorerFile__c> deleteFileList = new List<qsyd_FE__FileExplorerFile__c> ();
        List<qsyd_FE__FileExplorerFile__c> currentFileList = new List<qsyd_FE__FileExplorerFile__c> ();
        Map<String, qsyd_FE__FileExplorerFile__c> currentFileMap = new Map<String, qsyd_FE__FileExplorerFile__c>();
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        Map<String, ContentDocumentLink> currentContentDocumentMap = new Map<String, ContentDocumentLink>();

        try {
            contentDocumentLinks = new List<ContentDocumentLink>([
                    SELECT ContentDocument.Title,
                            ContentDocument.ContentSize,
                            ContentDocument.FileType,
                            ContentDocument.FileExtension,
                            ContentDocument.IsDeleted,
                            ContentDocument.OwnerId,
                            ContentDocumentId,
                            IsDeleted,
                            LinkedEntityId,
                            ShareType,
                            SystemModstamp,
                            Visibility
                    FROM ContentDocumentLink
                    WHERE ContentDocument.IsDeleted = FALSE
                    AND IsDeleted = FALSE
                    AND LinkedEntityId = :recordId
            ]);

            currentFileList = [
                    SELECT qsyd_FE__ContentDocumentId__c
                    FROM qsyd_FE__FileExplorerFile__c
                    WHERE qsyd_FE__LinkedEntityId__c = :recordId
            ];

            accessDecision = Security.stripInaccessible(AccessType.READABLE, currentFileList);
            currentFileList = (List<qsyd_FE__FileExplorerFile__c>) accessDecision.getRecords();

            for (Integer cfi = 0; cfi < currentFileList.size(); cfi++) {
                currentFileMap.put(currentFileList[cfi].qsyd_FE__ContentDocumentId__c, currentFileList[cfi]);
            }

            if (!contentDocumentLinks.isEmpty()) {
                accessDecision = Security.stripInaccessible(AccessType.READABLE, contentDocumentLinks);
                contentDocumentLinks = (List<ContentDocumentLink>) accessDecision.getRecords();

                for (ContentDocumentLink cdl : contentDocumentLinks) {
                    currentContentDocumentMap.put(cdl.ContentDocumentId, cdl);

                    if (!currentFileMap.containsKey(cdl.ContentDocumentId)) {
                        qsyd_FE__FileExplorerFile__c fe = new qsyd_FE__FileExplorerFile__c();
                        fe.qsyd_FE__ContentDocumentId__c = cdl.ContentDocumentId;
                        fe.qsyd_FE__LinkedEntityId__c = recordId;
                        fe.qsyd_FE__Label__c = cdl.ContentDocument.Title;
                        fe.qsyd_FE__FileType__c = cdl.ContentDocument.FileType;
                        fe.qsyd_FE__FileExtension__c = cdl.ContentDocument.FileExtension;
                        fe.qsyd_FE__FileOwner__c = cdl.ContentDocument.OwnerId;
                        fe.qsyd_FE__ContentSize__c = cdl.ContentDocument.ContentSize;

                        insertFileList.add(fe);
                    }
                }
            }

            if (!currentFileMap.isEmpty()) {
                for (String currentFileContentDocumentId : currentFileMap.keySet()) {
                    if (!currentContentDocumentMap.containsKey(currentFileContentDocumentId)) {
                        deleteFileList.add(currentFileMap.get(currentFileContentDocumentId));
                    }
                }
            }

            if (Schema.sObjectType.qsyd_FE__FileExplorerFile__c.isDeletable()) {
                accessDecision = Security.stripInaccessible(AccessType.CREATABLE, insertFileList);

                DELETE deleteFileList;
                INSERT accessDecision.getRecords();
            }

            return 'insertFileList: ' + JSON.serialize(insertFileList) + 'deleteFileList: ' + JSON.serialize(deleteFileList);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * True if called from a community context
     *
     * @return true if called from a community context, otherwise return false
     */
    @AuraEnabled
    public static Boolean isCommunity() {
        Id siteId = Site.getSiteId();
        if (siteId != null) {
            return true;
        }
        return false;
    }

    /**
     * Get the community prefix, if available
     *
     * @return a community prefix, if available
     */
    @AuraEnabled
    public static String getCommunityPrefix() {
        return !String.IsBlank(Site.getPathPrefix()) ? Site.getPathPrefix().removeEndIgnoreCase('/s') : '';
    }

    /**
     * Save either a file explorer file or folder
     *
     * @param serializedItem
     *
     * @return the file explorer item
     */
    @AuraEnabled
    public static String postItem(String serializedItem) {
        qsyd_Item dataItem;
        qsyd_IItem item;

        dataItem = (qsyd_Item) JSON.deserialize(serializedItem, qsyd_Item.class);

        // Concrete objects
        item = (new qsyd_ItemFactory()).newInstance(dataItem.getSubClass());

        item.load(dataItem)
                .convertToCanonical()
                .save();

        return JSON.serialize(item);
    }

    /**
     * Delete either a file explorer file or folder
     *
     * @param serializedItem
     */
    @AuraEnabled
    public static void deleteItem(String serializedItem) {
        qsyd_Item dataItem;
        qsyd_IItem item;

        dataItem = (qsyd_Item) JSON.deserialize(serializedItem, qsyd_Item.class);

        // Concrete objects
        item = (new qsyd_ItemFactory()).newInstance(dataItem.getSubClass());

        item.load(dataItem)
                .convertToCanonical()
                .remove();
    }

    /**
     * Retrieve the file explorer files and folder records for a given record
     *
     * @param recordId
     *
     * @return File explorer files and folders
     */
    @AuraEnabled
    public static String retrieveItemMap(String recordId) {
        qsyd_FileList files = new qsyd_FileList();
        qsyd_FolderList folders = new qsyd_FolderList();

        itemMap.put(qsyd_File.FILES_KEY, files.retrieve(recordId)
                .convertToLogical()
                .getLogicalList());

        itemMap.put(qsyd_Folder.FOLDERS_KEY, folders.retrieve(recordId)
                .convertToLogical()
                .getLogicalList());

        return JSON.serialize(itemMap);
    }

    /**
     * Get a page of folder templates
     *
     * @param filter
     * @param sortBy
     * @param pageSize
     * @param pageOffset
     *
     * @return Folder templates
     */
    @AuraEnabled
    public static String getTemplates(String filter, String sortBy, Integer pageSize, Integer pageOffset) {
        return JSON.serialize(new qsyd_FolderTemplate()
                .retrieveList(filter, sortBy, pageSize, pageOffset));
    }

    /**
     * Clone a folder template
     *
     * @param templateId
     * @param entityId
     * @param folderId
     */
    @AuraEnabled
    public static void cloneTemplate(String templateId, String entityId, String folderId) {
        new qsyd_FolderTemplate(templateId, entityId, folderId)
                .isValid()
                .rootFoldersDoNotExist()
                .generate();
    }
}