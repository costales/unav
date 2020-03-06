/*
 * uNav http://launchpad.net/unav
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
            mainPageStack.hideSideBar()
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
                onTriggered: mainPageStack.addPageToCurrentColumn(settingsPage, Qt.resolvedUrl("AboutPage.qml"))
            }
        ]
    }

    signal settingsChanged()

    ListModel {
        id: soundModel
        Component.onCompleted: initialize()
        function initialize() {
            soundModel.append({ "sound": i18n.tr("A voice"), "index": 0 })
            soundModel.append({ "sound": i18n.tr("A notification"), "index": 1 })
            soundModel.append({ "sound": i18n.tr("None"), "index": 2 })

            soundList.subText.text = soundModel.get(navApp.settings.soundIndications).sound
        }
    }

    ListModel {
        id: unitModel
        Component.onCompleted: initialize()
        function initialize() {
            unitModel.append({ "unit": i18n.tr("Kilometres"), "index": 0 })
            unitModel.append({ "unit": i18n.tr("Miles"), "index": 1 })

            unitList.subText.text = unitModel.get(navApp.settings.unit).unit
        }
    }

    ListModel {
        id: onlineLayerModel
        Component.onCompleted: initialize()
        function initialize() {
            onlineLayerModel.append({ "onlineLayer": "Carto Voyager",     "index": 0 })
            onlineLayerModel.append({ "onlineLayer": "Mapbox",            "index": 1 })
            onlineLayerModel.append({ "onlineLayer": "Stamen Terrain",    "index": 2 })
            onlineLayerModel.append({ "onlineLayer": "Stamen Toner Lite", "index": 3 })
            onlineLayerModel.append({ "onlineLayer": "OpenTopoMap",       "index": 4 })
            onlineLayerModel.append({ "onlineLayer": "Carto Positron",    "index": 5 })
            onlineLayerModel.append({ "onlineLayer": "Carto Dark Matter", "index": 6 })

            onlineLayerList.subText.text = onlineLayerModel.get(navApp.settings.onlineLayer).onlineLayer
        }
    }

    ListModel {
        id: shareMapModel
        Component.onCompleted: initialize()
        function initialize() {
            shareMapModel.append({ "shareMap": i18n.tr("uNav link"),         "index": 0 })
            shareMapModel.append({ "shareMap": i18n.tr("Google Maps link"),  "index": 1 })
            shareMapModel.append({ "shareMap": i18n.tr("Standard GEO link"), "index": 2 })

            shareMapList.subText.text = shareMapModel.get(navApp.settings.shareMap).shareMap
        }
    }

    ListModel {
        id: layerModel
        Component.onCompleted: initialize()
        function initialize() {
            layerModel.append({ "layer": i18n.tr("Online"), "index": 0 })
            layerModel.append({ "layer": i18n.tr("Offline"), "index": 1 })

            layerList.subText.text = layerModel.get(navApp.settings.layer).layer
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
                 id: navigationListHeader
                 title: i18n.tr("Navigation")
            }

            ExpandableListItem {
                id: soundList

                listViewHeight: units.gu(12+1)
                titleText.text: i18n.tr("Guidance")

                model: soundModel

                delegate: ListItem {
                    divider.visible: false
                    height: soundListItemLayout.height
                    ListItemLayout {
                        id: soundListItemLayout
                        title.text: model.sound
                        title.color: "#5D5D5D"
                        padding { top: units.gu(1); bottom: units.gu(1) }
                        Icon {
                            SlotsLayout.position: SlotsLayout.Trailing
                            width: units.gu(2)
                            name: "tick"
                            visible: navApp.settings.soundIndications === model.index
                        }
                    }

                    onClicked: {
                        navApp.settings.soundIndications = model.index
                        mainPageStack.executeJavaScript("settings.set_sound(" + model.index + ");")
                        soundList.subText.text = soundModel.get(navApp.settings.soundIndications).sound
                        soundList.toggleExpansion()
                    }
                }
            }

            ListItem {
                visible: navApp.settings.soundIndications === 0
                ListItemLayout {
                    title.text: i18n.tr("Download custom voices")
                }
                onClicked: mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("DownloadVoices.qml"))
            }

            ListItemHeader {
                 id: carListHeader
                 title: i18n.tr("Car Options")
            }

            ListItem {
                height: speedCameraLayout.height + divider.height
                ListItemLayout {
                    id: speedCameraLayout
                    title.text: i18n.tr("Speed camera alerts")
                    Switch {
                        id: radarsSwitch
                        checked: navApp.settings.alertRadars
                        onClicked: {
                            navApp.settings.alertRadars = checked;
                            mainPageStack.executeJavaScript("if (nav.get_route_status() != 'no'){nav.set_route_status('waiting4signal')}; settings.set_alert_radars(" + checked.toString() + ");");
                            if (navApp.settings.legalRadarShow) {
                                navApp.settings.legalRadarShow = false;
                                PopupUtils.open(confirmEnableRadar);
                            }
                        }
                        SlotsLayout.position: SlotsLayout.Last
                    }
                }
            }

           ListItemHeader {
                id: mapListHeader
                title: i18n.tr("Map")
            }

            ExpandableListItem {
                id: layerList
                height: howToMapsLabel.visible ? listViewHeight + units.gu(0.5) : listViewHeight
                listViewHeight: units.gu(9+1)
                titleText.text: i18n.tr("Mode")

                model: layerModel

                delegate: ListItem {
                    divider.visible: false
                    height: layerListItemLayout.height
                    ListItemLayout {
                        id: layerListItemLayout
                        title.text: model.layer
                        title.color: "#5D5D5D"
                        padding { top: units.gu(1); bottom: units.gu(1) }
                        Icon {
                            SlotsLayout.position: SlotsLayout.Trailing
                            width: units.gu(2)
                            name: "tick"
                            visible: navApp.settings.layer === model.index
                        }
                    }

                    onClicked: {
                        navApp.settings.layer = model.index
                        if (!model.index) {
                            mainPageStack.executeJavaScript("ui.set_map_layer(" + navApp.settings.onlineLayer + ")")
                        }
                        else {
                            mainPageStack.executeJavaScript("ui.set_map_layer(99)") // Independent of number of layers
                        }
                        layerList.subText.text = layerModel.get(navApp.settings.layer).layer
                        layerList.toggleExpansion()
                    }
                }

                Label {
                    id: howToMapsLabel
                    text: "<a href='http://unav.me/offline'>" + i18n.tr("How to use offline maps") + "</a>"
                    visible: navApp.settings.layer !== 0 && !layerList.expansion.expanded // Offline
                    width: parent.width
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        bottom: parent.bottom
                        bottomMargin: units.gu(1)
                    }
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }

           ExpandableListItem {
               id: onlineLayerList

               listViewHeight: units.gu(29+1)
               titleText.text: i18n.tr("Online style")

               model: onlineLayerModel
               visible: !navApp.settings.layer

               delegate: ListItem {
                   divider.visible: false
                   height: onlineLayerListItemLayout.height
                   ListItemLayout {
                       id: onlineLayerListItemLayout
                       title.text: model.onlineLayer
                       title.color: "#5D5D5D"
                       padding { top: units.gu(1); bottom: units.gu(1) }
                       Icon {
                           SlotsLayout.position: SlotsLayout.Trailing
                           width: units.gu(2)
                           name: "tick"
                           visible: navApp.settings.onlineLayer === model.index
                       }
                   }

                   onClicked: {
                        navApp.settings.onlineLayer = model.index
                        mainPageStack.executeJavaScript("ui.set_map_layer(" + model.index + ")")
                        onlineLayerList.subText.text = onlineLayerModel.get(navApp.settings.onlineLayer).onlineLayer
                        onlineLayerList.toggleExpansion()
                   }
               }
           }

           ExpandableListItem {
               id: unitList

               listViewHeight: units.gu(8+1)
               titleText.text: i18n.tr("Units")

               model: unitModel

               delegate: ListItem {
                   divider.visible: false
                   height: unitListItemLayout.height
                   ListItemLayout {
                       id: unitListItemLayout
                       title.text: model.unit
                       title.color: "#5D5D5D"
                       padding { top: units.gu(1); bottom: units.gu(1) }
                       Icon {
                           SlotsLayout.position: SlotsLayout.Trailing
                           width: units.gu(2)
                           name: "tick"
                           visible: navApp.settings.unit === model.index
                       }
                   }

                   onClicked: {
                       navApp.settings.unit = model.index
                       mainPageStack.executeJavaScript("settings.set_unit(\'" + ( model.index === 0 ? "km" : "mi" ) +"\');")
                       mainPageStack.executeJavaScript("ui.set_scale_unit(\'" + ( navApp.settings.unit === 0 ? "km" : "mi" ) +"\');")
                       unitList.subText.text = unitModel.get(navApp.settings.unit).unit
                       unitList.toggleExpansion()
                   }
               }
           }

           ExpandableListItem {
               id: shareMapList

               listViewHeight: units.gu(12+1)
               titleText.text: i18n.tr("Share position as")

               model: shareMapModel

               delegate: ListItem {
                   divider.visible: false
                   height: shareMapListItemLayout.height
                   ListItemLayout {
                       id: shareMapListItemLayout
                       title.text: model.shareMap
                       title.color: "#5D5D5D"
                       padding { top: units.gu(1); bottom: units.gu(1) }
                       Icon {
                           SlotsLayout.position: SlotsLayout.Trailing
                           width: units.gu(2)
                           name: "tick"
                           visible: navApp.settings.shareMap === model.index
                       }
                   }

                   onClicked: {
                        navApp.settings.shareMap = model.index
                        shareMapList.subText.text = shareMapModel.get(navApp.settings.shareMap).shareMap
                        shareMapList.toggleExpansion()
                   }
               }
           }

            ListItemHeader {
                id: privacyListHeader
                title: i18n.tr("History")
            }

            ListItem {
                height: storeSearchLayout.height + divider.height
                ListItemLayout {
                    id: storeSearchLayout
                    title.text: i18n.tr("Store new searches")
                    Switch {
                        id: saveHistorySwitch
                        checked: navApp.settings.saveHistory
                        onClicked: navApp.settings.saveHistory = checked
                        SlotsLayout.position: SlotsLayout.Last
                    }
                }
            }

            ListItem {
                ListItemLayout {
                    title.text: i18n.tr("Clear history")
                }
                onClicked: PopupUtils.open(confirmEraseHistory)
            }
        }

        Component {
            id: confirmEraseHistory
            Dialog {
                id: dialogueErase
                title: i18n.tr("Clear history")
                text: i18n.tr("You'll delete the current history")

                Button {
                    text: i18n.tr("Delete")
                    color: UbuntuColors.red
                    onClicked: {
                        UnavDB.dropHistoryTables();
                        PopupUtils.close(dialogueErase);
                    }
                }

                Button {
                     text: i18n.tr("Cancel")
                     onClicked: PopupUtils.close(dialogueErase)
                }
            }
        }

        Component {
            id: confirmEnableRadar
            Dialog {
                id: dialogueRadars
                title: i18n.tr("Speed Camera alerts and the law")
                text: i18n.tr("uNav is only reading the OpenStreetMap database.\nuNav will show a max speed notification and a Speed Camera marker (marker hidden for French users because of law).\n\nIn a few countries Speed Camera alerts are illegal, then enable this option only if it's legal in the country.")
                Label {
                    width: parent.width
                    color: UbuntuColors.slate
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: "<a href=\"http://people.ubuntu.com/~costales/unav/voices/speedcameras.html\">" + i18n.tr("Read more about it") + "</a>"
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Button {
                    text: i18n.tr("OK")
                    onClicked: PopupUtils.close(dialogueRadars);
                }
            }
        }
    }
}
