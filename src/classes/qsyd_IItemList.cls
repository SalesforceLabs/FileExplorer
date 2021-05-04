/**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_IItemList
    Date:           26-Apr-2020
        
    TODO:
 */

public interface qsyd_IItemList {
    qsyd_IItemList load(List<qsyd_Item> items);
    List<qsyd_Item> getLogicalList();
    List<sObject> getCanonicalList();
    qsyd_IItemList convertToLogical();
    qsyd_IItemList convertToCanonical();
}