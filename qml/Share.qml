/*
 * uNav http://launchpad.net/unav
 * Copyright (C) 2015-2018 Marcos Alvarez Costales https://launchpad.net/~costales
 * Copyright (C) 2016 Nekhelesh Ramananthan https://launchpad.net/~nik90
 *
 * uNav is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 * 
 * uNav is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

import QtQuick 2.4
import Ubuntu.Content 1.3
import Ubuntu.Components 1.3
import "components"

Page {
    id: picker

    property var lat
    property var lon

    // Property to indicate if the share page was opened directly (from a popup)
    // or as a child (from the search page)
    property bool isParentPage: false

    header: UNavHeader {
        title: i18n.tr("Share location to")

        trailingActionBar.actions: CloseHeaderAction {
            visible: mainPageStack.columns !== 1 && isParentPage
        }
    }

    Component.onDestruction: {
        // Hide 2nd column when returning to the map to avoid an empty white column
        if (mainPageStack.columns === 1 && isParentPage)
            mainPageStack.hideSideBar()
    }

    Component {
        id: resultComponent
        ContentItem {}
    }

    ContentPeerPicker {
        id: peerPicker

        showTitle: false
        contentType: ContentType.Links
        handler: ContentHandler.Share

        anchors.topMargin: picker.header.height

        onCancelPressed: {
            // Do not pop the share page when in a 2-column layout as it will leave
            // an empty second column
            if (mainPageStack.columns === 1) {
                mainPageStack.removePages(picker)
            }
        }

        onPeerSelected: {
            var request = peer.request();
            switch (navApp.settings.shareMap) {
                case 0:
                    var url2shared = 'http://map.unav.me?' + parseFloat(picker.lat).toFixed(5) + ',' + parseFloat(picker.lon).toFixed(5);
                    break;
                case 1:
                    var url2shared = 'https://www.google.com/maps/search/?api=1&query=' + parseFloat(picker.lat).toFixed(5) + ',' + parseFloat(picker.lon).toFixed(5);
                    break;
                case 2:
                    var url2shared = 'geo:' + parseFloat(picker.lat).toFixed(5) + ',' + parseFloat(picker.lon).toFixed(5);
                    break;
            }
            request.items = [ resultComponent.createObject(navApp.mainPageStack, {"url": url2shared}) ];
            request.state = ContentTransfer.Charged;
            // Do not pop the share page when in a 2-column layout as it will leave
            // an empty second column
            if (mainPageStack.columns === 1) {
                mainPageStack.removePages(picker)
            }
        }
    }
}
