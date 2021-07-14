/**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_ItemList
    Date:           03-Apr-2020
        
    TODO:
 */

global class qsyd_ItemList {

    global static final String SUFFIX = 'List';

    global qsyd_ItemList() {
    }

    public qsyd_IItemList newItemList(String className) {
        Type itemListType = Type.forName(className);
        if (itemListType == null) {
            return null;
        }

        return (qsyd_IItemList) itemListType.newInstance();
    }
}