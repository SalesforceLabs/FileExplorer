/**
 * @File Name          : qsydFileExplorerControllerTest.cls
 * @Description        : 
 * @Last Modified On   : 5/3/2020, 7:32:31 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
**/

@IsTest
global with sharing class qsydFileExplorerControllerTest {

    private static final String SIG_B64 = 'aSBhbSBhIHNpZ25hdHVyZQ==';

    @TestSetup
    private static void setupTestData() {

        //Create LinkedEntity Record
        Account a = new Account(Name = 'TestAccount');
        insert a;

        //Create ContentVersion Record 
        ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf(SIG_B64),
                IsMajorVersion = true
        );
        insert contentVersion;
        List<ContentDocument> contentDocumentList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion.Id];

        //Create ContentDocumentLink Record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = a.id;
        cdl.ContentDocumentId = contentDocumentList[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        //Create Folder Record
        FileExplorerFolder__c qFolder = new FileExplorerFolder__c(LinkedEntityId__c = a.Id, Label__c = 'qFolder');
        insert qFolder;
    }

    @IsTest
    private static void given_matchedContentDocumentId_when_getLatestContentVersion_success() {
        setupTestData();
        Test.startTest();
        String contentDocumentId;
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];

        List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :a.Id AND ContentDocument.Title = 'Penguins'];
        if (cdlList.size() > 0) {
            contentDocumentId = cdlList[0].ContentDocumentId;
        }
        List<ContentVersion> expectedCV = [SELECT Id, VersionNumber, ReasonForChange, LastModifiedDate FROM ContentVersion WHERE Title = 'Penguins' AND PathOnClient = 'Penguins.jpg'];
        String expected = JSON.serialize(expectedCV[0]);
        String actual = qsydFileExplorerController.getLatestContentVersion(contentDocumentId);
        System.assertEquals(expected, actual);
        Test.stopTest();
    }

    @IsTest
    private static void given_wrongContentDocumentId_when_getLatestContentVersion_null() {
        setupTestData();
        Test.startTest();
        String actual = qsydFileExplorerController.getLatestContentVersion('ABCD');
        System.assertEquals(null, actual);
        Test.stopTest();
    }

    @IsTest
    private static void given_validInputs_on_setFolder() {
        setupTestData();
        Test.startTest();
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];

        List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :a.Id AND ContentDocument.Title = 'Penguins'];

        String contentDocumentId = cdlList[0].ContentDocumentId;
        List<Id> contentDocumentIds = new List<Id>();
        contentDocumentIds.add(contentDocumentId);

        FileExplorerFile__c penguinsFileBefore = [SELECT Id, Folder__c FROM FileExplorerFile__c WHERE LinkedEntityId__c = :a.Id AND ContentDocumentId__c = :contentDocumentId LIMIT 1];

        FileExplorerFolder__c qFolder = [SELECT Id FROM FileExplorerFolder__c WHERE Label__c = 'qFolder' LIMIT 1];

        System.assertEquals(null, penguinsFileBefore.Folder__c);
        qsydFileExplorerController.setFolder(contentDocumentIds, qFolder.Id);

        FileExplorerFile__c penguinsFileAfter = [SELECT Id, Folder__c FROM FileExplorerFile__c WHERE Id = :penguinsFileBefore.Id];

        System.assertEquals(qFolder.Id, penguinsFileAfter.Folder__c);

        Test.stopTest();
    }

    @IsTest
    private static void given_validInputs_on_updateTags() {
        setupTestData();
        Test.startTest();
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];

        List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :a.Id AND ContentDocument.Title = 'Penguins'];

        String contentDocumentId = cdlList[0].ContentDocumentId;
        List<Id> contentDocumentIds = new List<Id>();
        contentDocumentIds.add(contentDocumentId);

        FileExplorerFile__c penguinsFileBefore = [SELECT Id, Tags__c FROM FileExplorerFile__c WHERE LinkedEntityId__c = :a.Id AND ContentDocumentId__c = :contentDocumentId LIMIT 1];

        System.assertEquals(null, penguinsFileBefore.Tags__c);
        qsydFileExplorerController.updateTags(penguinsFileBefore.Id, 'tags;tag');

        FileExplorerFile__c penguinsFileAfter = [SELECT Id, Tags__c FROM FileExplorerFile__c WHERE Id = :penguinsFileBefore.Id];

        System.assertEquals('tags;tag', penguinsFileAfter.Tags__c);

        Test.stopTest();
    }

    @IsTest
    private static void given_invalidInputs_on_updateTags_null() {
        setupTestData();
        Test.startTest();
        String actual = qsydFileExplorerController.updateTags('ABCDE', 'tags;tag');
        System.assertEquals(null, actual);
        Test.stopTest();
    }

    @IsTest
    private static void given_validInputs_andNoManualDeletion_on_checkSyncStatus() {
        setupTestData();
        Test.startTest();
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        Boolean actual = qsydFileExplorerController.checkSyncStatus(a.Id);
        System.assertEquals(true, actual);
        Test.stopTest();
    }

    @IsTest
    private static void given_validInputs_afterManualDeletion_on_checkSyncStatus_false() {
        setupTestData();
        Test.startTest();
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        FileExplorerFile__c penguinsFile = [SELECT Id FROM FileExplorerFile__c WHERE LinkedEntityId__c = :a.Id AND Label__c = 'Penguins' LIMIT 1];
        delete penguinsFile;
        Boolean actual = qsydFileExplorerController.checkSyncStatus(a.Id);
        System.assertEquals(false, actual);
        Test.stopTest();
    }

    @IsTest
    private static void given_validInputs_on_syncFiles_autoSyncMissingFEFile() {
        setupTestData();
        Test.startTest();

        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :a.Id AND ContentDocument.Title = 'Penguins'];
        String contentDocumentId = cdlList[0].ContentDocumentId;

        FileExplorerFile__c penguinsFile = [SELECT Id FROM FileExplorerFile__c WHERE LinkedEntityId__c = :a.Id AND Label__c = 'Penguins' LIMIT 1];
        delete penguinsFile;

        List<FileExplorerFile__c> beforeSyncFileList = [SELECT Id FROM FileExplorerFile__c WHERE LinkedEntityId__c = :a.Id AND Label__c = 'Penguins'];
        System.assertEquals(0, beforeSyncFileList.size());

        qsydFileExplorerController.syncFiles(a.Id);

        List<FileExplorerFile__c> afterSyncFileList = [SELECT Id, ContentDocumentId__c, LinkedEntityId__c FROM FileExplorerFile__c WHERE LinkedEntityId__c = :a.Id AND Label__c = 'Penguins'];

        System.assertEquals(1, afterSyncFileList.size());
        System.assertEquals(a.Id, afterSyncFileList[0].LinkedEntityId__c);
        System.assertEquals(contentDocumentId, afterSyncFileList[0].ContentDocumentId__c);

        Test.stopTest();
    }

    @IsTest
    private static void retrieveItemMap() {
        setupTestData();

        Test.startTest();
        Account a = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        String itemMapJSON = qsydFileExplorerController.retrieveItemMap(a.Id);
        Test.stopTest();

        System.assertEquals(true, itemMapJSON.contains('qFolder'));
    }

    @IsTest
    private static void postFolderItemTest() {

        String json;

        Test.startTest();

        Account a = new Account(Name = 'Test');
        INSERT a;

        json = '{"documentId":"","entityId":"' + a.Id + '","text":"new_folder","folder":null,"icon":null,"id":null,"owner":null,"size":0,"tags":null,"type":null}';
        String item = qsydFileExplorerController.postItem(json);

        List<FileExplorerFolder__c> folders = [
                SELECT Id,
                        Label__c
                FROM FileExplorerFolder__c
                WHERE Label__c = 'new_folder'
        ];
        Test.stopTest();

        System.assertEquals(1, folders.size());
    }

    @IsTest
    private static void postFileItemTest() {
        String json;

        Test.startTest();

        Account a = new Account(Name = 'Test');
        INSERT a;

        ContentVersion contentVersionInsert = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
        );
        INSERT contentVersionInsert;

        ContentDocument cd = [
                SELECT Id
                FROM ContentDocument
                LIMIT 1
        ];

        json = '{"documentId":"' + cd.Id + '","entityId":"' + a.Id + '","text":"new_file","folder":null,"icon":null,"id":null,"owner":null,"size":0,"tags":null,"type":null}';
        String item = qsydFileExplorerController.postItem(json);

        List<FileExplorerFile__c> files = [
                SELECT Id,
                        Label__c
                FROM FileExplorerFile__c
                WHERE Label__c = 'new_file'
        ];
        Test.stopTest();

        System.assertEquals(1, files.size());
    }

    @IsTest
    private static void deleteItemTest() {

        String json;

        Test.startTest();

        Account a = new Account(Name = 'Test');
        INSERT a;

        json = '{"documentId":"","entityId":"' + a.Id + '","text":"new_folder","folder":null,"icon":null,"id":null,"owner":null,"size":0,"tags":null,"type":null}';
        String item = qsydFileExplorerController.postItem(json);
        qsydFileExplorerController.deleteItem(item);

        List<FileExplorerFolder__c> folders = [
                SELECT Id,
                        Label__c
                FROM FileExplorerFolder__c
                WHERE Label__c = 'new_folder'
        ];
        Test.stopTest();

        System.assertEquals(0, folders.size());
    }

}