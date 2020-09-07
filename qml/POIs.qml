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

Item {
    id: poiPage

    property var lat
    property var lng

    property ListView flickable: categoryList

    Component.onDestruction: {
        // Hide 2nd column when returning to the map to avoid an empty white column
        if (mainPageStack.columns === 1)
            mainPageStack.hideSideBar()
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
                        theme: i18n.tr("Last used"),
                        label: res.rows.item(i).label,
                        tag_online: res.rows.item(i).tag_online,
                        tag_offline: res.rows.item(i).tag_offline,
                        enabled_offline: res.rows.item(i).enabled_offline
                    }
                );
            }

        }
        Component.onCompleted: initialize()
    }


    SortFilterModel {
        id: sortedCategoryListModel
        model: categoryListModel
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
                    source: Qt.resolvedUrl("../nav/img/poi/" + model.label + ".svg")
                    height: units.gu(3)
                    width: height
                    SlotsLayout.position: SlotsLayout.First
                }

                title.text: i18n.tr(model.label)
                enabled: navApp.settings.online || model.enabled_offline == "yes"
                subtitle.text: i18n.tr("Available only online")
                subtitle.visible: !navApp.settings.online && model.enabled_offline == "no"
            }
            onClicked: {
                if (navApp.settings.online || model.enabled_offline == "yes") {
                    UnavDB.saveToNearByHistory(model.label, model.tag_online, model.tag_offline, model.enabled_offline);
                    if (mainPageStack.columns === 1)
                        mainPageStack.removePages(searchPage);
                    if (navApp.settings.online)
                        mainPageStack.executeJavaScript("set_search_poi(\"" + model.tag_online + "\",\"" + model.label + "\")");
                    else
                        mainPageStack.executeJavaScript("set_search_poi(\"" + model.tag_offline + "\",\"" + model.label + "\")");
                }
            }
        }
    }

    Scrollbar {
        flickableItem: categoryList
        align: Qt.AlignTrailing
    }
}

