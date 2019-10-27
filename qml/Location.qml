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
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0
import "js/utils.js" as QmlJs
import "js/db.js" as UnavDB
import "components"

Item {
    id: container

    signal favorited(string lat, string lng, string name)

    property ListView flickable: listView

    //OSMTouch Model:
    XmlListModel {
        id: xmlSearchModel

        onStatusChanged: {
            if (status === XmlListModel.Loading) {
                historyModel.clear();
            }

            if (status === XmlListModel.Error) {
                historyModel.clear();
                colHistory.visible = false;
                statusLabel.text = i18n.tr("Time out! Please try again");
                notFound.visible = true;
            }

            else if (status === XmlListModel.Ready && count === 0) {
                historyModel.clear();
                colHistory.visible = false;
                //TRANSLATORS: This string is search shown when no POIs are found with the chosen search radius.
                statusLabel.text = i18n.tr("Sorry, nothing found. Try another search")
                notFound.visible = true;
                listView.model = historyModel
                listView.delegate = historyDelegateComponent
            }

            else if (status === XmlListModel.Ready && count >> 0) {
                colHistory.visible = false;
                notFound.visible = false;
                sortedSearchModel.sortXmlList();
                listView.model = sortedSearchModel
                listView.delegate = searchDelegateComponent
            }
        }

        readonly property string searchUrl: "https://nominatim.openstreetmap.org/search?format=xml&email=costales.marcos@gmail.com&limit=50&q="
        property string searchString

        function search() {
            xmlSearchModel.clear();
            sortedSearchModel.clear();
            source = (searchUrl + searchString);
        }

        function clear() {
            source = "";
        }

        source: ""
        query: "/searchresults/place"

        XmlRole { name: "osm_type"; query: "@osm_type/string()"; }
        XmlRole { name: "osm_id"; query: "@osm_id/string()"; }
        XmlRole { name: "name"; query: "@display_name/string()"; isKey: true }
        XmlRole { name: "lat"; query: "@lat/string()"; isKey: true }
        XmlRole { name: "lng"; query: "@lon/string()"; isKey: true }
        XmlRole { name: "boundingbox"; query: "@boundingbox/string()"; isKey: true }
        XmlRole { name: "icon"; query: "@icon/string()"; isKey: true }
    }

    ListModel {
        id: sortedSearchModel

        function sortXmlList (){
            sortedSearchModel.clear()
            var item
            for (var i = 0; i < xmlSearchModel.count; i++) {
                item  = {
                    "osm_type": xmlSearchModel.get(i).osm_type.charAt(0).toUpperCase(),
                    "osm_id": xmlSearchModel.get(i).osm_id,
                    "name": xmlSearchModel.get(i).name,
                    "lat": xmlSearchModel.get(i).lat,
                    "lng": xmlSearchModel.get(i).lng,
                    "boundingbox": xmlSearchModel.get(i).boundingbox,
                    "icon": (xmlSearchModel.get(i).icon).replace('.p.20.png', '.p.32.png'),
                    "distance": QmlJs.calcPoiDistance(
                                    mainPageStack.currentLat,
                                    mainPageStack.currentLng,
                                    xmlSearchModel.get(i).lat,
                                    xmlSearchModel.get(i).lng,
                                    10
                                    )
                };
                if (i === 0) {
                    sortedSearchModel.append(item);
                } else { // sort model by distance
                    var j = 0;
                    while (j <= sortedSearchModel.count) {
                        if (j === sortedSearchModel.count) {
                            sortedSearchModel.append(item);
                            break;
                        } else if (item.distance < sortedSearchModel.get(j).distance){
                            sortedSearchModel.insert(j,item);
                            break;
                        } else {
                            j++;
                        }
                    }
                }
                xmlSearchModel.clear();
            }
        }
    }

    ListModel {
        id: historyModel
        function initialize() {
            historyModel.clear();
            var res = UnavDB.getSearchHistory();
            var len = res.rows.length;
            for (var i = 0; i < len; ++i) {
                historyModel.append({
                                        title: i18n.tr("Search history"),
                                        name:  res.rows.item(i).key,
                                        lat:   res.rows.item(i).lat,
                                        lng:   res.rows.item(i).lng
                                    });
            }
            res = UnavDB.getfavHistory();
            len = res.rows.length;
            for (i = 0; i < len; ++i) {
                historyModel.append({
                                        title: i18n.tr("Favorite history"),
                                        name:  res.rows.item(i).key,
                                        lat:   res.rows.item(i).lat,
                                        lng:   res.rows.item(i).lng
                                    });
            }
            res = UnavDB.getNearByHistory();
            len = res.rows.length;
            for (i = 0; i < len; ++i) {
                historyModel.append({
                                        title:   i18n.tr("Nearby history"),
                                        name:    i18n.tr(res.rows.item(i).type),
                                        en_name: res.rows.item(i).type,
                                        clause:  res.rows.item(i).clause
                                    });
            }
        }
        Component.onCompleted: initialize();
    }

    Column {
        id: colHistory
        visible: historyModel.count === 0 && xmlSearchModel.status !== XmlListModel.Loading
        anchors.centerIn: parent
        spacing: units.gu(1)
        Row {
            Icon {
                id: noFavoritesIcon
                height: units.gu(10)
                source: Qt.resolvedUrl("../nav/img/states/no_history.svg")
            }
        }
        Row {
            anchors.horizontalCenter: colHistory.horizontalCenter
            Label {
                wrapMode: Text.WordWrap
                text: navApp.settings.saveHistory ? i18n.tr("No history yet") : i18n.tr("History is disabled")
            }
        }
    }

    Column {
        id: notFound
        visible: false
        anchors.centerIn: parent
        spacing: units.gu(1)
        Row {
            anchors.horizontalCenter: notFound.horizontalCenter
            Icon {
                visible: statusLabel.text !== i18n.tr("Searching…")
                height: units.gu(15)
                source: Qt.resolvedUrl("../nav/img/states/not_found.svg")
            }
        }
        Row {
            anchors.horizontalCenter: notFound.horizontalCenter
            Label {
                id: statusLabel
            }
        }
    }

    // Indicator to show search activity
    ActivityIndicator {
        id: searchActivity
        anchors {
            bottom: statusLabel.top
            bottomMargin: units.gu (1)
            horizontalCenter: parent.horizontalCenter
        }
        running: xmlSearchModel.status === XmlListModel.Loading
    }

    ListView {
        id: listView

        clip: true
        anchors { fill: parent; topMargin: units.gu(2) }
        model: historyModel
        delegate: historyDelegateComponent

        section.property: "title"
        section.criteria: ViewSection.FullString
        section.delegate: ListItemHeader {
            title: section
        }

        header: TextField {
            id: searchField

            primaryItem: Icon {
                height: units.gu(2)
                name: "find"
            }

            anchors { left: parent.left; right: parent.right; margins: units.gu(2) }
            hasClearButton: true
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: i18n.tr("Search location")

            onTriggered: {
                if (text.trim()) {
                    statusLabel.text = i18n.tr("Searching…");
                    xmlSearchModel.searchString = text;
                    xmlSearchModel.search();
                } else {
                    searchField.text = "";
                }
            }

            onTextChanged: {
                if (!text.trim()) {
                    xmlSearchModel.clear();
                    sortedSearchModel.clear();
                }
            }
        }

        Scrollbar {
            visible: listView.model === sortedSearchModel
            flickableItem: listView
            align: Qt.AlignTrailing
        }
    }

    Component {
        id: searchDelegateComponent
        ListItem {
            height: resultsDelegateLayout.height + divider.height
            trailingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "send"
                        onTriggered: {
                            if (navApp.settings.saveHistory) {
                                UnavDB.saveToSearchHistory(model.name, model.lat, model.lng)
                            }
                            if (mainPageStack.columns === 1)
                                mainPageStack.removePages(mainPageStack.primaryPage)
                            mainPageStack.center_onpos = 2;
                            mainPageStack.routeState = 'yes'
                            mainPageStack.executeJavaScript("calc2coord(" + model.lat + "," + model.lng + ");")
                        }
                    },
                    Action {
                        iconName: "share"
                        onTriggered: {
                            mainPageStack.addPageToCurrentColumn(searchPage, Qt.resolvedUrl("Share.qml"), {"lat": model.lat, "lon": model.lng})
                        }
                    },
                    Action {
                        iconName: "non-starred"
                        onTriggered: {
                            container.favorited(model.lat, model.lng, model.name)
                        }
                    }
                ]
            }

            onClicked: {
                if (navApp.settings.saveHistory) {
                    UnavDB.saveToSearchHistory(model.name, model.lat, model.lng);
                }
                if (mainPageStack.columns === 1)
                    mainPageStack.removePages(mainPageStack.primaryPage)
                if (mainPageStack.center_onpos === 2)
                    mainPageStack.center_onpos = 1;
                mainPageStack.executeJavaScript("ui.markers_POI_set([{title: \"" + model.name + "\", lat: " + model.lat + ", lng: " + model.lng + ", osm_type: '" + model.osm_type + "', osm_id: " + model.osm_id + ", boundingbox: \"" + model.boundingbox + "\"}])");
            }

            ListItemLayout {
                id: resultsDelegateLayout

                title.text: model.name
                title.maximumLineCount: 2
                title.wrapMode: Text.WordWrap
                subtitle.text: QmlJs.formatDistance(model.distance, navApp.settings.unit)
                subtitle.visible: mainPageStack.currentLat !== "null" && mainPageStack.currentLng !== "null"

                Icon {
                    id: resIcon
                    height: units.gu(2.5)
                    width: height
                    visible: model.icon !== ""
                    source: model.icon ? model.icon : ""
                    SlotsLayout.position: SlotsLayout.Last
                }
            }
        }
    }

    Component {
        id: historyDelegateComponent
        ListItem {
            height: historyDelegateLayout.height + divider.height
            leadingActions:  ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"
                        onTriggered: {
                            switch (model.title) {
                            case i18n.tr("Search history"):
                                UnavDB.removeHistorySearch(model.name);
                                break;
                            case i18n.tr("Nearby history"):
                                UnavDB.removeHistoryNearby(model.en_name);
                                break;
                            case i18n.tr("Favorite history"):
                                UnavDB.removeHistoryFavorite(model.name);
                            }
                            historyModel.initialize();
                        }
                    }
                ]
            }

            trailingActions:  ListItemActions {
                actions: [
                    Action {
                        iconName: "send"
                        visible: model.title !== i18n.tr("Nearby history")
                        onTriggered: {
                            if (mainPageStack.columns === 1)
                                mainPageStack.removePages(mainPageStack.primaryPage)
                            mainPageStack.center_onpos = 2;
                            mainPageStack.routeState = 'yes';
                            mainPageStack.executeJavaScript("calc2coord("+ model.lat + "," + model.lng + ");");
                        }
                    },
                    Action {
                        iconName: "share"
                        visible: model.title !== i18n.tr("Nearby history")
                        onTriggered: {
                            mainPageStack.addPageToCurrentColumn(searchPage, Qt.resolvedUrl("Share.qml"), {"lat": model.lat, "lon": model.lng});
                        }
                    }
                ]
            }

            ListItemLayout {
                id: historyDelegateLayout

                title.text: model.name
                title.wrapMode: Text.WordWrap
                title.maximumLineCount: 2
                subtitle.text: QmlJs.formatDistance(QmlJs.calcPoiDistance(mainPageStack.currentLat, mainPageStack.currentLng, model.lat, model.lng, 10), navApp.settings.unit)
                subtitle.visible: model.title !== i18n.tr("Nearby history") && mainPageStack.currentLat !== "null" && mainPageStack.currentLng !== "null"

                Loader {
                    id: resultTypeIconLoader
                    SlotsLayout.position: SlotsLayout.First
                    SlotsLayout.overrideVerticalPositioning: true
                    anchors.verticalCenter: parent.verticalCenter
                    sourceComponent: model.title !== i18n.tr("Nearby history") ? resultTypeIconName : resultTypeIconSource
                }

                Component {
                    id: resultTypeIconName
                    Icon {
                        width: height
                        height: units.gu(2.5)
                        color: UbuntuColors.jet
                        name: {
                            if (model.title === i18n.tr("Search history"))
                                return "history"
                            if (model.title === i18n.tr("Favorite history"))
                                return "starred"
                            return "history"
                        }
                    }
                }

                Component {
                    id: resultTypeIconSource
                    Icon {
                        width: height
                        height: units.gu(2.5)
                        source: Qt.resolvedUrl("../nav/img/poi/" + model.en_name + ".svg")
                    }
                }

                Icon {
                    id: progressionIcon
                    height: units.gu(2.5)
                    name: "next"
                    visible: model.title === i18n.tr("Nearby history")
                    SlotsLayout.position: SlotsLayout.Last
                }
            }

            onClicked: {
                if (model.title === i18n.tr("Nearby history")) {
                    mainPageStack.addPageToCurrentColumn(searchPage, Qt.resolvedUrl("PoiListPage.qml"),
                                       {
                                           lat: mainPageStack.currentLat,
                                           lng: mainPageStack.currentLng,
                                           poiType: model.name,
                                           clause: model.clause,
                                           en_label: model.en_name,
                                           geoDistFactor: 5
                                       })
                } else {
                    if (mainPageStack.columns === 1)
                        mainPageStack.removePages(mainPageStack.primaryPage)
                    if (mainPageStack.center_onpos === 2)
                        mainPageStack.center_onpos = 1;
                    mainPageStack.executeJavaScript("ui.markers_POI_set([{ title: \"" + model.name + "\", lat: " + model.lat + ", lng: " + model.lng + ", boundingbox: \"" + model.boundingbox + "\"}])");
                }
            }
        }
    }
}

