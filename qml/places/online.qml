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
import Lomiri.Components 1.3
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0
import "../js/db.js" as UnavDB
import "../js/utils.js" as Utils
import "../components"

Item {
	id: searchOnline
	anchors.fill: parent

	property ListView flickable: listView

	signal setSearchText(string text)

	Component.onCompleted: {
		if (mainPageStack.lastSearchResultsOnline) {
			var json = JSON.parse(mainPageStack.lastSearchResultsOnline);
			sortedSearchModel.loadLastResults(json.results);
			listView.model = sortedSearchModel
			listView.delegate = searchDelegateComponent
		}
		else {
			if (mainPageStack.lastSearchStringOnline == "") {
				var res = UnavDB.getSearchHistory();
				var len = res.rows.length;
				for (var i = 0; i < len; ++i) {
					var item = {
						"name": res.rows.item(i).key,
						"lat": '',
						"lng": '',
						"boundingbox": '',
						"icon": '../../nav/img/search/history.svg'
					};
					sortedSearchModel.append(item);
				}
				listView.model = sortedSearchModel
				listView.delegate = searchDelegateComponent
			}
		}
   }

	Item {
		id: xmlSearchModel
		
		readonly property string searchUrl: "https://photon.komoot.io/api?q="
		property string searchString
		
		function search() {
			mainPageStack.lastSearchResultsOnline = "";
			statusLabel.text = "";
			sortedSearchModel.clear();
			searchActivity.running = true;
			
			var encodedSearch = encodeURIComponent(searchString);
			var fullUrl = searchUrl + encodedSearch + "&limit=50";
			console.log("Buscando con Photon API:", fullUrl);
			
			var xhr = new XMLHttpRequest();
			xhr.onreadystatechange = function() {
				if (xhr.readyState === XMLHttpRequest.DONE) {
					searchActivity.running = false;
					console.log("XHR Status:", xhr.status);
					if (xhr.status === 200) {
						try {
							var responseText = xhr.responseText;
							console.log("Response length:", responseText.length);
							
							var json = JSON.parse(responseText);
							var features = json.features || [];
							console.log("Found features:", features.length);
							
							if (features.length === 0) {
								statusLabel.text = i18n.tr("Nothing found");
								notFound.visible = true;
							} else {
								notFound.visible = false;
								var items = [];
								for (var i = 0; i < features.length; i++) {
									var feature = features[i];
									var props = feature.properties;
									var coords = feature.geometry.coordinates;
									var displayName = props.name || "";
									if (props.city) displayName += ", " + props.city;
									if (props.state) displayName += ", " + props.state;
									if (props.country) displayName += ", " + props.country;
									
									items.push({
										"name": displayName,
										"lat": String(coords[1]),
										"lng": String(coords[0]),
										"boundingbox": "",
										"icon": ""
									});
								}
								
								// Sort by distance if we have current position
								if (mainPageStack.currentLng != 'null' && mainPageStack.currentLat != 'null') {
									items.sort(function(a, b) {
										var distA = Utils.distance2points(
											mainPageStack.currentLng,
											mainPageStack.currentLat,
											a.lng,
											a.lat
										);
										var distB = Utils.distance2points(
											mainPageStack.currentLng,
											mainPageStack.currentLat,
											b.lng,
											b.lat
										);
										return parseFloat(distA) - parseFloat(distB);
									});
								}
								
								mainPageStack.lastSearchResultsOnline = '{ "results": [';
								for (var i = 0; i < items.length; i++) {
									sortedSearchModel.append(items[i]);
									if (i > 0)
										mainPageStack.lastSearchResultsOnline = mainPageStack.lastSearchResultsOnline + ',';
									mainPageStack.lastSearchResultsOnline = mainPageStack.lastSearchResultsOnline + JSON.stringify(items[i]);
								}
								mainPageStack.lastSearchResultsOnline = mainPageStack.lastSearchResultsOnline + "]}";
								
								listView.model = sortedSearchModel;
								listView.delegate = searchDelegateComponent;
							}
						} catch(e) {
							console.log("Error parseando respuesta:", e);
							statusLabel.text = i18n.tr("Time out!");
							notFound.visible = true;
						}
					} else {
						console.log("Error HTTP:", xhr.status);
						statusLabel.text = i18n.tr("Time out!");
						notFound.visible = true;
					}
				}
			};
			
			xhr.open("GET", fullUrl, true);
			xhr.send();
		}
		
		function clear() {
		}
	}

	ListModel {
		id: sortedSearchModel

		function sortXmlList(){
			sortedSearchModel.clear();
			var item = [];
			for (var i = 0; i < xmlSearchModel.count; i++) {
				item.push({
					"name": xmlSearchModel.get(i).name,
					"lat": xmlSearchModel.get(i).lat,
					"lng": xmlSearchModel.get(i).lng,
					"boundingbox": xmlSearchModel.get(i).boundingbox,
					"icon": (xmlSearchModel.get(i).icon).replace('.p.20.png', '.p.32.png'),
					"distance": Utils.distance2points(
                                    mainPageStack.currentLng,
                                    mainPageStack.currentLat,
                                    xmlSearchModel.get(i).lng,
                                    xmlSearchModel.get(i).lat
								)
				});
			}
			xmlSearchModel.clear();
			if (mainPageStack.currentLng != 'null' && mainPageStack.currentLat != 'null') {
				item.sort(function(a, b) { // Sort by distance
					return parseFloat(a.distance) - parseFloat(b.distance);
				});
			}
			mainPageStack.lastSearchResultsOnline = '{ "results": [';
			for (var i = 0; i < item.length; i++) {
				sortedSearchModel.append(item[i]);
				if (i > 0)
					mainPageStack.lastSearchResultsOnline = mainPageStack.lastSearchResultsOnline + ',';
				mainPageStack.lastSearchResultsOnline = mainPageStack.lastSearchResultsOnline + JSON.stringify(item[i]);
			}
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

			onVisibleChanged: {
				if (visible) {
					searchField.focus = true;
					searchField.cursorPosition = searchField.text.length
				}				
			}

			Connections {
				target: searchOnline
				onSetSearchText: {
					searchField.text = text;
				}
			}

			onTriggered: {
				if (text.trim()) {
					UnavDB.saveToSearchHistory(text);
					mainPageStack.lastSearchResultsOnline = "";
					statusLabel.text = "";
					xmlSearchModel.clear();
					xmlSearchModel.searchString = text;
					xmlSearchModel.search();
				}
			}
			onTextChanged: {
				if (text != mainPageStack.lastSearchStringOnline)
					mainPageStack.lastSearchResultsOnline = "";
				mainPageStack.lastSearchStringOnline = text;
				sortedSearchModel.clear();
				statusLabel.text = "";
				if (!text.trim()) {
					var res = UnavDB.getSearchHistory();
					var len = res.rows.length;
					for (var i = 0; i < len; ++i) {
						var item = {
							"name": res.rows.item(i).key,
							"lat": '',
							"lng": '',
							"boundingbox": '',
							"icon": '../../nav/img/search/history.svg'
						};
						sortedSearchModel.append(item);
					}
					listView.model = sortedSearchModel;
					listView.delegate = searchDelegateComponent;
					searchField.focus = true;
				}
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
			leadingActions: ListItemActions {
				actions: [
					Action {
						iconName: "delete"
						visible: model.lng === ''
						onTriggered: {
							UnavDB.removeHistorySearch(model.name);
							sortedSearchModel.remove(index, 1);
						}
					}
				]
			}
			trailingActions: ListItemActions {
				actions: [
				]
			}
			onClicked: {
				if (model.lng === '') { // History
					UnavDB.saveToSearchHistory(model.name);
					var text_aux = model.name;
					searchOnline.setSearchText(text_aux);
					mainPageStack.lastSearchResultsOnline = "";
					statusLabel.text = "";
					xmlSearchModel.searchString = text_aux;
					xmlSearchModel.search();
				}
				else { // Show marker
					if (mainPageStack.columns === 1)
						mainPageStack.removePages(searchPage);
					mainPageStack.executeJavaScript("import_marker(" + model.lng + "," + model.lat + ",\"" + model.name + "\", \"" + model.boundingbox + "\")");
				}
			}

			ListItemLayout {
				id: resultsDelegateLayout

				title.text: model.name
				title.maximumLineCount: 2
				title.wrapMode: Text.WordWrap
				title.color: model.lng === '' ? theme.palette.normal.backgroundTertiaryText : theme.palette.normal.backgroundText

				Icon {
					id: resIcon
					height: units.gu(2.5)
					width: height
					visible: model.icon !== ""
					source: model.icon ? model.icon : ""
					SlotsLayout.position: SlotsLayout.Last
					keyColor: "#010101"
    				color: theme.palette.normal.backgroundText
				}
			}
		}
	}
}

