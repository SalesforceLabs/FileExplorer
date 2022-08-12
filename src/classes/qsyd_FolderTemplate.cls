/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * Author:         Paul Lucas
 * Company:        Salesforce
 * Description:    qsyd_FolderTemplate
 * Date:           01-Aug-2020
 * <p/>
 * TODO:
 */

global inherited sharing class qsyd_FolderTemplate {
    private List<FileExplorerFolderTemplate__c> template = new List<FileExplorerFolderTemplate__c>();
    private List<FileExplorerFolder__c> templateFolders = new List<FileExplorerFolder__c>();
    private qsyd_PaginatedFolderTemplates paginatedTemplates = new qsyd_PaginatedFolderTemplates();
    private Map<String, String> templateFolderIdMap = new Map<String, String>();

    /**
     * The qsyd_FolderTemplate templateId property
     */
    public String templateId {
        get {
            return templateId;
        }
        set {
            templateId = String.isBlank(value) || !(value.trim() instanceOf Id)
                    ? null
                    : String.escapeSingleQuotes(value.trim());
        }
    }

    /**
     * The qsyd_FolderTemplate entityId property
     */
    public String entityId {
        get {
            return entityId;
        }
        set {
            entityId = String.isBlank(value) || !(value.trim() instanceOf Id)
                    ? null
                    : String.escapeSingleQuotes(value.trim());
        }
    }

    /**
     * The qsyd_FolderTemplate folderId property
     */
    public String folderId {
        get {
            return folderId;
        }
        set {
            folderId = String.isBlank(value) || !(value.trim() instanceOf Id)
                    ? null
                    : String.escapeSingleQuotes(value.trim());
        }
    }

    global qsyd_FolderTemplate() {
    }

    /**
     * Constructor
     *
     * @param templateId
     * @param entityId
     * @param folderId
     */
    global qsyd_FolderTemplate(String templateId, String entityId, String folderId) {
        this.templateId = templateId;
        this.entityId = entityId;
        this.folderId = folderId;
    }

    /**
     * Checks that the File Explorer Folder Template id is valid
     *
     * @return an instance of qsyd_FolderTemplate
     */
    global qsyd_FolderTemplate isValid() {

        this.template = [
                SELECT Id
                FROM FileExplorerFolderTemplate__c
                WHERE Id = :this.templateId
                AND IsActive__c = TRUE
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];

        this.template = (List<FileExplorerFolderTemplate__c>) Security.stripInaccessible(AccessType.READABLE, this.template).getRecords();

        if (this.template.isEmpty()) {
            throw new AuraHandledException(System.Label.Action_Error_Messages_Invalid_template);
        }

        return this;
    }

    /**
     * Checks that duplicate (same label) File Explorer Folder records do not exist
     *
     * @return an instance of qsyd_FolderTemplate
     */
    global qsyd_FolderTemplate rootFoldersDoNotExist() {

        Set<String> rootTemplateFolderNames = new Map<String, SObject>([
                SELECT Label__c Id
                FROM FileExplorerFolder__c
                WHERE LinkedEntityId__c = :this.templateId
                AND Folder__c = ''
                GROUP BY Label__c
        ]).keySet();

        if ([
                SELECT COUNT()
                FROM FileExplorerFolder__c
                WHERE Label__c IN :rootTemplateFolderNames
                AND LinkedEntityId__c = :this.entityId
                AND Folder__c = :this.folderId
                WITH SECURITY_ENFORCED
                LIMIT 1
        ] > 0) {
            throw new AuraHandledException(System.Label.Action_Error_Messages_Duplicate_folder);
        }

        return this;
    }

    /**
     * Generates a shallow clone of a folder template for a given entityId
     *
     * @return an instance of qsyd_FolderTemplate
     */
    global qsyd_FolderTemplate generate() {

        this.templateFolders = [
                SELECT Id,
                        Label__c,
                        TemplateFolderId__c,
                        LinkedEntityId__c,
                        Folder__c
                FROM FileExplorerFolder__c
                WHERE LinkedEntityId__c = :this.templateId
                WITH SECURITY_ENFORCED
        ];

        this.templateFolders = (List<FileExplorerFolder__c>) Security.stripInaccessible(AccessType.READABLE, this.templateFolders).getRecords();

        // Reset references
        for (FileExplorerFolder__c folder : this.templateFolders) {
            folder.TemplateFolderId__c = folder.Id;
            folder.Id = null;
            folder.LinkedEntityId__c = this.entityId;
        }

        try {
            this.templateFolders = Security.stripInaccessible(AccessType.CREATABLE, this.templateFolders).getRecords();
            INSERT this.templateFolders;
        } catch (Exception e) {
            System.debug('>>>>> Error in cloneFolders, insert template folders: ');
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            System.debug(JSON.serializePretty(this.templateFolders));
            throw new AuraHandledException(e.getMessage());
        }

        // Dictionary of folder ids
        for (FileExplorerFolder__c folder : this.templateFolders) {
            this.templateFolderIdMap.put(folder.TemplateFolderId__c, folder.Id);
        }

        // Construct folder hierarchy
        for (FileExplorerFolder__c folder : this.templateFolders) {
            folder.Folder__c = String.isBlank(folder.Folder__c)
                    ? this.folderId
                    : this.templateFolderIdMap.get(folder.Folder__c);
            folder.TemplateFolderId__c = null;
        }

        try {
            UPDATE Security.stripInaccessible(AccessType.UPDATABLE, this.templateFolders).getRecords();
        } catch (Exception e) {
            System.debug('>>>>> Error in cloneFolders, updating template folders: ');
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            System.debug(JSON.serializePretty(this.templateFolders));
            throw new AuraHandledException(e.getMessage());
        }

        return this;
    }

    /**
     * Returns a page of File Explorer Folder Template records based on an offset, filter and sort conditions. Also returns the next expected offset
     *
     * @param filter
     * @param sortBy
     * @param pageSize
     * @param pageOffset
     *
     * @return an instance of qsyd_PaginatedFolderTemplates
     */
    global qsyd_PaginatedFolderTemplates retrieveList(String filter, String sortBy, Integer pageSize, Integer pageOffset) {
        Integer nextPageOffset = pageOffset + pageSize;
        Integer totalTemplates;

        paginatedTemplates.filter = filter;
        filter = !String.isBlank(filter.trim()) ? '\'%' + String.escapeSingleQuotes(filter) + '%\'' : '';
        sortBy = String.escapeSingleQuotes(sortBy);

        String qSelect = 'SELECT Id, Name, Label__c, Description__c, LastModifiedDate';
        String qSelectCount = 'SELECT COUNT()';
        String qFrom = ' FROM FileExplorerFolderTemplate__c';
        String qWhere = ' WHERE IsActive__c = TRUE';
        String qFilterLabel = !String.isBlank(filter) ? ' AND (Label__c LIKE ' : '';
        String qFilterDescription = !String.isBlank(filter) ? ' OR Description__c LIKE ' : '';
        String qFilterEnd = !String.isBlank(filter) ? ' ) ' : '';
        String qWith = ' WITH SECURITY_ENFORCED';
        String qOrderBy = ' ORDER BY ';
        String qLimit = ' LIMIT ';
        String qOffset = ' OFFSET ';

        String qRecords = String.format('{0}{1}{2}{3}{4}{5}{6}{7}{8}{9}{10}{11}{12}{13}{14}', new List<String>{
                qSelect, qFrom, qWhere, qFilterLabel, filter, qFilterDescription, filter, qFilterEnd, qWith,
                qOrderBy, sortBy, qLimit, String.valueOf(pageSize), qOffset, String.valueOf(pageOffset)
        });

        String qCount = String.format('{0}{1}{2}{3}{4}{5}{6}{7}{8}', new List<String>{
                qSelectCount, qFrom, qWhere, qFilterLabel, filter, qFilterDescription, filter, qFilterEnd, qWith
        });

        try {
            paginatedTemplates.records = (List<FileExplorerFolderTemplate__c>) Security.stripInaccessible(AccessType.READABLE, Database.Query(qRecords)).getRecords();
        } catch (Exception e) {
            System.debug('>>>>>> Error in retrieveList, executing query:');
            System.debug(qRecords);
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new AuraHandledException('Error executing: ' + qRecords);
        }

        try {
            totalTemplates = Database.countQuery(qCount);
            paginatedTemplates.pageOffset = nextPageOffset < totalTemplates
                    ? nextPageOffset
                    : -1;
        } catch (Exception e) {
            System.debug('>>>>>> Error in retrieveList, executing query:');
            System.debug(qCount);
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new AuraHandledException('Error executing: ' + qCount);
        }

        return paginatedTemplates;
    }

    /**
     * @description Represents a list of folder templates with current page and filters applied
     */
    global class qsyd_PaginatedFolderTemplates {
        @AuraEnabled
        public List<FileExplorerFolderTemplate__c> records;

        @AuraEnabled
        public Integer pageOffset;

        @AuraEnabled
        public String filter;
    }
}