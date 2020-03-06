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
import Ubuntu.Components.Popups 1.3
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0
import "components"
import "js/PoiCategories.js" as Categories
import "js/db.js" as UnavDB

Page {
    id: poiQuickAccessPage

    property string unit: navApp.settings.unit === 0 ? "km" : "mi"
    property var factorList: ["1", "5", "15", "30", "50"]

    readonly property int maxQuickAccessItems: 5

    property string mode: "Car"

    Component.onCompleted: {
        switch (navApp.settings.routingMode) {
        case 0:
            poiQuickAccessPage.mode = "Car";
            break;
        case 1:
            poiQuickAccessPage.mode = "Walk";
            break;
        case 2:
            poiQuickAccessPage.mode = "Bike";
            break;
        }
        categoryListModel.initialize()
    }

    Component.onDestruction: {
        // Hide 2nd column when returning to the map to avoid an empty white column
        if (mainPageStack.columns === 1)
            mainPageStack.hideSideBar()
    }

    header: UNavHeader {
        id: poiQuickAccessHeader

        flickable: categoryList

        title: i18n.tr("Fast Nearest Editor: ") + i18n.tr(mode)

        trailingActionBar {
            actions: [
                CloseHeaderAction {}
            ]
        }

        extension: UNavPageSection {
            id: distanceSections
            anchors {
                left: parent.left
                bottom: parent.bottom
            }

            model: [factorList[0]+unit, factorList[1]+unit, factorList[2]+unit, factorList[3]+unit, factorList[4]+unit]
            selectedIndex: 1
        }
    }

    ListModel {
        id: categoryListModel
        property var indices: []
        property var distances: []
        function initialize() {
            categoryListModel.clear();
            categoryListModel.indices = [];
            categoryListModel.distances = [];
            var res = UnavDB.getQuickAccessItems(poiQuickAccessPage.mode);
            var len = res.rows.length;
            for ( var i = 0; i < len; ++i) {
                categoryListModel.indices.push( res.rows.item(i).type )
                categoryListModel.distances.push( res.rows.item(i).distance )
            }
            Categories.data.forEach( function(category) {
                categoryListModel.append(category);
            });
        }
    }

    SortFilterModel {
        id: sortedCategoryListModel
        model: categoryListModel
        filter.property: "label"
        filter.pattern: RegExp("", "gi")
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
            divider.visible: true
            height: poiItemLayout.height

            ListItemLayout {
                id: poiItemLayout
                title.text: label

                Icon {
                    source: Qt.resolvedUrl("../nav/img/poi/" + model.en_label + ".svg")
                    height: units.gu(2.5)
                    width: height
                    SlotsLayout.position: SlotsLayout.Leading
                }

                Item {
                    id: quickAccesslabel
                    SlotsLayout.overrideVerticalPositioning: true
                    anchors.verticalCenter: parent.verticalCenter
                    height: quickAccessBGIcon.height
                    width: quickAccessBGIcon.width
                    visible: quickAccessCheckBox.checked

                    Label {
                        id: quickAccessDistancelabel
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        text: !quickAccessCheckBox.checked ? "" : categoryListModel.distances[ categoryListModel.indices.indexOf(model.en_label) ] + unit
                    }

                    Icon {
                        id: quickAccessBGIcon
                        source: "../nav/img/header/radius.svg"
                        anchors.horizontalCenter: quickAccessDistancelabel.horizontalCenter
                        width: !quickAccessCheckBox.checked ? 0 : units.gu(4.5 + 4/45*categoryListModel.distances[ categoryListModel.indices.indexOf(model.en_label) ])
                        height: width
                        opacity: 0.15
                    }
                }

                CheckBox {
                    id: quickAccessCheckBox
                    checked: categoryListModel.indices.indexOf(model.en_label) > -1
                    SlotsLayout.position: SlotsLayout.Last
                    onClicked: {
                        var count = UnavDB.countQuickAccessItems(poiQuickAccessPage.mode).rows.item(0).count;
                        if (!quickAccessCheckBox.checked) {
                            UnavDB.removeQuickAccessItem( poiQuickAccessPage.mode, model.en_label )
                        } else if (quickAccessCheckBox.checked && count >= poiQuickAccessPage.maxQuickAccessItems ){
                            quickAccessCheckBox.checked = false;
                            PopupUtils.open(maxSelectedDialogComponent);
                        } else if (quickAccessCheckBox.checked && count < poiQuickAccessPage.maxQuickAccessItems ){
                            UnavDB.saveToQuickAccessItem(poiQuickAccessPage.mode, model.en_label, model.clause, factorList[header.extension.selectedIndex])
                            categoryListModel.initialize()
                        }
                    }
                }
            }
        }
    }

    Scrollbar {
        flickableItem: categoryList
        align: Qt.AlignTrailing
    }

    Component {
        id: maxSelectedDialogComponent
        Dialog {
            id: maxSelectedDialog
            title: i18n.tr("Selection")
            //TRANSLATORS: argument is a number > 1.
            text: i18n.tr("Max. %1 POIs can be selected.").arg(poiQuickAccessPage.maxQuickAccessItems)

            Button {
                text: i18n.tr("OK")
                color: UbuntuColors.orange
                onClicked: PopupUtils.close(maxSelectedDialog);
            }
        }
    }
}

