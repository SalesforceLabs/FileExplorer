/**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_ContentDocumentTriggerHandler
    Date:           05-May-2020
        
    TODO:
 */

public with sharing class qsyd_ContentDocumentTriggerHandler extends TriggerHandler {
    public final String SHARE_TYPE_VIEWER = 'V';
    public final String SHARE_TYPE_COLLABORATOR = 'C';
    public final String SHARE_TYPE_INFERRED = 'I';
    public final String VISIBILITY_ALLUSERS = 'AllUsers';
    public final String VISIBILITY_INTERNALUSERS = 'InternalUsers';
    public final String VISIBILITY_SHAREDUSERS = 'SharedUsers';

    private List<ContentDocument> contentDocumentOldList;
    private Map<Id, ContentDocument> contentDocumentOldMap;
    private List<ContentDocument> contentDocumentNewList;
    private Map<Id, ContentDocument> contentDocumentNewMap;

    private SObjectAccessDecision accessDecision;

    public qsyd_ContentDocumentTriggerHandler() {
        this.contentDocumentOldList = (List<ContentDocument>) Trigger.old;
        this.contentDocumentOldMap = (Map<Id, ContentDocument>) Trigger.oldMap;
        this.contentDocumentNewList = (List<ContentDocument>) Trigger.new;
        this.contentDocumentNewMap = (Map<Id, ContentDocument>) Trigger.newMap;
    }
    public override void afterUpdate() {
        // If Lightning File Explorer has not been enabled or the user has not been assigned the file explorer permissionset, return
        if (!qsyd_FileExplorerCommon.isFileExplorerEnabled() || !qsyd_FileExplorerCommon.checkForPermission()) {
            return;
        }

        Id linkedEntityId;
        ContentDocument cd = this.contentDocumentNewList.get(0);
        qsyd_FE__FileExplorerFile__c file = new qsyd_FE__FileExplorerFile__c();

        List<ContentDocumentLink> cdlList = [
                SELECT LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :this.contentDocumentNewMap.keySet()
                WITH SECURITY_ENFORCED
        ];

        this.accessDecision = Security.stripInaccessible(AccessType.READABLE, cdlList);
        cdlList = (List<ContentDocumentLink>) this.accessDecision.getRecords();

        if (!cdlList.isEmpty()) {
            switch on cdlList.size() {
                // Files uploaded to the user record
                when 1 {
                    linkedEntityId = cdlList.get(0).LinkedEntityId;
                }
                // Files uploaded to a record
                when else {
                    for (ContentDocumentLink cdl : cdlList) {
                        if (cdl.LinkedEntityId.getSobjectType() != Schema.User.SObjectType) {
                            linkedEntityId = cdl.LinkedEntityId;
                        }
                    }
                }
            }
        }

        // Transpose the EmailMessage id to its related object id and share with the related record
        if (linkedEntityId.getSobjectType() == Schema.EmailMessage.SObjectType) {
            list<EmailMessage> emailMessage = [
                    SELECT RelatedToId
                    FROM EmailMessage
                    WHERE Id = :linkedEntityId
            ];

            this.accessDecision = Security.stripInaccessible(AccessType.READABLE, emailMessage);
            emailMessage = (List<EmailMessage>) this.accessDecision.getRecords();

            linkedEntityId = emailMessage[0]?.RelatedToId;

            // Add a ContentDocumentLink entry for the EmailMessage related object, removing the degree of separation
            shareFile(cd.Id, linkedEntityId, SHARE_TYPE_INFERRED, VISIBILITY_ALLUSERS);
        }

        // Check if a file explorer file exists
        List<qsyd_FE__FileExplorerFile__c> fileList = [
                SELECT qsyd_FE__ContentDocumentId__c,
                        qsyd_FE__LinkedEntityId__c,
                        qsyd_FE__Label__c,
                        qsyd_FE__FileType__c,
                        qsyd_FE__FileExtension__c,
                        qsyd_FE__FileOwner__c,
                        qsyd_FE__ContentSize__c
                FROM qsyd_FE__FileExplorerFile__c
                WHERE qsyd_FE__ContentDocumentId__c = :cd.Id
                WITH SECURITY_ENFORCED
        ];

        this.accessDecision = Security.stripInaccessible(AccessType.READABLE, fileList);

        if (!fileList.isEmpty()) {
            file = (qsyd_FE__FileExplorerFile__c) this.accessDecision.getRecords().get(0);
        }

        // TODO: Check for changes before updating
        file.qsyd_FE__ContentDocumentId__c = cd.Id;
        file.qsyd_FE__linkedEntityId__c = linkedEntityId;
        file.qsyd_FE__Label__c = cd.Title;
        file.qsyd_FE__FileType__c = cd.FileType;
        file.qsyd_FE__FileExtension__c = cd.FileExtension;
        file.qsyd_FE__FileOwner__c = cd.OwnerId;
        file.qsyd_FE__ContentSize__c = cd.ContentSize;

        this.accessDecision = Security.stripInaccessible(AccessType.UPSERTABLE,
                new List<qsyd_FE__FileExplorerFile__c>{
                        file
                });

        try {
            UPSERT this.accessDecision.getRecords();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }

    public override void afterDelete() {
        Set<Id> contentDocumentIds = (new Map<Id, SObject>(this.contentDocumentOldList)).keySet();

        // If Lightning File Explorer has not been enabled or the user has not been assigned the file explorer permissionset, return
        if (!qsyd_FileExplorerCommon.isFileExplorerEnabled() || !qsyd_FileExplorerCommon.checkForPermission()) {
            return;
        }

        List<qsyd_FE__FileExplorerFile__c> files = [
                SELECT Id
                FROM qsyd_FE__FileExplorerFile__c
                WHERE qsyd_FE__ContentDocumentId__c IN :contentDocumentIds
                WITH SECURITY_ENFORCED
        ];

        this.accessDecision = Security.stripInaccessible(AccessType.READABLE, files);

        try {
            if (Schema.sObjectType.qsyd_FE__FileExplorerFile__c.isDeletable()) {
                DELETE files;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }

    private void shareFile(String contentDocumentId, String linkedEntityId, String shareType, String visibility) {
        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = contentDocumentId, LinkedEntityId = linkedEntityId, ShareType = shareType, Visibility = visibility);

        this.accessDecision = Security.stripInaccessible(AccessType.CREATABLE, new list<ContentDocumentLink>{
                cdl
        });

        try {
            INSERT this.accessDecision.getRecords();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }
}