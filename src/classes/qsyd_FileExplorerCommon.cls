/**
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_FileExplorerCommon
    Date:           28-Feb-2021

    TODO:
 */

global without sharing class qsyd_FileExplorerCommon {
    private static String AUTOMATEDPROCESS_USERTYPE = 'AutomatedProcess';
    private static String FILE_EXPLORER_PERMISSION = 'File_Explorer';
    private static String FILE_EXPLORER_SETTINGS_QUALIFIEDAPINAME = 'qsyd_FE__Settings';
    private static String DEFAULT_ACTION_MESSAGES_FILE_EXPLORER_IS_NOT_ENABLED = 'In order to access the File Explorer, please ask your Administrator to enable the Lightning File Explorer in the Custom Metadata Settings record.';
    private static String DEFAULT_ACTION_MESSAGES_NO_PERMISSION_SET = 'In order to access the File Explorer, please ask your Administrator to assign the &lt;a href=&quot;/lightning/setup/PermSets/home&quot;&gt;File Explorer Permission Set&lt;/a&gt; to your user.';

    /**
    * Determine whether to show the File Explorer or return the reason why not to
    *
    * @return return empty string if the file explorer should display, otherwise return the reason not to
    */
    @AuraEnabled
    public static String showFileExplorer() {
        String reasonWhyFileExplorerNotShown = '';

        if (!isFileExplorerEnabled()) {
            reasonWhyFileExplorerNotShown = (System.Label.Action_Messages_File_Explorer_is_not_enabled == '') ? DEFAULT_ACTION_MESSAGES_FILE_EXPLORER_IS_NOT_ENABLED : System.Label.Action_Messages_File_Explorer_is_not_enabled;
        } else if (!checkForPermission()) {
            reasonWhyFileExplorerNotShown = (System.Label.Action_Messages_No_permission_set == '') ? DEFAULT_ACTION_MESSAGES_NO_PERMISSION_SET : System.Label.Action_Messages_No_permission_set;
        }

        return reasonWhyFileExplorerNotShown;
    }

    /**
    * Check if Lightning File Explorer has been enabled for the org
    *
    * @return true if the custom metadata Lightning File Explorer.Settings "Enable" flag has been checked, otherwise return false
    */
    @AuraEnabled
    public static Boolean isFileExplorerEnabled() {
        Boolean isFileExplorerEnabled = [
                SELECT Enable__c
                FROM qsyd_FE__Lightning_File_Explorer__mdt
                WHERE QualifiedApiName = :FILE_EXPLORER_SETTINGS_QUALIFIEDAPINAME
        ]?.Enable__c;

        return (isFileExplorerEnabled != null && isFileExplorerEnabled) ? true : false;
    }

    /**
     * Check if the contextual caller has the "File_Explorer" permission set or is of type AutomatedProcess
     *
     * @return true if the contextual caller has the "File_Explorer" permission set or is of type AutomatedProcess, otherwise return false
     */
    @AuraEnabled
    public static Boolean checkForPermission() {
        Boolean hasLightningFileExplorerPermission = FeatureManagement.checkPermission(FILE_EXPLORER_PERMISSION);
        Boolean isAutomatedProcessUser = UserInfo.getUserType() == AUTOMATEDPROCESS_USERTYPE;

        return hasLightningFileExplorerPermission || isAutomatedProcessUser;
    }
}