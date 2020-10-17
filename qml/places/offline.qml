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
import "../js/db.js" as UnavDB
import "../components"

Item {
	id: searchOffline
	anchors.fill: parent

	property ListView flickable: listView
	property bool searching: false

	signal setSearchText(string text)

	Component.onCompleted: {
		if (mainPageStack.lastSearchResultsOffline) {
			var json = JSON.parse(mainPageStack.lastSearchResultsOffline);
			searchModel.loadList(json.result);
		}
		else {
			if (mainPageStack.lastSearchStringOffline == "") {
				var res = UnavDB.getSearchHistory();
				var len = res.rows.length;
				for (var i = 0; i < len; ++i) {
					var item = {
						"title": res.rows.item(i).key,
						"lng": 0.0,
						"lat": 0.0
					};
					searchModel.append(item);
				}
			}
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

	// Indicator to show search activity
	ActivityIndicator {
		id: searchActivity
		anchors.centerIn: parent
		running: searchOffline.searching
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
			leadingActions: ListItemActions {
				actions: [
					Action {
						iconName: "delete"
						visible: model.lng === 0.0
						onTriggered: {
							UnavDB.removeHistorySearch(model.title);
							searchModel.remove(index, 1);
						}
					}
				]
			}
			trailingActions: ListItemActions {
				actions: [
				]
			}
			ListItemLayout {
				id: resultsDelegateLayout
				title.text: model.title
				title.maximumLineCount: 2
				title.wrapMode: Text.WordWrap
				subtitle.text: " "
				subtitle.visible: true
				title.color: model.lng === 0.0 ? theme.palette.normal.backgroundTertiaryText : theme.palette.normal.backgroundText
			}
			onClicked: {
				if (model.lng === 0.0) { // History
					var text_aux = model.title;
					searchOffline.setSearchText(text_aux);
					searchModel.clear();
					mainPageStack.lastSearchResultsOffline = "";
					statusLabel.text = "";
					searchJSON(text_aux);
				}
				else { // Show marker
					if (mainPageStack.columns === 1)
						mainPageStack.removePages(searchPage);
					mainPageStack.executeJavaScript("import_marker(" + model.lng + "," + model.lat + ",\"" + model.title + "\")");
				}
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
			text: mainPageStack.lastSearchStringOffline
			placeholderText: i18n.tr("Place or location")

			Connections {
				target: searchOffline
				onSetSearchText: {
					searchField.text = text;
				}
			}

			onTriggered: {
				if (text.trim()) {
					UnavDB.saveToSearchHistory(text);
					searchModel.clear();
					mainPageStack.lastSearchResultsOffline = "";
					statusLabel.text = "";
					searchJSON(text);
				}
			}
			onTextChanged: {
				if (text != mainPageStack.lastSearchStringOffline)
					mainPageStack.lastSearchResultsOffline = "";
				mainPageStack.lastSearchStringOffline = text;
				searchModel.clear();
				statusLabel.text = "";
				if (!text.trim()) {
					var res = UnavDB.getSearchHistory();
					var len = res.rows.length;
					for (var i = 0; i < len; ++i) {
						var item = {
							"title": res.rows.item(i).key,
							"lng": 0.0,
							"lat": 0.0
						};
						searchModel.append(item);
					}
				}
			}
		}
	}

	ScrollView {
		anchors.fill: parent
		contentItem: listView
	}

	function searchJSON(text) {
		searchOffline.searching = true;
		var request = new XMLHttpRequest();
		request.open("GET", "http://localhost:8553/v2/search?search="+text, true);
		request.setRequestHeader("Content-Type", 'application/json');

		request.onreadystatechange = function() {
			if (request.readyState == XMLHttpRequest.DONE) {
				searchOffline.searching = false;
				try {
					var json = JSON.parse(request.responseText);
					if (json.result.length > 0) {
						statusLabel.text = "";
						mainPageStack.lastSearchResultsOffline = request.responseText;
						searchModel.loadList(json.result);
					}
					else {
						mainPageStack.lastSearchResultsOffline = "";
						statusLabel.text = i18n.tr("Nothing found");
					}
				} catch(e) {
					mainPageStack.lastSearchResultsOffline = "";
					statusLabel.text = i18n.tr("Error searching");
				}
			}
		}
		request.onerror = function () {
			searchOffline.searching = false;
			mainPageStack.lastSearchResultsOffline = "";
			statusLabel.text = i18n.tr("Time out!");
		};
		request.send();
	}
}
