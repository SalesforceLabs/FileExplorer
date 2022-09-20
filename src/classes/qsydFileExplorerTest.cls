/**
 * :
 * @Last Modified On   : 5/3/2020, 7:32:31 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 **/
@IsTest
global with sharing class qsydFileExplorerTest {
    private static final String SIG_B64 = 'aSBhbSBhIHNpZ25hdHVyZQ==';
    private static Account a;
    private static qsyd_File fileItem;
    private static qsyd_FileList fileItemList;
    private static qsyd_Folder folderItem;
    private static qsyd_FolderList folderItemList;
    private static User standardUser;

    @TestSetup
    private static void setupTestData() {
        fileItemList = new qsyd_FileList();
        folderItemList = new qsyd_FolderList();

        // Create LinkedEntity Record
        a = new Account(Name = 'TestAccount');
        INSERT a;

        //Create ContentVersion Record 
        ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf(SIG_B64),
                IsMajorVersion = true,
                SharingPrivacy = 'P' // set it to private on records
        );
        insert contentVersion;
        List<ContentDocument> contentDocumentList = [
                SELECT Id,
                        Title,
                        ContentSize,
                        LatestPublishedVersionId
                FROM ContentDocument
                WHERE LatestPublishedVersionId = :contentVersion.Id
        ];

        //Create ContentDocumentLink Record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = a.id;
        cdl.ContentDocumentId = contentDocumentList[0].Id;
        cdl.shareType = 'V';
        INSERT cdl;

        //Create Folder Record
        FileExplorerFolder__c qFolder = new FileExplorerFolder__c(LinkedEntityId__c = a.Id, Label__c = 'qFolder');
        INSERT qFolder;

        fileItem = new qsyd_File(
                null,
                qFolder.Id,
                'qFile',
                contentDocumentList[0].Id,
                a.Id,
                'jpg',
                'jpg',
                UserInfo.getUserId(),
                UserInfo.getUserName(),
                UserInfo.getUserType(),
                'tags',
                contentDocumentList[0].ContentSize,
                null);

        
        createStandardUser();
        
    }

    @future
    private static void createStandardUser() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@file-explorer.dev';
        
        Profile p = [
                SELECT Id 
                FROM Profile 
                WHERE Name = 'Standard User'
        ];

        standardUser = new User(
                Alias = 'stduser', 
                Email='standarduser@file-explorer.dev',
                EmailEncodingKey='UTF-8', 
                LastName='Test', 
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', 
                ProfileId = p.Id,
                TimeZoneSidKey='Australia/Sydney',
                UserName = uniqueUserName
        );
        insert standardUser;

        PermissionSet ps = [
                SELECT Id 
                FROM PermissionSet 
                WHERE Name = 'File_Explorer_Permission_Set'];

        insert new PermissionSetAssignment(
                AssigneeId = standardUser.id, 
                PermissionSetId = ps.Id
        );
    }

    @IsTest
    private static void given_newFile_when_loadItem_success() {
        setupTestData();
        Test.startTest();

        fileItem.convertToCanonical()
                .save();

        List<FileExplorerFile__c> qFiles = [
                SELECT Id,
                        ContentDocumentId__c,
                        Folder__c,
                        Label__c,
                        LinkedEntityId__c,
                        FileExtension__c,
                        ContentSize__c
                FROM FileExplorerFile__c
                ORDER BY LastModifiedDate DESC
                LIMIT 1
        ];

        Test.stopTest();

        System.assertEquals(1, qFiles.size());
    }


    @IsTest
    private static void given_newFileItemList_when_convertedToCanonical_success() {
        List<FileExplorerFile__c> canonicalFiles;

        setupTestData();

        Test.startTest();

        canonicalFiles = fileItemList.load(new List<qsyd_File>{
                fileItem
        }).convertToCanonical()
                .getCanonicalList();

        Test.stopTest();

        System.assertEquals(1, canonicalFiles.size());
    }

    @IsTest
    private static void given_newFolderItemList_when_convertedToLogical_success() {
        List<qsyd_Item> logicalFolders;

        setupTestData();

        Test.startTest();

        logicalFolders = folderItemList
                .retrieve(a.Id)
                .convertToLogical()
                .getLogicalList();

        Test.stopTest();

        System.assertEquals(1, logicalFolders.size());
    }

    @IsTest
    private static void given_newFolderItemList_when_convertedToCanonical_success() {
        List<FileExplorerFolder__c> canonicalFolders;

        setupTestData();

        Test.startTest();

        folderItemList = new qsyd_FolderList(new List<qsyd_Item>{
                fileItem
        });

        canonicalFolders = folderItemList
                .retrieve(a.Id)
                .convertToCanonical()
                .getCanonicalList();

        Test.stopTest();

        System.assertEquals(2, canonicalFolders.size());
    }

    @IsTest
    private static void given_fileSetToPrivateOnRecords_when_fileRetreieved_success() {
        List<FileExplorerFile__c> fileExplorerFileList;

        setupTestData();

        System.runAs(standardUser) {
                fileExplorerFileList = fileItemList
                        .retrieve(a.Id)
                        .convertToCanonical()
                        .getCanonicalList();

                // does not return any file
                // as only the owner can see this file
                // https://help.salesforce.com/s/articleView?id=sf.collab_files_make_private_on_record.htm&type=5
                System.assertEquals(0, fileExplorerFileList.size());
        }
    }
}