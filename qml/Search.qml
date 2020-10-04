/*
 * uNav https://github.com/costales/unav
 * Copyright (C) 2015-2020 Marcos Alvarez Costales https://costales.github.io
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

    Component.onCompleted: {
        mainPageStack.executeJavaScript("ui.topPanelsMargin(" + header.height + ")");
    }

    Component.onDestruction: {
        mainPageStack.hideSideBar();
        mainPageStack.executeJavaScript("ui.topPanelsMargin(" + mainPageStack.defaultHeaderHeight + ")");
    }

    header: UNavHeader {
        id: standardHeader

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
            CloseHeaderAction {}
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
            model: [i18n.tr("Places"), i18n.tr("POIs"), i18n.tr("Favorites"), i18n.tr("Simulate"), i18n.tr("Track"), i18n.tr("Coordinate")]
            selectedIndex: navApp.settings.lastSearchTab

            onSelectedIndexChanged: {
                navApp.settings.lastSearchTab = selectedIndex;
                if (selectedIndex !== 1) {
                    addActionList.hide()
                }
            }
        }
    }

    Loader {
        id: mainLoader
        anchors { top: (typeSections.selectedIndex == 3) ? standardHeader.bottom : standardHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        source: {
            switch(typeSections.selectedIndex) {
                case 0:
                    if (navApp.settings.onlineSearch)
                        return Qt.resolvedUrl("onlineLocation/Location.qml");
                    else
                        return Qt.resolvedUrl("offlineLocation/Location.qml");
                    break;
                case 1:
                    return Qt.resolvedUrl("POIs.qml");
                    break;
                case 2:
                    return Qt.resolvedUrl("Favorites.qml")
                    break;
                case 3:
                    return Qt.resolvedUrl("Simulate.qml")
                    break;
                case 4:
                    return Qt.resolvedUrl("GPX.qml")
                    break;
                case 5:
                    return Qt.resolvedUrl("Coordinate.qml")
                    break;
                default:
                    return '';
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
    }
}

