/**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_IItem
    Date:           20-Apr-2020

    TODO:
 */

public interface qsyd_IItem {
    String getSubClass();
    String getFolder();
    Boolean isFile();
    qsyd_IItem load(qsyd_Item item);
    qsyd_IItem convertToCanonical();
    qsyd_IItem save();
    qsyd_IItem remove();
}