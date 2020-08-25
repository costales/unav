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
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0
import "../components"

Item {
    id: container
    anchors.fill: parent

    property ListView flickable: listView

    Component.onCompleted: {
        if (mainPageStack.lastSearchResultsOffline) {
            var json = JSON.parse(mainPageStack.lastSearchResultsOffline);
            searchModel.loadList(json.result);
        }
    }

    ListModel {
        id: searchModel

        function loadList (json) {
            searchModel.clear();
            for (var i = 0; i < json.length; i++) {
                var item = {
                    "title": json[i].title,
                    "lng": json[i].lng,
                    "lat": json[i].lat
                };
                searchModel.append(item);
            }
        }
    }

    Column {
        id: notFound
        visible: statusLabel.text != ""
        anchors.centerIn: parent
        spacing: units.gu(1)
        Row {
            anchors.horizontalCenter: notFound.horizontalCenter
            Label {
                id: statusLabel
            }
        }
    }

    ListView {
        id: listView

        clip: true
        anchors { fill: parent; topMargin: units.gu(2) }
        model: searchModel
        delegate: ListItem {
            height: resultsDelegateLayout.height + divider.height
            ListItemLayout {
                id: resultsDelegateLayout
                title.text: model.title
                title.maximumLineCount: 2
                title.wrapMode: Text.WordWrap
                subtitle.text: " "
                subtitle.visible: true
            }
            onClicked: {
                if (mainPageStack.columns === 1)
                    mainPageStack.removePages(mainPageStack.primaryPage)
                mainPageStack.executeJavaScript("import_marker(" + model.lng + "," + model.lat + ",\"" + model.title + "\")");
            }
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
            text: navApp.settings.lastSearchString
            placeholderText: i18n.tr("Place or location")

            onTriggered: {
                if (text.trim()) {
                    searchModel.clear();
                    statusLabel.text = i18n.tr("Searching...");
                    searchJSON(text);
                }
            }
            onTextChanged: {
                navApp.settings.lastSearchString = text;
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        contentItem: listView
    }

    function searchJSON(text) {
        var request = new XMLHttpRequest();
        request.open("GET", "http://localhost:8553/v2/search?search="+text, false);
        request.setRequestHeader("Content-Type", 'application/json');

        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE) {
                statusLabel.text = "";
                var json = JSON.parse(request.responseText);
                if (json.result.length > 0) {
                    mainPageStack.lastSearchResultsOffline = request.responseText;
                    searchModel.loadList(json.result);
                }
                else {
                    mainPageStack.lastSearchResultsOffline = "";
                    statusLabel.text = i18n.tr("Nothing found");
                }
            }
        }
        request.onerror = function () {
            mainPageStack.lastSearchResultsOffline = "";
            statusLabel.text = i18n.tr("Time out!");
        };
        request.send();
    }
}