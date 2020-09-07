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
import QtMultimedia 5.0
import QtSystemInfo 5.0
import QtWebEngine 1.6
import Qt.labs.settings 1.0
import Ubuntu.Content 1.1
import Ubuntu.Components.Popups 1.3
import QtQuick.LocalStorage 2.0
import "components"
import "js/utils.js" as QmlJs
import "js/db.js" as UnavDB

MainView {
	id: navApp

	width: units.gu(50)
	height: units.gu(75)

	objectName: "navApp"
	applicationName: "navigator.costales"

	Component.onCompleted: {
		i18n.domain = "unav";
		i18n.bindtextdomain("unav", "nav/locales/mo");
	}

	property string applicationVersion: "3.0"
	property string mapUrl: "../nav/index.html"
	property string appUA: "Mozilla/5.0 (Linux; Android 5.0; Nexus 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.102 Mobile Safari/537.36 Project uNav"

	// Persistent settings:
	property var settings: Settings {
		property bool online: true
		property int unit: 0
		property bool rotateMap: true
		property string routeModes: "car"
		property bool speak: true
		property string speakVoice: 'Nathan Haines'
		property int lastSearchTab: 0
		property string lastLng: '4.666389'
		property string lastLat: '50.009167'
		property string lastZoom: '4'
        property string default_coord_0a: '51.506177'
        property string default_coord_1a: '-0.100236'
        property string default_coord_2a: '51'
        property string default_coord_2b: '30'
        property string default_coord_2c: '22.23'
        property string default_coord_2d: 'N'
        property string default_coord_3a: '0'
        property string default_coord_3b: '6'
        property string default_coord_3c: '0.84'
        property string default_coord_3d: 'W'
	}

	ScreenSaver {
		screenSaverEnabled: !Qt.application.active
	}

	AdaptivePageLayout {
		id: mainPageStack
		property int maxWidth: units.gu(125)
		property bool childPageOpened: false
		function showSideBar() {
			childPageOpened = true
		}
		function hideSideBar() {
			childPageOpened = false
		}
		anchors.fill: parent
		primaryPage: navigationPage
		layouts:[
			PageColumnsLayout {
				id: nonstandardlayout
				when: width >= mainPageStack.maxWidth && mainPageStack.childPageOpened
				PageColumn { // Column 0
					fillWidth: true
				}
				PageColumn { // Column 1
					minimumWidth: units.gu(30)
					maximumWidth: mainPageStack.maxWidth
					preferredWidth: units.gu(50)
				}
			}
		]

		property bool onLoadingExecuted: false
		property string importGPX: ''
		property string favLng: ""
		property string favLat: ""
		property string favName: ""
		property string lastSearchStringOnline: ''
		property string lastSearchStringOffline: ''
		property string lastSearchResultsOnline: ''
		property string lastSearchResultsOffline: ''

		property string usContext: "messaging://"
		function executeJavaScript(code) {
			_webview.runJavaScript(code);
		}

		Page {
			id: navigationPage
			anchors.fill: parent

			header: UNavHeader {
				id: header
				title: "uNav"

				leadingActionBar {
					width: 0
					visible: false
				}

				trailingActionBar {
					numberOfSlots: 2
					actions: [
						Action {
							id: actionSettings
							iconName: "settings"
							enabled: mainPageStack.onLoadingExecuted
							onTriggered: {
								mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("Settings.qml"));
								mainPageStack.showSideBar();
							}
						},
						Action {
							id: searchAction
							iconName: "find"
							shortcut: "Ctrl+F"
							enabled: mainPageStack.onLoadingExecuted
							onTriggered: {
								mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("Search.qml"));
								mainPageStack.showSideBar();
							}
						}
					]
				}
			}

			WebEngineProfile {
				id: webcontext
				httpUserAgent: navApp.appUA
			}

			WebEngineView {
				id: _webview
				zoomFactor: units.gu(1) / 8.4
				anchors.fill: parent
				profile: webcontext
				url: navApp.mapUrl
				settings.localContentCanAccessFileUrls: true
				settings.localContentCanAccessRemoteUrls: true
				settings.javascriptEnabled: true
				settings.accelerated2dCanvasEnabled: true
				settings.focusOnNavigationEnabled: true
				settings.webGLEnabled: true
				settings.allowWindowActivationFromJavaScript: true
				onNavigationRequested:{
					var url = request.url.toString().toLowerCase().split("/");
					switch (url[2]) {
						case "sharepos":
							mainPageStack.showSideBar();
							mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("Share.qml"), {"lng": url[3], "lat": url[4], "isParentPage": true});
							break;
						case "savefavorite":
							mainPageStack.favLng = parseFloat(url[3]).toFixed(5);
							mainPageStack.favLat = parseFloat(url[4]).toFixed(5);
							mainPageStack.favName = "";
							PopupUtils.open(newFavDialog);
							break;
						case "callphone":
							Qt.openUrlExternally("tel:///" + url[3]);
							break;
						case "openwebsite":
							var website = request.url.toString().replace('http://openwebsite/','');
                            Qt.openUrlExternally(website);
							break;
						case "sendemail":
                            Qt.openUrlExternally("mailto:" + url[3]);
							break;
						case "savelastpos":
							navApp.settings.lastLng = url[3];
							navApp.settings.lastLat = url[4];
							navApp.settings.lastZoom = url[5];
							break;
						case "routemode":
							navApp.settings.routeModes = url[3];
							break;
					}
					// Allow loading of file:// but dissallow http because it's used for navigation
					if (typeof url[0] != "undefined" && url[0].includes("http"))
						request.action = WebEngineNavigationRequest.IgnoreRequest;
				}

				onJavaScriptConsoleMessage: {
					var msg = "[JS] (%1:%2) %3".arg(sourceID).arg(lineNumber).arg(message)
				    console.log(msg)
				}
				
				Connections {
					onLoadingChanged: {
						if (loadRequest.status === WebEngineView.LoadSucceededStatus && !mainPageStack.onLoadingExecuted) {
							mainPageStack.onLoadingExecuted = true;
							
							// Restore settings into webview
							mainPageStack.executeJavaScript("settings.set_online(" + navApp.settings.online + ")");
							mainPageStack.executeJavaScript("settings.set_unit(" + navApp.settings.unit + ")");
							mainPageStack.executeJavaScript("settings.set_rotate_map(" + navApp.settings.rotateMap + ")");
							mainPageStack.executeJavaScript("settings.set_route_mode(\"" + navApp.settings.routeModes + "\")");
							mainPageStack.executeJavaScript("settings.set_speak(" + navApp.settings.speak + ")");
							mainPageStack.executeJavaScript("settings.set_speak_voice(\"" + navApp.settings.speakVoice + "\")");
							mainPageStack.executeJavaScript("mapUI.set_map_center(" + navApp.settings.lastLng + "," + navApp.settings.lastLat + ")");
							mainPageStack.executeJavaScript("mapUI.set_map_zoom(" + navApp.settings.lastZoom + ")");
							// Catching urls
							var coord = QmlJs.get_url_coord(Qt.application.arguments[1]);
							if (coord['lat'] !== null && coord['lng'] !== null) {
								mainPageStack.executeJavaScript("import_marker(" + coord['lng'] + "," + coord['lat'] + ")");
							}
							// Catching GPX
							if (mainPageStack.importGPX) {
								mainPageStack.executeJavaScript("import_gpx('" + mainPageStack.importGPX + "')");
								mainPageStack.importGPX = '';
							}
						}
					}
					onFeaturePermissionRequested: {
						console.log("grantFeaturePermission", feature)
						_webview.grantFeaturePermission(securityOrigin, feature, true);
					}
				}
			}
		}
	}
	
	// Pos import
	Connections {
		target: UriHandler
		onOpened: {
			if (uris.length > 0) {
				var coord = QmlJs.get_url_coord(uris[0]);
				if (coord['lat'] !== null && coord['lng'] !== null)
					mainPageStack.executeJavaScript("import_marker(" + coord['lng'] + "," + coord['lat'] + ")");
			}
		}
	}
	// GPX import
	Connections {
        target: ContentHub
        onImportRequested: {
			if (transfer.contentType == 0) {
				var filePath = String(transfer.items[0].url).replace('file://', '');
				if (filePath.toLowerCase().endsWith(".gpx")) {
					mainPageStack.importGPX = filePath;
					mainPageStack.executeJavaScript("import_gpx('" + mainPageStack.importGPX + "')");
				}
				else {
					mainPageStack.importGPX = '';
				}
			}
		}
	}

    Component {
         id: newFavDialog
         Dialog {
            id: newFav
            title: i18n.tr("Adding Favorite")
            
            property bool isOverwriteMode: false
         
			Component.onCompleted: favNameField.forceActiveFocus()

			function checkFavoriteExists() {
                var exist_fav = UnavDB.getFavorite(favNameField.text);
                if (exist_fav[0] === null || exist_fav[1] === null) {
                    return false;
                } else {
                    return true;
                }
            }

            TextField {
                id: favNameField
                width: parent.width
                hasClearButton: true
                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: i18n.tr("Insert name")
                onTextChanged: {
                    if (favNameField.text.trim()) {
                        isOverwriteMode = checkFavoriteExists();
                    }
                }
            }

            Column {
                width: parent.width
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: units.gu(2)
                    Button {
                        text: i18n.tr("Cancel")
                        onClicked: {
                            favNameField.text = ''
							PopupUtils.close(newFav);
                        }
                    }
                    Button {
                        text: isOverwriteMode ? i18n.tr("Overwrite") : i18n.tr("Add")
                        color: isOverwriteMode ? UbuntuColors.red : UbuntuColors.green
                        enabled: favNameField.text.trim()
                        onClicked: {
                            UnavDB.saveFavorite(favNameField.text, mainPageStack.favLat, mainPageStack.favLng);
							PopupUtils.close(newFav);
                        }
                    }
                }
            }
        }
    }
    Connections {
        target: Qt.application
        onStateChanged:
            if (Qt.application.state !== Qt.ApplicationActive) {
				mainPageStack.executeJavaScript("qml_save_last_pos()");
            }
    }
}
