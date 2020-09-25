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
import QtQuick.LocalStorage 2.0
import "js/db.js" as UnavDB
import "components"

Page {
    id: settingsPage

    Component.onDestruction: {
        // Hide 2nd column when returning to the map to avoid an empty white column
        if (mainPageStack.columns === 1)
            mainPageStack.hideSideBar();
    }

    header: UNavHeader {
        title: i18n.tr("Settings")
        flickable: flickable

        trailingActionBar.actions: [
            CloseHeaderAction {},

            Action {
                id: actionInfo
                iconName: "info"
                text: i18n.tr("About")
                onTriggered: mainPageStack.addPageToCurrentColumn(settingsPage, Qt.resolvedUrl("About.qml"))
            }
        ]
    }

    signal settingsChanged()

    ListModel {
        id: unitModel
        Component.onCompleted: initialize()
        function initialize() {
            unitModel.append({ "unit": i18n.tr("Kilometres"), "index": 0 })
            unitModel.append({ "unit": i18n.tr("Miles"), "index": 1 })

            unitList.subText.text = unitModel.get(navApp.settings.unit).unit
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: settingsColumn.height

        Column {
            id: settingsColumn

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

           ListItemHeader {
                id: mapListHeader
                title: i18n.tr("Map")
                color: theme.palette.normal.background
           }

            ListItem {
                height: navApp.settings.online ? mapOnline.height + divider.height : mapOnline.height + howToOfflineLabel.height + divider.height
                ListItemLayout {
                    id: mapOnline
                    title.text: i18n.tr("Online")
                    Switch {
                        id: mapOnlineSwitch
                        checked: navApp.settings.online
                        onClicked: {
                            navApp.settings.online = checked;
                            if (navApp.settings.online)
                                mainPageStack.executeJavaScript("settings.set_online(true);");
                            else
                                mainPageStack.executeJavaScript("settings.set_online(false);");
                        }
                        SlotsLayout.position: SlotsLayout.Last
                    }
                }

                Label {
                    id: howToOfflineLabel
                    text: "<a href='#'>" + i18n.tr("Instructions for offline mode") + "</a>"
                    visible: !navApp.settings.online
                    width: parent.width
                    height: units.gu(3)
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: units.gu(2)
                        rightMargin: units.gu(2)
                        bottom: parent.bottom
                        bottomMargin: units.gu(1)
                        topMargin: units.gu(2)
                    }
                    onLinkActivated: PopupUtils.open(stepsOfflineComponent);
                }
            }

           ExpandableListItem {
               id: unitList

               listViewHeight: units.gu(10)
               titleText.text: i18n.tr("Units")

               model: unitModel

               delegate: ListItem {
                    divider.visible: false
                    height: unitListItemLayout.height
                    ListItemLayout {
                        id: unitListItemLayout
                        title.text: model.unit
                        title.color: theme.palette.normal.backgroundSecondaryText
                        padding { top: units.gu(1); bottom: units.gu(1) }
                        Icon {
                            SlotsLayout.position: SlotsLayout.Trailing
                            width: units.gu(2)
                            name: "tick"
                            visible: navApp.settings.unit === model.index
                        }
                    }

                    onClicked: {
                        navApp.settings.unit = model.index;
                        mainPageStack.executeJavaScript("settings.set_unit(" + navApp.settings.unit + ")");
                        unitList.subText.text = unitModel.get(model.index).unit;
                        unitList.toggleExpansion();
                   }
               }
            }

            ListItemHeader {
                 id: navigationListHeader
                 title: i18n.tr("Navigation")
                 color: theme.palette.normal.background
            }

            ListItem {
                height: navApp.settings.rotateMap ? navRotate.height + divider.height : navRotate.height + divider.height + navRotateLabel.height
                ListItemLayout {
                    id: navRotate
                    title.text: i18n.tr("View optimized for car")
                    Switch {
                        id: navRotateSwitch
                        checked: navApp.settings.rotateMap
                        onClicked: {
                            navApp.settings.rotateMap = checked;
                            mainPageStack.executeJavaScript("settings.set_rotate_map(" + navApp.settings.rotateMap + ");");
                        }
                        SlotsLayout.position: SlotsLayout.Last
                    }
                }
                Label {
                    id: navRotateLabel
                    text: i18n.tr("Will rotate the marker and not the map")
                    visible: !navApp.settings.rotateMap
                    width: parent.width
                    height: units.gu(3)
                    wrapMode: Text.WordWrap
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: units.gu(2)
                        rightMargin: units.gu(2)
                        bottom: parent.bottom
                        bottomMargin: units.gu(1)
                        topMargin: units.gu(3)
                    }
                }
            }

            ListItem {
                height: navTolls.height + divider.height
                ListItemLayout {
                    id: navTolls
                    title.text: i18n.tr("Use roads with tolls")
                    Switch {
                        id: navTollsSwitch
                        checked: navApp.settings.tolls
                        onClicked: {
                            navApp.settings.tolls = checked;
                            mainPageStack.executeJavaScript("settings.set_tolls(" + navApp.settings.tolls + ");");
                        }
                        SlotsLayout.position: SlotsLayout.Last
                    }
                }
            }

            ListItem {
                height: navSpeak.height + divider.height
                ListItemLayout {
                    id: navSpeak
                    title.text: i18n.tr("Speak instructions")
                    Switch {
                        id: navSpeakSwitch
                        checked: navApp.settings.speak
                        onClicked: {
                            navApp.settings.speak = checked;
                            mainPageStack.executeJavaScript("settings.set_speak(" + navApp.settings.speak + ");");
                        }
                        SlotsLayout.position: SlotsLayout.Last
                    }
                }
            }

            ListItem {
                visible: navApp.settings.speak
                ListItemLayout {
                    title.text: i18n.tr("Download custom voices")
                }
                onClicked: mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("Voices.qml"))
            }
        }
    }

    Component {
        id: stepsOfflineComponent
        Dialog {
            id: stepsOffline
            title: i18n.tr("How to use uNav offline")
            Label {
                width: parent.width
                color: theme.palette.normal.backgroundSecondaryText
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                text: i18n.tr("<b>Step 1</b> Install") + " <a href='https://open-store.io/app/osmscout-server.jonnius'>OSM Scout Server</a>: " + i18n.tr("In its wizard, set profile to <i>Default</i>, disable <i>Automatic activation</i> and download a map.")
                onLinkActivated: Qt.openUrlExternally(link)
            }
            Label {
                width: parent.width
                color: theme.palette.normal.backgroundSecondaryText
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                text: i18n.tr("<b>Step 2</b> Install") + " <a href='https://open-store.io/app/ut-tweak-tool.sverzegnassi'>UT Tweak Tool</a>: " + i18n.tr("Set <i>Prevent app suspension</i> for OSM Scout Server.")
                onLinkActivated: Qt.openUrlExternally(link)
            }
            Label {
                width: parent.width
                color: theme.palette.normal.backgroundSecondaryText
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                text: i18n.tr("<b>Step with each use</b>: Launch OSM Scout Server before uNav.")
                onLinkActivated: Qt.openUrlExternally(link)
            }
            Button {
                text: i18n.tr("Close")
                onClicked: {
                    PopupUtils.close(stepsOffline)
                }
            }
        }
    }

}
