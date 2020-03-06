/*
 * GPS Navigation http://launchpad.net/unav
 * Copyright (C) 2015-2020 Marcos Alvarez Costales https://costales.github.io
 * Copyright (C) 2015-2016 JkB https://launchpad.net/~joergberroth
 * Copyright (C) 2016 Nekhelesh Ramananthan http://launchpad.net/~nik90
 *
 * GPS Navigation is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * GPS Navigation is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0
import "components"
import "js/PoiCategories.js" as Categories
import "js/db.js" as UnavDB

Page {
    id: poiPage

    property var lat
    property var lng
    property string unit: navApp.settings.unit === 0 ? "km" : "mi"
    property var factorList: ["1", "5", "15", "30", "50"]

    function goBackSearchMode() {
        categoryList.forceActiveFocus()
        poiHeader.isSearchMode = false
    }

    function goBackStandardMode() {
        mainPageStack.removePages(poiPage)
    }

    Keys.onEscapePressed: {
        !poiHeader.isSearchMode ? goBackStandardMode()
                                : goBackSearchMode()
    }

    Component.onDestruction: {
        // Hide 2nd column when returning to the map to avoid an empty white column
        if (mainPageStack.columns === 1)
            mainPageStack.hideSideBar()
    }

    header: UNavHeader {
        id: poiHeader

        property bool isSearchMode: false
        property alias searchField: contentLoader.item

        flickable: categoryList

        leadingActionBar.actions: Action {
            iconName: "back"
            text: i18n.tr("Back")
            visible: poiHeader.isSearchMode || mainPageStack.columns === 1
            onTriggered: {
                if (poiHeader.isSearchMode) {
                    goBackSearchMode()
                } else {
                    goBackStandardMode()
                }
            }
        }

        trailingActionBar.actions: [
            CloseHeaderAction {
                visible: mainPageStack.columns !== 1 && !poiHeader.isSearchMode
            },

            Action {
                id: searchAction
                iconName: "find"
                text: i18n.tr("Search")
                shortcut: "Ctrl+F"
                visible: !poiHeader.isSearchMode
                onTriggered: {
                    poiHeader.isSearchMode = true
                    poiHeader.searchField.forceActiveFocus()
                }
            }
        ]

        contents: Loader {
            id: contentLoader
            width: parent.width; height: units.gu(4)
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: poiHeader.isSearchMode ? searchFieldComponent : pageTitleComponent
        }

        extension: UNavPageSection {
            id: distanceSections
            anchors {
                left: parent.left
                bottom: parent.bottom
            }

            model: [factorList[0]+unit, factorList[1]+unit, factorList[2]+unit, factorList[3]+unit, factorList[4]+unit]
            selectedIndex: navApp.settings.defaultDistancePOI
            onSelectedIndexChanged: navApp.settings.defaultDistancePOI = distanceSections.selectedIndex;
        }
    }

    Component {
        id: searchFieldComponent
        TextField {
            hasClearButton: true
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: i18n.tr("Filter POI categories by name")
        }
    }

    Component {
        id: pageTitleComponent
        Label {
            textSize: Label.Large
            color: "White"
            font.weight: Font.Light
            text: i18n.tr("Nearby")
            verticalAlignment: Text.AlignVCenter
        }
    }

    ListModel {
        id: categoryListModel
        function initialize() {
            categoryListModel.clear();
            Categories.data.forEach( function(category) {
                categoryListModel.append(category);
            });

            var res = UnavDB.getNearByHistory();
            var len = res.rows.length;
            for ( var i = 0; i < len; ++i) {
                categoryListModel.insert(
                    i,
                    {
                        theme: i18n.tr("Most recent"),
                        label: i18n.tr(res.rows.item(i).type),
                        en_label: res.rows.item(i).type,
                        clause: res.rows.item(i).clause
                    }
                );
            }
        }
        Component.onCompleted: initialize()
    }


    SortFilterModel {
        id: sortedCategoryListModel
        model: categoryListModel
        filter.property: "label"
        filter.pattern: poiHeader.isSearchMode ? RegExp(poiHeader.searchField.text, "gi")
                                               : RegExp("", "gi")
    }

    ListView {
        id: categoryList

        model: sortedCategoryListModel
        anchors.fill: parent
        clip: true

        section.property: "theme"
        section.criteria: ViewSection.FullString
        section.labelPositioning: ViewSection.CurrentLabelAtStart + ViewSection.InlineLabels
        section.delegate: Rectangle {
            width: parent.width
            height: sectionHeader.height

            ListItemHeader {
                id: sectionHeader
                title: section
            }
        }

        delegate: ListItem {
            id: poiItem
            divider.visible: false
            height: poiItemLayout.height
            ListItemLayout {
                id: poiItemLayout

                Icon {
                    source: Qt.resolvedUrl("../nav/img/poi/" + model.en_label + ".svg")
                    height: units.gu(2.5)
                    width: height
                    SlotsLayout.position: SlotsLayout.First
                }

                title.text: label
                ProgressionSlot{}
            }
            onClicked: {
                if (poiHeader.isSearchMode) {
                    goBackSearchMode()
                }
                mainPageStack.addPageToCurrentColumn(poiPage, Qt.resolvedUrl("PoiListPage.qml"), {
                    lat: poiPage.lat,
                    lng: poiPage.lng,
                    poiType: model.label,
                    clause: model.clause,
                    en_label: model.en_label,
                    geoDistFactor: Number(factorList[distanceSections.selectedIndex])
                });
                if (navApp.settings.saveHistory) {
                    UnavDB.saveToNearByHistory(model.en_label, model.clause);
                }
            }
        }
    }

    Scrollbar {
        flickableItem: categoryList
        align: Qt.AlignTrailing
    }
}

