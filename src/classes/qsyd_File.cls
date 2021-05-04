/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
 /**      
    Author:         Paul Lucas
    Company:        Salesforce
    Description:    qsyd_File
    Date:           20-Apr-2020

    History:
    When           Who                 What

    TODO:
 */

global virtual inherited sharing class qsyd_File extends qsyd_Item {
    public static final String FILES_KEY = 'files';
    public static final String SITE_PATH_PREFIX = !String.IsBlank(Site.getPathPrefix()) ? Site.getPathPrefix() : '';
    public static final String ASSETS_PATH = SITE_PATH_PREFIX.removeEndIgnoreCase('/s') + '/resource/filexplorer/assets/';

    private FileExplorerFile__c fileExplorerFile;

    global qsyd_File() {
    }

    global qsyd_File(Id id, Id folder, String label, String documentId, String entityId, String type, String ext, String owner, String tags, Decimal size, List<qsyd_Item> items) {
        super(id, folder, label, entityId, items);

        this.documentId = documentId;
        this.entityId = entityId;
        this.type = type;
        this.ext = ext;
        this.owner = owner;
        this.tags = tags;
        this.size = size;

        switch on this.type.toLowerCase() {
            when 'doc', 'docx', 'word_x' {
                this.icon = ASSETS_PATH + 'word.png';
            }
            when 'xls', 'xlsx', 'excel_x' {
                this.icon = ASSETS_PATH + 'excel.png';
            }
            when 'ai' {
                this.icon = ASSETS_PATH + 'illustrator.png';
            }
            when 'jpg', 'jpeg', 'svg', 'gif', 'png', 'tif' {
                this.icon = ASSETS_PATH + 'image.png';
            }
            when 'pdf' {
                this.icon = ASSETS_PATH + 'pdf.png';
            }
            when 'ps' {
                this.icon = ASSETS_PATH + 'photoshop.png';
            }
            when 'ppt', 'pptx', 'power_point_x' {
                this.icon = ASSETS_PATH + 'ppt.png';
            }
            when else {
                this.icon = ASSETS_PATH + 'doc.png';
            }
        }
    }

    global qsyd_File load(qsyd_Item item) {
        this.id = item.id;
        this.text = item.text;
        this.folder = item.folder;
        this.documentId = item.documentId;
        this.entityId = item.entityId;
        this.type = item.type;
        this.ext = item.ext;
        this.owner = item.owner;
        this.tags = item.tags;
        this.size = item.size;

        return this;
    }

    global qsyd_File convertToCanonical() {
        this.fileExplorerFile = new FileExplorerFile__c(Id = this.id, Label__c = this.text, Folder__c = this.folder, LinkedEntityId__c = this.entityId);

        return this;
    }

    global qsyd_File save() {
        this.accessDecision = Security.stripInaccessible(AccessType.UPSERTABLE,
                new List<FileExplorerFile__c>{
                        fileExplorerFile
                });

        try {
            UPSERT this.accessDecision.getRecords();
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, e.getMessage());
        }

        return this;
    }

    global qsyd_File remove() {

        return this;
    }
}