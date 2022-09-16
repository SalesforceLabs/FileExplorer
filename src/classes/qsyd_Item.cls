/**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_Item
    Date:           20-Apr-2020

    History:
    When           Who                 What

    TODO:
 */

global virtual class qsyd_Item {
    protected SObjectAccessDecision accessDecision;

    @AuraEnabled
    global String id { get; set; }

    @AuraEnabled
    global String text { get; set; }

    @AuraEnabled
    global String folder { get; set; }

    @AuraEnabled
    global List<qsyd_Item> children { get; set; }

    @AuraEnabled
    global String documentId { get; set; }

    @AuraEnabled
    global String entityId { get; set; }

    @AuraEnabled
    global String type { get; set; }

    @AuraEnabled
    global String ext { get; set; }

    @AuraEnabled
    global String ownerId { get; set; }

    @AuraEnabled
    global String owner { get; set; }

    @AuraEnabled
    global String userType { get; set; }

    @AuraEnabled
    global String tags { get; set; }

    @AuraEnabled
    global Decimal size { get; set; }

    @AuraEnabled
    global String icon { get; set; }

    /**
     * Constructor
     */
    global qsyd_Item() {
    }

    /**
     * Constructor
     *
     * @param id
     * @param folder
     * @param label
     * @param entityId
     */
    global qsyd_Item(String id, String folder, String label, String entityId) {
        this(id, folder, label, entityId, null);
    }

    /**
     * Constructor
     *
     * @param id
     * @param folder
     * @param label
     * @param entityId
     * @param children
     */
    global qsyd_Item(Id id, Id folder, String label, String entityId, List<qsyd_Item> children) {
        this.id = (Id) id;
        this.text = label;
        this.folder = folder;
        this.entityId = (Id) entityId;

        if (children != null && children.size() > 0) {
            this.children = children;
        } else {
            this.children = new List<qsyd_Item>();
        }
    }

    /**
     * Returns true if this item is a file
     *
     * @return true if this item is a file, otherwise return false
     */
    global Boolean isFile() {
        return !String.isBlank(this.documentId);
    }

    /**
     * Returns the subclass for this item
     *
     * @return the concrete type
     */
    global String getSubClass() {
        return this.isFile() ? qsyd_File.class.getName() : qsyd_Folder.class.getName();
    }

    /**
     * Returns the folder id for this item
     *
     * @return a folder id
     */
    global Id getFolder() {
        return this.folder;
    }

    /**
     * Adds a child item.
     *
     * @param item : The item to add
     */
    public void addItem(Object item) {
        if (item != null) {
            this.children.add((qsyd_Item) item);
        }
    }

    /**
     * Object security checks
     *
     * @param objectType
     * @param checkType
     *
     * @return true if action is allowed, otherwise return false
     */
    global static boolean checkObjectSecurity(DescribeSObjectResult objectType, string checkType) {
        boolean ret = false;

        if (checkType == 'create') {
            ret = objectType.isCreateable();
        } else if (checkType == 'delete') {
            ret = objectType.isDeletable();
        } else if (checkType == 'update') {
            ret = objectType.isUpdateable();
        }
        return ret;
    }
}