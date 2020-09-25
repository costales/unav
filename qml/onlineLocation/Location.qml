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
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0
import "../components"

Item {
    id: container
    anchors.fill: parent

    property ListView flickable: listView

    Component.onCompleted: {
        if (mainPageStack.lastSearchResultsOnline) {
            var json = JSON.parse(mainPageStack.lastSearchResultsOnline);
            sortedSearchModel.loadLastResults(json.results);
            listView.model = sortedSearchModel
            listView.delegate = searchDelegateComponent
        }
   }

    XmlListModel {
        id: xmlSearchModel

        onStatusChanged: {
            if (status === XmlListModel.Error) {
                mainPageStack.lastSearchResultsOnline = "";
                statusLabel.text = i18n.tr("Time out!");
                notFound.visible = true;
            }
            else if (status === XmlListModel.Ready && count === 0) {
                mainPageStack.lastSearchResultsOnline = "";
                statusLabel.text = i18n.tr("Nothing found")
                notFound.visible = true;
            }
            else if (status === XmlListModel.Ready && count >> 0) {
                notFound.visible = false;
                sortedSearchModel.sortXmlList();
                listView.model = sortedSearchModel
                listView.delegate = searchDelegateComponent
            }
        }

        readonly property string searchUrl: "https://nominatim.openstreetmap.org/search?format=xml&email=marcos.costales@gmail.com&q="
        property string searchString
        
        source: ""
        query: "/searchresults/place"

        XmlRole { name: "name"; query: "@display_name/string()"; isKey: true }
        XmlRole { name: "lat"; query: "@lat/string()"; isKey: true }
        XmlRole { name: "lng"; query: "@lon/string()"; isKey: true }
        XmlRole { name: "boundingbox"; query: "@boundingbox/string()"; isKey: true }
        XmlRole { name: "icon"; query: "@icon/string()"; isKey: true }

        function search() {
            xmlSearchModel.clear();
            sortedSearchModel.clear();
            source = (searchUrl + searchString);
        }

        function clear() {
            source = "";
        }
    }

    ListModel {
        id: sortedSearchModel

        function sortXmlList(){
            sortedSearchModel.clear();
            mainPageStack.lastSearchResultsOnline = '{ "results": [';
            for (var i = 0; i < xmlSearchModel.count; i++) {
                var item  = {
                    "name": xmlSearchModel.get(i).name,
                    "lat": xmlSearchModel.get(i).lat,
                    "lng": xmlSearchModel.get(i).lng,
                    "boundingbox": xmlSearchModel.get(i).boundingbox,
                    "icon": (xmlSearchModel.get(i).icon).replace('.p.20.png', '.p.32.png')
                };
                sortedSearchModel.append(item);
                if (i > 0)
                    mainPageStack.lastSearchResultsOnline = mainPageStack.lastSearchResultsOnline + ',';
                mainPageStack.lastSearchResultsOnline = mainPageStack.lastSearchResultsOnline + JSON.stringify(item);
            }
            xmlSearchModel.clear();
            mainPageStack.lastSearchResultsOnline = mainPageStack.lastSearchResultsOnline + "]}";
        }
        function loadLastResults(json_results) {
            sortedSearchModel.clear();
            for (var i = 0; i < json_results.length; i++) {
                var item  = {
                    "name": json_results[i].name,
                    "lat": json_results[i].lat,
                    "lng": json_results[i].lng,
                    "boundingbox": json_results[i].boundingbox,
                    "icon": json_results[i].icon
                };
                sortedSearchModel.append(item);
                xmlSearchModel.clear();
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
            Label {
                id: statusLabel
            }
        }
    }

    // Indicator to show search activity
    ActivityIndicator {
        id: searchActivity
        anchors.centerIn: parent
        running: xmlSearchModel.status === XmlListModel.Loading
    }

    ListView {
        id: listView

        clip: true
        anchors { fill: parent; topMargin: units.gu(2) }
        model: xmlSearchModel

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
            text: mainPageStack.lastSearchStringOnline
            placeholderText: i18n.tr("Place or location")

            onTriggered: {
                if (text.trim()) {
                    statusLabel.text = "";
                    xmlSearchModel.searchString = text;
                    xmlSearchModel.search();
                }
            }
            onTextChanged: {
                mainPageStack.lastSearchStringOnline = text;
                sortedSearchModel.clear();
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        contentItem: listView
    }

    Component {
        id: searchDelegateComponent
        ListItem {
            height: resultsDelegateLayout.height + divider.height
            onClicked: {
                if (mainPageStack.columns === 1)
                    mainPageStack.removePages(mainPageStack.primaryPage)
                mainPageStack.executeJavaScript("import_marker(" + model.lng + "," + model.lat + ",\"" + model.name + "\", \"" + model.boundingbox + "\")");
            }

            ListItemLayout {
                id: resultsDelegateLayout

                title.text: model.name
                title.maximumLineCount: 2
                title.wrapMode: Text.WordWrap

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
}

