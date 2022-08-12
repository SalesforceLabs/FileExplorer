/**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_File
    Date:           20-Apr-2020

    History:
    When           Who                 What

    TODO:
 */

global virtual inherited sharing class qsyd_File extends qsyd_Item implements qsyd_IItem {
    public static final String FILES_KEY = 'files';
    public static final String SITE_PATH_PREFIX = !String.IsBlank(Site.getPathPrefix()) ? Site.getPathPrefix() : '';
    public static final String ASSETS_PATH = SITE_PATH_PREFIX.removeEndIgnoreCase('/s') + '/resource/qsyd_FE__filexplorer/assets/';

    private qsyd_FE__FileExplorerFile__c fileExplorerFile;

    /**
     * Constructor
     */
    global qsyd_File() {
    }

    /**
     * Constructor
     *
     * @param id
     * @param folder
     * @param label
     * @param documentId
     * @param entityId
     * @param type
     * @param ext
     * @param owner
     * @param tags
     * @param size
     * @param items
     */
    global qsyd_File(Id id, Id folder, String label, String documentId, String entityId, String type, String ext, String owner, String tags, Decimal size, List<qsyd_Item> items) {
        super(id, folder, label, entityId, items);

        this.documentId = documentId;
        this.entityId = entityId;
        this.type = type;
        this.ext = ext;
        this.owner = owner;
        this.tags = tags;
        this.size = size;

        switch on this.type.toLowerCase() {
            when 'doc', 'docx', 'word_x' {
                this.icon = ASSETS_PATH + 'word.png';
            }
            when 'xls', 'xlsx', 'excel_x' {
                this.icon = ASSETS_PATH + 'excel.png';
            }
            when 'ai' {
                this.icon = ASSETS_PATH + 'illustrator.png';
            }
            when 'jpg', 'jpeg', 'svg', 'gif', 'png', 'tif' {
                this.icon = ASSETS_PATH + 'image.png';
            }
            when 'pdf' {
                this.icon = ASSETS_PATH + 'pdf.png';
            }
            when 'ps' {
                this.icon = ASSETS_PATH + 'photoshop.png';
            }
            when 'ppt', 'pptx', 'power_point_x' {
                this.icon = ASSETS_PATH + 'ppt.png';
            }
            when else {
                this.icon = ASSETS_PATH + 'doc.png';
            }
        }
    }

    /**
     * Populates an instance of qsyd_File
     *
     * @return an instance of qsyd_File
     */
    global qsyd_File load(qsyd_Item item) {
        this.id = (Id) item.id;
        this.text = item.text;
        this.folder = (Id) item.folder;
        this.documentId = (Id) item.documentId;
        this.entityId = (Id) item.entityId;
        this.type = item.type;
        this.ext = item.ext;
        this.owner = item.owner;
        this.tags = item.tags;
        this.size = item.size;

        return this;
    }

    /**
     * Converts from qsyd_File to File Explorer File
     *
     * @return an instance of qsyd_File
     */
    global qsyd_File convertToCanonical() {
        this.fileExplorerFile = new qsyd_FE__FileExplorerFile__c(Id = this.id, qsyd_FE__Label__c = this.text, qsyd_FE__Folder__c = this.folder, qsyd_FE__LinkedEntityId__c = this.entityId);

        return this;
    }

    /**
     * Saves a File Explorer File record
     *
     * @return an instance of qsyd_File
     */
    global qsyd_File save() {
        this.accessDecision = Security.stripInaccessible(AccessType.UPSERTABLE,
                new List<qsyd_FE__FileExplorerFile__c>{
                        this.fileExplorerFile
                });

        try {
            UPSERT this.accessDecision.getRecords();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }

        return this;
    }

    /**
     * No action
     *
     * @return an instance of qsyd_File
     */
    global qsyd_File remove() {

        return this;
    }
}