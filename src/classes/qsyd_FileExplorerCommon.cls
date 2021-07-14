/**
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_FileExplorerCommon
    Date:           28-Feb-2021

    TODO:
 */

global with sharing class qsyd_FileExplorerCommon {
    private static String FILE_EXPLORER_PERMISSION = 'File_Explorer';

    /**
        * Check if the contextual caller has the "File_Explorer" permission set
        *
        * @return true if the contextual caller has the "File_Explorer" permission set, otherwise return false
        */
    @AuraEnabled
    public static Boolean isFileExplorerEnabled() {
        Boolean hasLightningFileExplorerPermission = FeatureManagement.checkPermission(FILE_EXPLORER_PERMISSION);

        return hasLightningFileExplorerPermission;
    }
}