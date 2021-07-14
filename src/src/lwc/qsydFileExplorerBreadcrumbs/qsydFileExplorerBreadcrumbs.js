/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
 
import { LightningElement, api } from 'lwc';
import { item } from 'c/qsydFileExplorerCommon';
 
export default class QsydFileExplorerBreadcrumbs extends LightningElement {
    @api breadcrumbs;

    get truncatePath() {
        return this.breadcrumbsLength > 20 && this.breadcrumbs.length > 1;
    }

    get breadcrumbsLength() {
        if (this.breadcrumbs) {
            return this.breadcrumbs.reduce(function(sum, item) { return sum + item.text.length; }, 0);
        }
        return 0;
    }
    
    handleClick(e) {
        const clicked = e.target.getAttribute('data-item-id');
        let item;
        if (clicked == 'root') {
            item = {
                id : clicked
            };
        } else {
            item = this.breadcrumbs.find(({ id }) => id == clicked);
        }
        this.dispatchEvent(
            new CustomEvent('itemclick', { 
                detail: item
            })
        );
    }
}