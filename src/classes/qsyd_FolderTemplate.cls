/**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_FolderTemplate
    Date:           01-Aug-2020
        
    TODO:
 */

global inherited sharing class qsyd_FolderTemplate {
    private List<qsyd_FE__FileExplorerFolderTemplate__c> template = new List<qsyd_FE__FileExplorerFolderTemplate__c>();
    private List<qsyd_FE__FileExplorerFolder__c> templateFolders = new List<qsyd_FE__FileExplorerFolder__c>();
    private qsyd_PaginatedFolderTemplates paginatedTemplates = new qsyd_PaginatedFolderTemplates();
    private Map<String, String> templateFolderIdMap = new Map<String, String>();

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
                FROM qsyd_FE__FileExplorerFolderTemplate__c
                WHERE Id = :this.templateId
                AND IsActive__c = TRUE
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];

        this.template = (List<qsyd_FE__FileExplorerFolderTemplate__c>) Security.stripInaccessible(AccessType.READABLE, this.template).getRecords();

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
                SELECT qsyd_FE__Label__c Id
                FROM qsyd_FE__FileExplorerFolder__c
                WHERE qsyd_FE__LinkedEntityId__c = :this.templateId
                AND qsyd_FE__Folder__c = ''
                GROUP BY qsyd_FE__Label__c
        ]).keySet();

        if ([
                SELECT COUNT()
                FROM qsyd_FE__FileExplorerFolder__c
                WHERE qsyd_FE__Label__c IN :rootTemplateFolderNames
                AND qsyd_FE__LinkedEntityId__c = :this.entityId
                AND qsyd_FE__Folder__c = :this.folderId
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
                        qsyd_FE__Label__c,
                        qsyd_FE__TemplateFolderId__c,
                        qsyd_FE__LinkedEntityId__c,
                        qsyd_FE__Folder__c
                FROM qsyd_FE__FileExplorerFolder__c
                WHERE qsyd_FE__LinkedEntityId__c = :this.templateId
                WITH SECURITY_ENFORCED
        ];

        this.templateFolders = (List<qsyd_FE__FileExplorerFolder__c>) Security.stripInaccessible(AccessType.READABLE, this.templateFolders).getRecords();

        // Reset references
        for (qsyd_FE__FileExplorerFolder__c folder : this.templateFolders) {
            folder.qsyd_FE__TemplateFolderId__c = folder.Id;
            folder.Id = null;
            folder.qsyd_FE__LinkedEntityId__c = this.entityId;
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
        for (qsyd_FE__FileExplorerFolder__c folder : this.templateFolders) {
            this.templateFolderIdMap.put(folder.qsyd_FE__TemplateFolderId__c, folder.Id);
        }

        // Construct folder hierarchy
        for (qsyd_FE__FileExplorerFolder__c folder : this.templateFolders) {
            folder.qsyd_FE__Folder__c = String.isBlank(folder.qsyd_FE__Folder__c)
                    ? this.folderId
                    : this.templateFolderIdMap.get(folder.qsyd_FE__Folder__c);
            folder.qsyd_FE__TemplateFolderId__c = null;
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

        String qSelect = 'SELECT Id, Name, qsyd_FE__Label__c, qsyd_FE__Description__c, LastModifiedDate';
        String qSelectCount = 'SELECT COUNT()';
        String qFrom = ' FROM qsyd_FE__FileExplorerFolderTemplate__c';
        String qWhere = ' WHERE qsyd_FE__IsActive__c = TRUE';
        String qFilterLabel = !String.isBlank(filter) ? ' AND (qsyd_FE__Label__c LIKE ' : '';
        String qFilterDescription = !String.isBlank(filter) ? ' OR qsyd_FE__Description__c LIKE ' : '';
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
            paginatedTemplates.records = (List<qsyd_FE__FileExplorerFolderTemplate__c>) Security.stripInaccessible(AccessType.READABLE, Database.Query(qRecords)).getRecords();
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

    global class qsyd_PaginatedFolderTemplates {
        @AuraEnabled
        public List<qsyd_FE__FileExplorerFolderTemplate__c> records;

        @AuraEnabled
        public Integer pageOffset;

        @AuraEnabled
        public String filter;
    }
}