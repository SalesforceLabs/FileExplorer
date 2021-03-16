/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


 /**
    @author         Paul Lucas
    @company        Salesforce
    @description    qsyd_ContentDocumentTriggerHandler
    @date           20-Apr-2020
        
    TODO:
 */

public with sharing class qsyd_ContentDocumentTriggerHandler extends TriggerHandler {
    private List<ContentDocument> contentDocumentOldList;
    private Map<Id, ContentDocument> contentDocumentOldMap;
    private List<ContentDocument> contentDocumentNewList;
    private Map<Id, ContentDocument> contentDocumentNewMap;
    private SObjectAccessDecision accessDecision;

    /**
     * @description Constructor
     */
    public qsyd_ContentDocumentTriggerHandler() {
        this.contentDocumentOldList = (List<ContentDocument>) Trigger.old;
        this.contentDocumentOldMap = (Map<Id, ContentDocument>) Trigger.oldMap;
        this.contentDocumentNewList = (List<ContentDocument>) Trigger.new;
        this.contentDocumentNewMap = (Map<Id, ContentDocument>) Trigger.newMap;
    }

    /**
     * @description After update, associate content document to file explorer
     */
    public override void afterUpdate() {
        Id linkedEntityId;

        List<ContentDocumentLink> cdlList = [
                SELECT LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :this.contentDocumentNewMap.keySet()
                WITH SECURITY_ENFORCED
        ];

        this.accessDecision = Security.stripInaccessible(AccessType.READABLE, cdlList);
        cdlList = (List<ContentDocumentLink>)this.accessDecision.getRecords();

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

        ContentDocument cd = this.contentDocumentNewList.get(0);
        qsyd_FE__FileExplorerFile__c file = new qsyd_FE__FileExplorerFile__c();

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
            file = (qsyd_FE__FileExplorerFile__c)this.accessDecision.getRecords().get(0);
        }

        // TODO: Check for changes before updating
        file.qsyd_FE__ContentDocumentId__c = cd.Id;
        file.qsyd_FE__LinkedEntityId__c = linkedEntityId;
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

    /**
     * @description After delete, remove any associated file explorer files
     */
    public override void afterDelete() {
        Set<Id> contentDocumentIds = (new Map<Id, SObject>(this.contentDocumentOldList)).keySet();

        List<qsyd_FE__FileExplorerFile__c> files = [
                SELECT Id
                FROM qsyd_FE__FileExplorerFile__c
                WHERE qsyd_FE__ContentDocumentId__c IN :contentDocumentIds
                WITH SECURITY_ENFORCED
        ];

        this.accessDecision = Security.stripInaccessible(AccessType.READABLE, files);

        try {
            if (Schema.SObjectType.qsyd_FE__FileExplorerFile__c.isDeletable()) {
                DELETE files;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }
}