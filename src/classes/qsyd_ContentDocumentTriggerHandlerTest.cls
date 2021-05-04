/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


/**
    @author         Paul Lucas
    @company        Salesforce
    @description    qsyd_ContentDocumentTriggerHandlerTest
    @date           20-Apr-2020
        
    TODO:
 */
@IsTest
public with sharing class qsyd_ContentDocumentTriggerHandlerTest {
    static Account testAccount;
    static ContentVersion contentVersionInsert;

    @TestSetup
    private static void setupTestData() {
        // Insert an account
        testAccount = new Account(Name = 'Test Account');
        INSERT testAccount;

        contentVersionInsert = new ContentVersion(
                Title = 'Test1212',
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
        );

        INSERT contentVersionInsert;
    }

    @IsTest
    private static void initialiseSetupTestData() {

    }

    @IsTest
    private static void given_aContentDocumentIsUpdated_when_itCommits_then_aFileExplorerFileIsCreated() {

        initialiseSetupTestData();

        Test.startTest();

        List<FileExplorerFile__c> files = [
                SELECT Id
                FROM FileExplorerFile__c
        ];

        Test.stopTest();

        System.assertEquals(files.size(), 1);
    }

    @IsTest
    private static void given_aContentDocumentIsDeleted_when_itCommits_then_theAssociatedFileExplorerFileIsDeleted() {

        initialiseSetupTestData();

        Test.startTest();

        List<ContentDocument> cd = [
                SELECT Id
                FROM ContentDocument
        ];

        DELETE cd;

        List<FileExplorerFile__c> files = [
                SELECT Id
                FROM FileExplorerFile__c
        ];

        Test.stopTest();

        System.assertEquals(files.size(), 0);
    }
}