/*
 * uNav http://launchpad.net/unav
 * Copyright (C) 2015-2018 Marcos Alvarez Costales https://launchpad.net/~costales
 * Copyright (C) 2015-2016 JkB https://launchpad.net/~joergberroth
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
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "components"

Page {
    id: searchPage

    property string favLat
    property string favLng
    property string favName

    Component.onCompleted: {
        mainPageStack.executeJavaScript("qml_set_route_status();")
    }

    Component.onDestruction: {
        // Hide 2nd column when returning to the map to avoid an empty white column
        if (mainPageStack.columns === 1)
            mainPageStack.hideSideBar()
    }

    // This connection is needed to add a favorite from the search results returned
    // when the user searches for a location.
    Connections {
        target: mainLoader.item
        onFavorited: {
            searchPage.favLat = lat
            searchPage.favLng = lng
            searchPage.favName = name
            addFavorite()
        }
    }

    function addFavorite() {
        typeSections.selectedIndex = 1
        mainLoader.item.lat = favLat
        mainLoader.item.lng = favLng
        mainLoader.item.favName = favName
        mainLoader.item.addPOIFromPopup()
    }

    header: UNavHeader {
        id: standardHeader

        flickable: typeSections.selectedIndex !== 2 ? mainLoader.item.flickable : null

        contents: Label {
            textSize: Label.Large
            color: "White"
            font.weight: Font.Light
            text: i18n.tr("Search")
            verticalAlignment: Text.AlignVCenter
            width: parent.width; height: units.gu(4)
            anchors.verticalCenter: parent.verticalCenter
        }

        trailingActionBar.actions: [
            CloseHeaderAction {},

            Action {
                id: actionButton
                iconSource: Qt.resolvedUrl("../nav/img/header/favorite-new.svg")
                shortcut: "Ctrl+N"
                visible: typeSections.selectedIndex === 1
                text: i18n.tr("Add Favorite")
                onTriggered: {
                    addActionList.show()
                }
            }
        ]

        extension: UNavPageSection {
            id: typeSections
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            // TRANSLATORS: These are section headers. Please keep their translations short and not
            // longer than their original string lengths.
            model: [i18n.tr("Location"), i18n.tr("Favorites"), i18n.tr("Coordinates")]
            selectedIndex: navApp.settings.lastSearchOption

            onSelectedIndexChanged: {
                navApp.settings.lastSearchOption = selectedIndex;
                if (selectedIndex !== 1) {
                    addActionList.hide()
                }
            }
        }
    }

    Loader {
        id: mainLoader
        anchors { top: typeSections.selectedIndex !== 2 ? parent.top : standardHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        source: {
            if (typeSections.selectedIndex === 0) {
                return Qt.resolvedUrl("Location.qml")
            } else if (typeSections.selectedIndex === 1) {
                return Qt.resolvedUrl("Favorites.qml")
            } else if (typeSections.selectedIndex === 2) {
                return Qt.resolvedUrl("Coordinate.qml")
            } else {
                return ""
            }
        }
    }

    ActionSelectionPopover {
        id: addActionList

        width: units.gu(25)
        anchors {
            top: parent.top
            right: parent.right
            rightMargin: units.gu(0.5)
            topMargin: searchPage.header.height
        }

        delegate: ListItem {
            Label {
                text: action.text
                elide: Text.ElideMiddle
                opacity: action.enabled ? 1.0 : 0.5
                anchors { left: parent.left; right: parent.right; margins: units.gu(2); verticalCenter: parent.verticalCenter }
            }
        }

        actions: ActionList {
            Action {
                text: i18n.tr("Add Current Position")
                enabled: (mainPageStack.center_onpos !== 0 && mainPageStack.currentLat !== "null" && mainPageStack.currentLng !== "null")
                onTriggered: {
                    mainLoader.item.lat = mainPageStack.currentLat;
                    mainLoader.item.lng = mainPageStack.currentLng;
                    mainLoader.item.addFavoriteDialog()
                    addActionList.hide();
                }
            }
            Action {
                text: i18n.tr("Add Current Destination")
                enabled: (mainPageStack.routeState !== 'no')
                onTriggered: {
                    mainLoader.item.lat = mainPageStack.endLat;
                    mainLoader.item.lng = mainPageStack.endLng;
                    mainLoader.item.addFavoriteDialog()
                    addActionList.hide();
                }

            }
            Action {
                visible: mainPageStack.columns === 1
                text: i18n.tr("Add by clicking on Map")
                onTriggered: {
                    mainPageStack.removePages(searchPage)
                }
            }
        }
    }
}

