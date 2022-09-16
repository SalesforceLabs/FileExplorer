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

        // Create LinkedEntity Record
        Account a = new Account(Name = 'TestAccount');
        insert a;

        //Create ContentVersion Record 
        ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                ReasonForChange = 'update',
                PathOnClient = 'Penguins.ppt',
                VersionData = Blob.valueOf(SIG_B64),
                IsMajorVersion = true
        );
        INSERT contentVersion;
        List<ContentDocument> contentDocumentList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion.Id];

        //Create ContentDocumentLink Record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = a.id;
        cdl.ContentDocumentId = contentDocumentList[0].Id;
        cdl.shareType = 'V';
        INSERT cdl;

        //Create Folder Record
        FileExplorerFolder__c qFolder = new FileExplorerFolder__c(LinkedEntityId__c = a.Id, Label__c = 'qFolder');
        INSERT qFolder;
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
        List<ContentVersion> expectedCV = [SELECT Id, VersionNumber, ReasonForChange, LastModifiedDate FROM ContentVersion WHERE Title = 'Penguins' AND PathOnClient = 'Penguins.ppt'];

        System.assertEquals(expectedCV[0].Id, ((ContentVersion) JSON.deserialize(qsydFileExplorerController.getLatestContentVersion(contentDocumentId), ContentVersion.class)).Id);
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
    private static void qsyd_FileInitialisationTest() {
        qsyd_File file;

        Test.startTest();
        file = new qsyd_File('a000a0000000000000', 'a000a0000000000001', 'label', 'a000a0000000000002', 'a000a0000000000004', 'doc', '.doc', null, 'owner', 'Standard', 'tags', 10, null);
        System.assertEquals(true, file.icon.contains('word.png'));
        file = new qsyd_File('a000a0000000000000', 'a000a0000000000001', 'label', 'a000a0000000000002', 'a000a0000000000004', 'xls', '.xls', null,'owner', 'Standard', 'tags', 10, null);
        System.assertEquals(true, file.icon.contains('excel.png'));
        file = new qsyd_File('a000a0000000000000', 'a000a0000000000001', 'label', 'a000a0000000000002', 'a000a0000000000004', 'ai', '.ai', null,'owner', 'Standard', 'tags', 10, null);
        System.assertEquals(true, file.icon.contains('illustrator.png'));
        file = new qsyd_File('a000a0000000000000', 'a000a0000000000001', 'label', 'a000a0000000000002', 'a000a0000000000004', 'jpg', '.jpg', null,'owner', 'Standard', 'tags', 10, null);
        System.assertEquals(true, file.icon.contains('image.png'));
        file = new qsyd_File('a000a0000000000000', 'a000a0000000000001', 'label', 'a000a0000000000002', 'a000a0000000000004', 'pdf', '.pdf', null,'owner', 'Standard', 'tags', 10, null);
        System.assertEquals(true, file.icon.contains('pdf.png'));
        file = new qsyd_File('a000a0000000000000', 'a000a0000000000001', 'label', 'a000a0000000000002', 'a000a0000000000004', 'ps', '.ps', null,'owner', 'Standard', 'tags', 10, null);
        System.assertEquals(true, file.icon.contains('photoshop.png'));
        file = new qsyd_File('a000a0000000000000', 'a000a0000000000001', 'label', 'a000a0000000000002', 'a000a0000000000004', 'ppt', '.ppt', null,'owner', 'Standard', 'tags', 10, null);
        System.assertEquals(true, file.icon.contains('ppt.png'));
        file = new qsyd_File('a000a0000000000000', 'a000a0000000000001', 'label', 'a000a0000000000002', 'a000a0000000000004', 'other', '.other', null,'owner', 'Standard', 'tags', 10, null);
        System.assertEquals(true, file.icon.contains('doc.png'));
        Test.stopTest();

    }

        @IsTest
    private static void retrieveItemMapTest() {
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

        json = '{"documentId":"' + cd.Id + '","entityId":"' + a.Id + '","text":"new_file","folder":null,"icon":null,"id":null,"ownerId":null,"owner":null,"userType":"Standard","size":0,"tags":null,"type":null}';
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

    @IsTest
    private static void given_comeParameters_when_aFolderConstructorIsCalledWithInvalidParameters_then_instanceParametersAreSet() {
        qsyd_FolderTemplate template;

        Test.startTest();

        template = new qsyd_FolderTemplate('templateId', 'entityId', 'folderId');

        Test.stopTest();

        System.assertEquals(null, template.templateId);
        System.assertEquals(null, template.entityId);
        System.assertEquals(null, template.folderId);
    }

    @IsTest
    private static void given_comeParameters_when_aFolderConstructorIsCalledWithValidParameters_then_instanceParametersAreSet() {
        qsyd_FolderTemplate template;

        Test.startTest();

        template = new qsyd_FolderTemplate('a000a0000000000000', 'a000a0000000000001', 'a000a0000000000002');

        Test.stopTest();

        System.assertEquals('a000a0000000000000', template.templateId);
        System.assertEquals('a000a0000000000001', template.entityId);
        System.assertEquals('a000a0000000000002', template.folderId);
    }

    @IsTest
    private static void given_someTemplateParameters_when_aListIsRequested_then_activeTemplatesAreReturned() {
        qsyd_FolderTemplate.qsyd_PaginatedFolderTemplates paginatedTemplates;
        String filter = 'plate';
        String sortBy = 'Label__c';
        Integer pageSize = 2;
        Integer pageOffset = 0;

        // Setup
        List<FileExplorerFolderTemplate__c> templates = new List<FileExplorerFolderTemplate__c>{
                new FileExplorerFolderTemplate__c(Label__c = 'Template 1', Description__c = 'Template 1 description', IsActive__c = TRUE),
                new FileExplorerFolderTemplate__c(Label__c = 'Template 2', Description__c = 'Template 2 description', IsActive__c = TRUE),
                new FileExplorerFolderTemplate__c(Label__c = 'Template 3', Description__c = 'Template 3 description', IsActive__c = TRUE),
                new FileExplorerFolderTemplate__c(Label__c = 'Template 4', Description__c = 'Template 4 description', IsActive__c = FALSE),
                new FileExplorerFolderTemplate__c(Label__c = 'Template 5', Description__c = 'Template 5 description', IsActive__c = TRUE),
                new FileExplorerFolderTemplate__c(Label__c = 'Template 6', Description__c = 'Template 6 description', IsActive__c = TRUE)
        };

        INSERT templates;

        Test.startTest();

        paginatedTemplates = (qsyd_FolderTemplate.qsyd_PaginatedFolderTemplates) JSON.deserialize(qsydFileExplorerController.getTemplates(filter, sortBy, pageSize, pageOffset), qsyd_FolderTemplate.qsyd_PaginatedFolderTemplates.class);
        paginatedTemplates = (qsyd_FolderTemplate.qsyd_PaginatedFolderTemplates) JSON.deserialize(qsydFileExplorerController.getTemplates(filter, sortBy, pageSize, paginatedTemplates.pageOffset), qsyd_FolderTemplate.qsyd_PaginatedFolderTemplates.class);
        paginatedTemplates = (qsyd_FolderTemplate.qsyd_PaginatedFolderTemplates) JSON.deserialize(qsydFileExplorerController.getTemplates(filter, sortBy, pageSize, paginatedTemplates.pageOffset), qsyd_FolderTemplate.qsyd_PaginatedFolderTemplates.class);

        Test.stopTest();

        System.assertEquals(-1, paginatedTemplates.pageOffset);
        System.assertEquals(1, paginatedTemplates.records.size());
    }

    @IsTest
    private static void given_aRecord_when_aTemplateIsProvided_then_aCloneOfThatTemplateIsMade() {
        String folderId = null;
        List<FileExplorerFolder__c> folders;

        // Setup
        Account acme = new Account(Name = 'Acme');
        INSERT acme;

        FileExplorerFolderTemplate__c template = new FileExplorerFolderTemplate__c(Label__c = 'Template 1', Description__c = 'Template 1 description', IsActive__c = TRUE);
        INSERT template;

        FileExplorerFolder__c parentFolder = new FileExplorerFolder__c(LinkedEntityId__c = template.Id, Label__c = 'parent');
        INSERT parentFolder;

        FileExplorerFolder__c childFolder = new FileExplorerFolder__c(LinkedEntityId__c = template.Id, Label__c = 'child', Folder__c = parentFolder.Id);
        INSERT childFolder;

        Test.startTest();

        qsydFileExplorerController.cloneTemplate(template.Id, acme.Id, folderId);

        childFolder = [
                SELECT Id,
                        Folder__c
                FROM FileExplorerFolder__c
                WHERE LinkedEntityId__c = :acme.Id
                AND Label__c = 'child'
                LIMIT 1
        ][0];

        parentFolder = [
                SELECT Label__c
                FROM FileExplorerFolder__c
                WHERE LinkedEntityId__c = :acme.Id
                AND Id = :childFolder.Folder__c
                LIMIT 1
        ][0];

        Test.stopTest();
        System.assertEquals('parent', parentFolder.Label__c);
    }
}