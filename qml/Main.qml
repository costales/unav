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
import QtQuick.Layouts 1.1
import Ubuntu.Components.Popups 1.3
import Ubuntu.Content 1.1
import QtMultimedia 5.0
import QtFeedback 5.0
import QtSystemInfo 5.0
import QtQuick.XmlListModel 2.0
import "components"
import "js/utils.js" as QmlJs
import "js/db.js" as UnavDB
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.2
import QtWebEngine 1.6
import Qt.labs.settings 1.0

Window {
    id: unavWindow

    title: "uNav"
    width: units.gu(150)
    height: units.gu(100)
    minimumWidth: units.gu(45)
    minimumHeight: units.gu(45)
    maximumWidth: Screen.width
    maximumHeight: Screen.height

    MainView {
        id: navApp

        objectName: "navApp"
        applicationName: "navigator.costales"

        Component.onCompleted: {
            // Translations
            i18n.domain = "unav";
            i18n.bindtextdomain("unav", "nav/locales/mo");
        }

        anchorToKeyboard: true

        width: unavWindow.width + units.gu(0.1) //TODO: Investigate why this is needed
        height: unavWindow.height + units.gu(0.1) //TODO: Investigate why this is needed

        property string applicationVersion: "2.3"
        property string mapUrl: "../nav/index.html"
        property string appUA: "Mozilla/5.0 (Linux; Android 5.0; Nexus 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.102 Mobile Safari/537.36 Project uNav"

        // persistent app settings:
        property var settings: Settings {
            property int soundIndications: 0 // 0 voice 1 notification 2 none
            property int layer: 0
            property int onlineLayer: 0
            property int shareMap: 0
            property int unit: 0
            property int routingMode: 0 // 0 car, 1 walk, 2 bicycle, 3 bus
            property bool alertRadars: false
            property bool legalRadarShow: true
            property string prevLat: ''
            property string prevLng: ''
            property int prevZoom: 9999
            property bool uiShowSpeed: false
            property bool saveHistory: true
            property bool showTuto: true
            property bool showCustomVoices: true
            property int lastSearchOption: 0
            property int defaultDistancePOI: 1
            property string currentVoice: 'Nathan Haines'

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
            id: screenSaver
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
                    id: standardlayout

                    when: navApp.settings.showTuto

                    PageColumn {
                        fillWidth: true
                    }
                },

                PageColumnsLayout {
                    id: nonstandardlayout
                    when: !navApp.settings.showTuto && width >= mainPageStack.maxWidth && mainPageStack.childPageOpened

                    // column #0
                    PageColumn {
                        fillWidth: true
                    }

                    // column #1
                    PageColumn {
                        minimumWidth: units.gu(30)
                        maximumWidth: mainPageStack.maxWidth
                        preferredWidth: units.gu(50)
                    }
                }
            ]

            Component.onCompleted: {
                if (navApp.settings.showTuto) { // If uNav is being opened for the first time, show the welcome tutorial in just one column
                    mainPageStack.addPageToCurrentColumn(mainPageStack.primaryPage, Qt.resolvedUrl("tuto/WelcomeWizard.qml"))
                }
                else {
                    if (navApp.settings.showCustomVoices && Qt.locale().name.toLowerCase().replace('_','-') !== 'en-us') { // If not Tuto & not American English language
                        navApp.settings.showCustomVoices = false;
                        PopupUtils.open(setVoiceComponent);
                    }
                }
            }

            property string currentLat: "null"
            property string currentLng: "null"
            property string endLat: "null"
            property string endLng: "null"
            property string clickedLat: "null"
            property string clickedLng: "null"
            property string ptFromLat: "null"
            property string ptFromLng: "null"
            property string resimulatePTFromLat: "null"
            property string resimulatePTFromLng: "null"
            property string resimulatePTToLat: "null"
            property string resimulatePTToLng: "null"
            property string routeState: "no"
            property int center_onpos: 0 // 0 GPS off, 1 GPS on + not center, 2 GPS on + center
            property bool favPopup: false
            property bool onLoadingExecuted: false

            property string usContext: "messaging://"
            function executeJavaScript(code) {
              console.log(code)

              _webview.runJavaScript(code);
            }

            Page {
                id: navigationPage

                property bool buttonsEnabled: false

                anchors.fill: parent

                function show_header() {
                    if (mainPageStack.columns > 1) // There issue in header, show all times with 2 columns
                        return true;

                    // tablet
                    if ( (Screen.width == 800  && Screen.height == 1280) ||
                         (Screen.width == 1280 && Screen.height == 800)  ||
                         (Screen.width == 1920 && Screen.height == 1200) ||
                         (Screen.width == 1200 && Screen.height == 1920) )
                        return true;

                    if (navApp.width < navApp.height) // portraid
                        return true;

                    return false; // phone in landscape
                }

                header: UNavHeader {
                    id: header

                    title: "uNav"
                    visible: navigationPage.show_header()

                    leadingActionBar {
                        width: 0
                        visible: false
                    }

                    trailingActionBar {
                        numberOfSlots: 4
                        actions: [
                            Action {
                                id: actionSettings
                                iconName: "settings"
                                text: i18n.tr("Settings")
                                enabled: navigationPage.buttonsEnabled
                                onTriggered: {
                                    mainPageStack.showSideBar();
                                    mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("SettingsPage.qml"));
                                }
                            },

                            Action {
                                id: centerPosAction
                                iconName: mainPageStack.center_onpos ? "media-optical-symbolic" : "gps"
                                text: i18n.tr("Center on Position")
                                enabled: navigationPage.buttonsEnabled && mainPageStack.center_onpos !== 2
                                onTriggered: {
                                    if (mainPageStack.center_onpos === 0) {
                                        notificationBar.text =  i18n.tr("Searching your position… This could take a while");
                                        notificationBar.info();
                                        notificationBarTimer.start();
                                    }
                                    mainPageStack.center_onpos = 2;
                                    goThereActionPopover.hide();
                                    mainPageStack.executeJavaScript("center_pos()");
                                }
                            },

                            Action {
                                id: searchAction
                                iconName: "find"
                                shortcut: "Ctrl+F"
                                text: i18n.tr("Search")
                                enabled: navigationPage.buttonsEnabled
                                onTriggered: {
                                    mainPageStack.showSideBar();
                                    mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("SearchPage.qml"));
                                }
                            },

                            Action {
                                id: cancelAction
                                iconSource: Qt.resolvedUrl("../nav/img/header/nav-actions.svg")
                                text: i18n.tr("Destination")
                                visible: mainPageStack.routeState !== 'no'
                                enabled: navigationPage.buttonsEnabled
                                onTriggered: {
                                    goThereActionPopover.hide();
                                    goThereActionPopover.showMenu = true;
                                    goThereActionPopover.show();
                                }
                            }
                        ]
                    }
                }

                /**
                Workaround:
                QML Map Element currently does not support flicking. This makes it unusable to this app so far.
                As long as this is to supported, the map view falls back to a html5 container that renders the navigation.
                Signals from qml are sent via eventhandlers in oxide via userScript.
                The panel stays in html5, too, for ease of integration.
                **/

                WebEngineProfile {
                    id: webcontext
                    httpUserAgent: navApp.appUA
                }

                WebEngineView {
                    property alias context: _webview.profile

                    id: _webview
                    anchors.fill: parent
                    z: -6
                    profile: webcontext
                    url: navApp.mapUrl
                    settings.localContentCanAccessFileUrls: true
                    settings.javascriptCanAccessClipboard: true
                    settings.javascriptEnabled: true
                    //not used right now:
                    //filePicker: filePickerLoader.item

                    // get in-webcontainer click events (e.g. click on map)
                    // and coordinates to handle them in qml ui:
                    onNavigationRequested:{
                        // We could start to clean this up a bit by writing functions on that...
                        var url = request.url.toString().split("?");
                        if(typeof url[1]!="undefined")
                        var params = url[1].split("/");
                        else var params = []
                        console.log(url, params);
                        switch (url[0]) {
                        case "http://go/":
                            Qt.openUrlExternally(url[1]);
                            break;

                        case "http://get_routeinfo_list/":
                            var dec_routeList = decodeURIComponent(url[1]);
                            mainPageStack.showSideBar();
                            mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("RouteInfoListPage.qml"), { routeList: JSON.parse(dec_routeList) });
                            break;

                        case "http://route_status/":
                            mainPageStack.currentLat = params[0];
                            mainPageStack.currentLng = params[1];
                            mainPageStack.endLat = params[2];
                            mainPageStack.endLng = params[3];
                            mainPageStack.routeState = params[4];
                            break;

                        case "http://clicked_on_map/":
                            goThereActionPopover.hide();
                            goThereActionPopover.osm_type = 'none';
                            goThereActionPopover.osm_id = 'none';
                            goThereActionPopover.phone = '';
                            goThereActionPopover.poiName = "";
                            notificationBar.visible = false;

                            if (params[0] === 'nofollow' && mainPageStack.center_onpos === 2)
                                mainPageStack.center_onpos = 1;

                            mainPageStack.clickedLat = params[1];
                            mainPageStack.clickedLng = params[2];

                            if (params[3] !== 'none')
                                goThereActionPopover.osm_type = params[3];

                            if (params[4] !== 'none')
                                goThereActionPopover.osm_id = params[4];

                            if (params[5] !== 'none')
                                goThereActionPopover.phone = params[5];

                            if (params[6] !== "none")
                                goThereActionPopover.poiName = decodeURIComponent(params[6].replace(/¿¿¿/g, '/'));

                            mainPageStack.favPopup = false;
                            goThereActionPopover.show();

                            // Perform reverse geocoding only when it is a generic marker that the user clicked on the map
                            if (goThereActionPopover.poiName === "" && goThereActionPopover.osm_id === 'none') {
                                reverseXmlModel.reverseSearch(mainPageStack.clickedLat, mainPageStack.clickedLng);
                            }
                            break;

                        case "http://simulate_again/":
                            mainPageStack.routeState = 'simulate_calculating';
                            mainPageStack.executeJavaScript("simulate2coord(" + mainPageStack.resimulatePTFromLat + ", " + mainPageStack.resimulatePTFromLng + ", " + mainPageStack.resimulatePTToLat + ", " + mainPageStack.resimulatePTToLng + ");");
                            break;

                        case "http://hide_popup/":
                            goThereActionPopover.hide();
                            break;

                        case "http://set_center_onpos/":
                            switch (params[0]) {
                            case '0': // GPS Denied (special)
                                mainPageStack.routeState = 'no';
                                mainPageStack.center_onpos = 0;
                                break;
                            case '1':
                                mainPageStack.center_onpos = 1;
                                break;
                            case '2':
                                mainPageStack.center_onpos = 2;
                                break;
                            }
                            break;

                        case "http://set_ui_speed/":
                            if (params[0] === 'true')
                                navApp.settings.uiShowSpeed = true;
                            else
                                navApp.settings.uiShowSpeed = false;
                            break;

                        case "http://cancel_route/":
                            mainPageStack.routeState = 'no';
                            break;

                        case "http://save_data/":
                            navApp.settings.prevLat = params[0];
                            navApp.settings.prevLng = params[1];
                            navApp.settings.prevZoom = params[2];
                            navApp.settings.routingMode = params[3];
                            break;

                        case "http://show_notification/":
                            switch (params[0]) {
                                case "info":
                                    notificationBar.info();
                                    break;
                                case "warning":
                                    notificationBar.warning();
                                    break;
                                case "critical":
                                    notificationBar.critical();
                                    break;
                            }
                            switch (params[1]) {
                                case "speed_camera_error":
                                    notificationBar.text =  i18n.tr("Error getting speed cameras!");
                                    break;
                                case "webapi_error":
                                    notificationBar.text =  i18n.tr("Error finding route! Retrying again in 1 minute…");
                                    break;
                                case "calcfromout_error":
                                    notificationBar.text =  i18n.tr("Error finding route! Trying again…");
                                    break;
                            }
                            notificationBarTimer.start();
                        }
                        //allow loading of file:// but dissallow http because it's used for navigation
                        if(typeof url[0]!="undefined" && url[0].includes("http")){
                          request.action = WebEngineNavigationRequest.IgnoreRequest;
                        }
                    }

                    Component.onCompleted: {
                        settings.localStorageEnabled = true
                    }
                    onJavaScriptConsoleMessage: {
                      var msg = "[JS] (%1:%2) %3".arg(sourceID).arg(lineNumber).arg(message)
                      console.log(msg)
                    }
                    Connections {
                        onLoadingChanged: {
                          if (loadRequest.status == WebEngineView.LoadSucceededStatus && !mainPageStack.onLoadingExecuted) {
                              mainPageStack.onLoadingExecuted = true;
                              //send saved Setting states:
                              mainPageStack.executeJavaScript("settings.set_sound(" + navApp.settings.soundIndications + ")");
                              mainPageStack.executeJavaScript("settings.set_unit(\'" + ( navApp.settings.unit === 0 ? "km" : "mi" ) +"\')");
                              mainPageStack.executeJavaScript("ui.set_scale_unit(\'" + ( navApp.settings.unit === 0 ? "km" : "mi" ) +"\')");
                              mainPageStack.executeJavaScript("settings.set_routing_mode(" + navApp.settings.routingMode + ")");
                              mainPageStack.executeJavaScript("settings.set_alert_radars(" + navApp.settings.alertRadars + ")");
                              mainPageStack.executeJavaScript("settings.set_ui_speed(" + navApp.settings.uiShowSpeed + ")");
                              // Center map in last position
                              if (navApp.settings.prevLat !== '' && navApp.settings.prevLng !== '' && navApp.settings.prevLat !== null && navApp.settings.prevLng !== null && navApp.settings.prevZoom !== 9999)
                                  mainPageStack.executeJavaScript("map.getView().setCenter(ol.proj.transform([" + navApp.settings.prevLng + "," + navApp.settings.prevLat + "], 'EPSG:4326', 'EPSG:3857')); map.getView().setZoom(" + navApp.settings.prevZoom + ")");
                              // This always after previous instruction!
                              if (!navApp.settings.layer)
                                  mainPageStack.executeJavaScript("ui.set_map_layer(" + navApp.settings.onlineLayer + ")");
                              else
                                  mainPageStack.executeJavaScript("ui.set_map_layer(99)");

                              // Hack: If user click so fast in buttons, app breaks sometimes
                              navigationPage.buttonsEnabled = true;

                              // Catching urls
                              var url_dispatcher = Qt.application.arguments[1];
                              navApp.checkReceivedCoordinates(url_dispatcher);
                          }
                        }
                        // onInsertionHandleTapped: quickMenu.visible = !quickMenu.visible
                        onContextMenuRequested: quickMenu.visible = true
                        onFeaturePermissionRequested: {
                            console.log("grantFeaturePermission", feature)
                            _webview.grantFeaturePermission(securityOrigin, feature, true);
                        }
                    }


                }

                Connections {
                    target: UriHandler
                    onOpened: {
                        if (uris.length === 0 ) {
                            return;
                        }
                        // Catching urls
                        var url_dispatcher = uris[0];
                        navApp.checkReceivedCoordinates(url_dispatcher);
                    }
                }

                Loader {
                    id: actionButtonRowLoader
                    sourceComponent: !header.visible ? actionButtonRowComponent : undefined
                    anchors { right: parent.right; top: parent.top; margins: units.gu(1) }
                }

                Rectangle {
                    z: -1
                    visible: !header.visible
                    width: mainPageStack.routeState !== 'no' ? units.gu(19) : units.gu(15)
                    height: header.height
                    color: "#398DFF"
                    anchors.right: parent.right
                }

                Component {
                    id: actionButtonRowComponent
                    Row {
                        id: actionButtonRow

                        opacity: navigationPage.buttonsEnabled ? 1.0 : 0.2

                        ActionIcon {
                            icon.source: Qt.resolvedUrl("../nav/img/header/nav-actions-transparent.svg")
                            enabled: navigationPage.buttonsEnabled
                            visible: mainPageStack.routeState !== 'no'
                            onClicked: {
                                goThereActionPopover.hide();
                                goThereActionPopover.showMenu = true;
                                goThereActionPopover.show();
                            }
                        }

                        ActionIcon {
                            icon.name: "find"
                            enabled: navigationPage.buttonsEnabled
                            onClicked: {
                                mainPageStack.showSideBar();
                                mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("SearchPage.qml"));
                            }
                        }

                        ActionIcon {
                            id: centerPosBtn
                            icon.name: mainPageStack.center_onpos ? "media-optical-symbolic" : "gps"
                            enabled: navigationPage.buttonsEnabled && mainPageStack.center_onpos !== 2
                            opacity: centerPosBtn.enabled ? 1.0 : 0.2 // enabled property is not changing the opacity of the icon
                            onClicked: {
                                if (mainPageStack.center_onpos === 0) {
                                    notificationBar.text =  i18n.tr("Searching your position… This could take a while");
                                    notificationBar.info();
                                    notificationBarTimer.start();
                                }
                                mainPageStack.center_onpos = 2;
                                goThereActionPopover.hide();
                                mainPageStack.executeJavaScript("center_pos()");
                            }
                        }

                        ActionIcon {
                            icon.name: "settings"
                            enabled: navigationPage.buttonsEnabled
                            onClicked: {
                                mainPageStack.showSideBar();
                                mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("SettingsPage.qml"));
                            }
                        }
                    }
                }

                Item {
                    clip: true
                    width: zoomButtons.width + units.gu(2)
                    height: zoomButtons.height + units.gu(6)
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter; verticalCenterOffset: units.gu(-3) }
                    ZoomButtons {
                        id: zoomButtons
                        visible: navigationPage.buttonsEnabled
                        onZoomedIn: mainPageStack.executeJavaScript("custom_zoom(1)")
                        onZoomedOut: mainPageStack.executeJavaScript("custom_zoom(-1)")
                    }
                }

                Timer {
                    id: notificationBarTimer
                    interval: 4000
                    repeat: false
                    onTriggered: {
                        notificationBar.visible = false
                    }
                }

                NotificationBar {
                    id: notificationBar
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            notificationBarTimer.stop()
                            notificationBar.visible = false
                        }
                    }
                }

                XmlListModel {
                    id: reverseXmlModel

                    readonly property string baseUrl: "https://nominatim.openstreetmap.org/reverse?format=xml&email=costales.marcos@gmail.com&addressdetails=0&extratags=1&zoom=18&namedetails=1&"

                    function reverseSearch(lat, lon) {
                        source = (baseUrl + "lat=" + lat + "&lon=" + lon) ;
                    }

                    function clear() {
                        goThereActionPopover.reverseGeoString = "";
                        source = "";
                    }

                    onStatusChanged: {
                        if (status === XmlListModel.Error || (status === XmlListModel.Ready && count === 0)) {
                            goThereActionPopover.reverseGeoString = ""
                            console.log("Error reverse geocoding the location!")
                        }

                        else if (status === XmlListModel.Ready && count > 0) {
                            // Check if the location returned by reverse geocoding is a POI by looking for the existence of certain parameters
                            // like cuisine, phone, opening_hours, internet_access, wheelchair etc that do not apply to a generic address
                            if (reverseXmlModel.get(0).description || reverseXmlModel.get(0).cuisine || reverseXmlModel.get(0).phone || reverseXmlModel.get(0).contactphone || reverseXmlModel.get(0).opening_hours || reverseXmlModel.get(0).website || reverseXmlModel.get(0).contactwebsite || reverseXmlModel.get(0).email || reverseXmlModel.get(0).contactemail || reverseXmlModel.get(0).wheelchair || reverseXmlModel.get(0).internet_access) {

                                // Check if the name, osm_id and osm_type are valid, otherwise the POI popup will break.
                                if (reverseXmlModel.get(0).name && reverseXmlModel.get(0).osm_id && reverseXmlModel.get(0).osm_type) {
                                    goThereActionPopover.poiName = reverseXmlModel.get(0).name
                                    goThereActionPopover.osm_id = reverseXmlModel.get(0).osm_id
                                    goThereActionPopover.osm_type = reverseXmlModel.get(0).osm_type.charAt(0).toUpperCase()
                                    if (reverseXmlModel.get(0).phone !== '')
                                        goThereActionPopover.phone = reverseXmlModel.get(0).phone
                                    else
                                        goThereActionPopover.phone = reverseXmlModel.get(0).contactphone
                                } else {
                                    goThereActionPopover.reverseGeoString = reverseXmlModel.get(0).result
                                }
                            }

                            // If nothing works, fall back to just showing the address in a generic popup
                            else {
                                goThereActionPopover.reverseGeoString = reverseXmlModel.get(0).result
                            }
                        }
                    }

                    source: ""
                    query: "/reversegeocode"

                    XmlRole { name: "osm_type"; query: "result/@osm_type/string()" }
                    XmlRole { name: "osm_id"; query: "result/@osm_id/string()" }
                    XmlRole { name: "result"; query: "result/string()" }
                    XmlRole { name: "name"; query: "namedetails/name[1]/string()" }
                    XmlRole { name: "description"; query: "extratags/tag[@key='description']/@value/string()" }
                    XmlRole { name: "cuisine"; query: "extratags/tag[@key='cuisine']/@value/string()" }
                    XmlRole { name: "opening_hours"; query: "extratags/tag[@key='opening_hours']/@value/string()" }
                    XmlRole { name: "phone"; query: "extratags/tag[@key='phone']/@value/string()" }
                    XmlRole { name: "website"; query: "extratags/tag[@key='website']/@value/string()" }
                    XmlRole { name: "email"; query: "extratags/tag[@key='email']/@value/string()" }
                    XmlRole { name: "contactphone"; query: "extratags/tag[@key='contact:phone']/@value/string()" }
                    XmlRole { name: "contactwebsite"; query: "extratags/tag[@key='contact:website']/@value/string()" }
                    XmlRole { name: "contactemail"; query: "extratags/tag[@key='contact:email']/@value/string()" }
                    XmlRole { name: "internet_access"; query: "extratags/tag[@key='internet_access']/@value/string()" }
                    XmlRole { name: "wheelchair"; query: "extratags/tag[@key='wheelchair']/@value/string()" }
                }

                PoiPopup {
                    id: goThereActionPopover

                    // Dragons be here! Don't change these values
                    hidePosition: -3*height
                    showPosition: header.visible ? 0 : -navigationPage.header.height
                    anchors { top: navigationPage.header.bottom }

                    height: mainContentLoader.height + 2*mainContentLoader.anchors.margins

                    property string reverseGeoString: ""
                    property string poiName
                    property string osm_type
                    property string osm_id
                    property string phone
                    property bool showMenu: false

                    onIsShownChanged: {
                        if (!goThereActionPopover.isShown) {
                            reverseXmlModel.clear()
                            goThereActionPopover.showMenu = false
                        }
                    }

                    Loader {
                        id: mainContentLoader

                        sourceComponent: {
                            if (goThereActionPopover.isShown) {
                                if (goThereActionPopover.showMenu) {
                                    return routeMenu
                                }

                                if (goThereActionPopover.osm_id === 'none') {
                                    return genericPopupComponent
                                }
                                return poiPopupComponent
                            }
                            return undefined
                        }

                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: units.gu(2) }
                    }

                    Component {
                        id: routeMenu
                        Column {
                            height: routePageGrid.height
                            spacing: 0
                            Component.onCompleted: {
                                mainPageStack.executeJavaScript("qml_set_route_status();")
                            }

                            Row {
                                id: gridRow
                                spacing: units.gu(2)
                                anchors.horizontalCenter: parent.horizontalCenter

                                Loader {
                                    id: poiQuickAccessLoader
                                    sourceComponent: POIQuickAccessGridView {}
                                }

                                CustomGridView {
                                    id: routePageGrid

                                    ListModel {
                                        id: routePageModel
                                        Component.onCompleted: initialize()

                                        function initialize() {
                                            routePageModel.append({mode: "DESTINATION", text: i18n.tr("Near to destination"), iconName: "location"})
                                            routePageModel.append({mode: "CANCEL", text: i18n.tr("Cancel route"), iconName: "dialog-error-symbolic"})
                                        }
                                    }

                                    itemWidth: units.gu(8)
                                    model: routePageModel

                                    delegate: GridDelegate {
                                        id: delegate

                                        width: units.gu(8)
                                        title: model.text
                                        icon.name: model.iconName

                                        onClicked: {
                                            if (model.mode === "DESTINATION") {
                                                mainPageStack.showSideBar();
                                                mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("PoiPage.qml"), {"lat": mainPageStack.endLat, "lng": mainPageStack.endLng});
                                            } else if (model.mode === "CANCEL") {
                                                mainPageStack.routeState = 'no';
                                                mainPageStack.executeJavaScript("click_cancel_route();");
                                            }
                                            goThereActionPopover.showMenu = false
                                            goThereActionPopover.hide()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Component {
                        id: genericPopupComponent
                        Column {
                            spacing: units.gu(2)

                            Label {
                                id: geoCodeLabel
                                maximumLineCount: 3
                                width: parent.width
                                wrapMode: Text.WordWrap
                                color: UbuntuColors.slate
                                horizontalAlignment: Text.AlignHCenter
                                textSize: !truncated ? Label.Large : Label.Medium
                                text: goThereActionPopover.poiName ? goThereActionPopover.poiName :
                                            goThereActionPopover.reverseGeoString ? goThereActionPopover.reverseGeoString :
                                                                                    i18n.tr("Coord: %1, %2").arg(parseFloat(mainPageStack.clickedLat).toFixed(5)).arg(parseFloat(mainPageStack.clickedLng).toFixed(5));
                            }

                            Row {
                                spacing: units.gu(0.5)
                                anchors.horizontalCenter: parent.horizontalCenter

                                GridIconDelegate {
                                    icon.name: "send"
                                    icon.height: units.gu(3)
                                    highlightSize: units.gu(-1)
                                    visible: goThereActionPopover.poiName !== i18n.tr("Current Position") ? true : false
                                    onClicked: {
                                        if (navApp.settings.saveHistory && goThereActionPopover.reverseGeoString) {
                                            UnavDB.saveToSearchHistory(geoCodeLabel.text, mainPageStack.clickedLat, mainPageStack.clickedLng);
                                        }
                                        goThereActionPopover.hide();
                                        mainPageStack.center_onpos = 2;
                                        mainPageStack.routeState = 'yes';
                                        mainPageStack.executeJavaScript("calc2coord(" + mainPageStack.clickedLat + ", " + mainPageStack.clickedLng + ");");
                                    }
                                }

                                GridIconDelegate {
                                    icon.name: mainPageStack.favPopup ? "starred" : "non-starred"
                                    icon.height: units.gu(3)
                                    highlightSize: units.gu(-1)
                                    onClicked: {
                                        mainPageStack.favPopup = !mainPageStack.favPopup;
                                        mainPageStack.showSideBar();
                                        var incubator = mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("SearchPage.qml"), {favLat: mainPageStack.clickedLat, favLng: mainPageStack.clickedLng, favName: ""});
                                        incubator.onStatusChanged = function(status) {
                                            if (status === Component.Ready) {
                                                incubator.object.addFavorite();
                                            }
                                        }
                                    }
                                }

                                GridIconDelegate {
                                    icon.name: "location"
                                    icon.height: units.gu(3)
                                    highlightSize: units.gu(-1)
                                    onClicked: {
                                        mainPageStack.showSideBar();
                                        mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("PoiPage.qml"), {"lat": mainPageStack.clickedLat, "lng": mainPageStack.clickedLng});
                                    }
                                }

                                GridIconDelegate {
                                    icon.name: "share"
                                    icon.height: units.gu(3)
                                    highlightSize: units.gu(-1)
                                    onClicked: {
                                        mainPageStack.showSideBar();
                                        mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("Share.qml"), {"lat": mainPageStack.clickedLat, "lon": mainPageStack.clickedLng, "isParentPage": true});
                                    }
                                }

                                GridIconDelegate {
                                    icon.name: "info"
                                    visible: goThereActionPopover.osm_id != 'none'
                                    icon.height: units.gu(3)
                                    highlightSize: units.gu(-1)
                                    onClicked: {
                                        goThereActionPopover.hide();
                                        mainPageStack.showSideBar();
                                        mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("PoiDetailsPage.qml"), {osm_id: goThereActionPopover.osm_id, osm_type: goThereActionPopover.osm_type, poiName: goThereActionPopover.poiName, isParentPage: true});
                                    }
                                }

                                GridIconDelegate {
                                    icon.name: "transfer-progress-upload"
                                    visible: mainPageStack.ptFromLat === "null" && goThereActionPopover.osm_id === 'none'
                                    icon.height: units.gu(3)
                                    highlightSize: units.gu(-1)
                                    onClicked: {
                                        goThereActionPopover.hide();
                                        mainPageStack.ptFromLat = mainPageStack.clickedLat;
                                        mainPageStack.ptFromLng = mainPageStack.clickedLng;
                                        notificationBar.text =  i18n.tr("Simulate from here! Now click on destination");
                                        notificationBar.info();
                                        notificationBarTimer.start();

                                    }
                                }

                                GridIconDelegate {
                                    icon.name: "transfer-progress-download"
                                    visible: mainPageStack.ptFromLat !== "null" && goThereActionPopover.osm_id === 'none'
                                    icon.height: units.gu(3)
                                    highlightSize: units.gu(-1)
                                    onClicked: {
                                        // Validate coordinates are different points
                                        if (mainPageStack.ptFromLat === mainPageStack.clickedLat && mainPageStack.ptFromLng === mainPageStack.clickedLng) {
                                            goThereActionPopover.hide();
                                            mainPageStack.ptFromLat = "null";
                                            notificationBar.text = i18n.tr("Set a different coordinates for simulating");
                                            notificationBar.warning();
                                            notificationBarTimer.start();
                                        }
                                        else {
                                            goThereActionPopover.hide();
                                            mainPageStack.routeState = 'simulate_calculating';
                                            mainPageStack.resimulatePTFromLat = mainPageStack.ptFromLat;
                                            mainPageStack.resimulatePTFromLng = mainPageStack.ptFromLng;
                                            mainPageStack.resimulatePTToLat = mainPageStack.clickedLat;
                                            mainPageStack.resimulatePTToLng = mainPageStack.clickedLng;
                                            mainPageStack.executeJavaScript("simulate2coord(" + mainPageStack.ptFromLat + ", " + mainPageStack.ptFromLng + ", " + mainPageStack.clickedLat + ", " + mainPageStack.clickedLng + ");");
                                            mainPageStack.ptFromLat = "null";
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Component {
                        id: poiPopupComponent
                        Column {
                            spacing: units.gu(2)

                            Label {
                                id: poiPopupComponentLabel
                                text: goThereActionPopover.poiName
                                visible: goThereActionPopover.poiName !== ""
                                maximumLineCount: 2
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                textSize: Label.Large
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                color: UbuntuColors.slate
                            }

                            Row {
                                spacing: units.gu(0.5)
                                anchors.horizontalCenter: parent.horizontalCenter

                                GridIconDelegate {
                                    icon.name: "send"
                                    icon.height: units.gu(3)
                                    highlightSize: units.gu(-1)
                                    onClicked: {
                                        if (navApp.settings.saveHistory) {
                                            UnavDB.saveToSearchHistory(poiPopupComponentLabel.text, mainPageStack.clickedLat, mainPageStack.clickedLng);
                                        }
                                        goThereActionPopover.hide();
                                        mainPageStack.center_onpos = 2;
                                        mainPageStack.routeState = 'yes';
                                        mainPageStack.executeJavaScript("calc2coord(" + mainPageStack.clickedLat + ", " + mainPageStack.clickedLng + ");");
                                    }
                                }

                                GridIconDelegate {
                                    icon.name: mainPageStack.favPopup ? "starred" : "non-starred"
                                    icon.height: units.gu(3)
                                    highlightSize: units.gu(-1)
                                    onClicked: {
                                        mainPageStack.favPopup = !mainPageStack.favPopup;
                                        mainPageStack.showSideBar();
                                        var incubator = mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("SearchPage.qml"), {favLat: mainPageStack.clickedLat, favLng: mainPageStack.clickedLng, favName: ""});
                                        incubator.onStatusChanged = function(status) {
                                            if (status === Component.Ready) {
                                                incubator.object.addFavorite();
                                            }
                                        }
                                    }
                                }

                                GridIconDelegate {
                                    icon.name: "location"
                                    icon.height: units.gu(3)
                                    highlightSize: units.gu(-1)
                                    onClicked: {
                                        mainPageStack.showSideBar();
                                        mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("PoiPage.qml"), {"lat": mainPageStack.clickedLat, "lng": mainPageStack.clickedLng});
                                    }
                                }

                                GridIconDelegate {
                                    icon.name: "share"
                                    icon.height: units.gu(3)
                                    highlightSize: units.gu(-1)
                                    onClicked: {
                                        mainPageStack.showSideBar();
                                        mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("Share.qml"), {"lat": mainPageStack.clickedLat, "lon": mainPageStack.clickedLng, "isParentPage": true});
                                    }
                                }

                                GridIconDelegate {
                                    icon.name: "info"
                                    icon.height: units.gu(3)
                                    highlightSize: units.gu(-1)
                                    onClicked: {
                                        goThereActionPopover.hide();
                                        mainPageStack.showSideBar();
                                        mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("PoiDetailsPage.qml"), {osm_id: goThereActionPopover.osm_id, osm_type: goThereActionPopover.osm_type, poiName: goThereActionPopover.poiName, isParentPage: true});
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Connections {
            target: Qt.application
            onStateChanged:
                if(Qt.application.state !== Qt.ApplicationActive) {
                    _webview.runJavaScript("window.qml_save_data()");
                }
        }

        Component {
             id: setVoiceComponent
             Dialog {
                id: setVoice
                title: i18n.tr("Custom voices")
                text: i18n.tr("American English voice will be the unique voice installed by default.\n\nYou can set a custom voice in your language from Settings: Download custom voices.\n\nThe list of voices will be updated by the users. Please check them out in the future.\n")
                Button {
                    text: i18n.tr("Set a voice now")
                    color: UbuntuColors.green
                    onClicked: {
                        PopupUtils.close(setVoice);
                        mainPageStack.showSideBar();
                        mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("DownloadVoices.qml"));
                    }
                }
                Button {
                    text: i18n.tr("Close")
                    onClicked: {
                        PopupUtils.close(setVoice);
                    }
                }
            }
        }

        //Item to receive shared urls
        ContentHubModel {
            id: contentHub
            onShareRequested: navApp.startImport(transfer)
        }

        function startImport(transfer) {
            console.log("Start import")
            if (transfer.contentType === ContentType.Links) {

                // Extract the pure text
                for (var i = 0; i < transfer.items.length; i++) {
                    if (transfer.items[i].url) {
                        var importedUrl = String(transfer.items[i].url);

                        checkReceivedCoordinates(importedUrl);
                    }
                }

                console.log("Import: ", importedUrl)
            }
        }

        function checkReceivedCoordinates(urlToCheck){
            if (QmlJs.is_url_dispatcher(urlToCheck)['is_dispatcher']) {
                var coord = QmlJs.get_url_coord(urlToCheck);
                if (coord['lat'] !== null && coord['lng'] !== null) {
                    mainPageStack.clickedLat = coord['lat'];
                    mainPageStack.clickedLng = coord['lng'];
                    if (mainPageStack.center_onpos === 2)
                        mainPageStack.center_onpos = 1;
                    mainPageStack.executeJavaScript("ui.markers_POI_set([{title: \"" + i18n.tr("Shared Position") + "\", lat: " + mainPageStack.clickedLat + ", lng: " + mainPageStack.clickedLng + "}])");
                    mainPageStack.favPopup = false;
                    goThereActionPopover.show();
                }
            }
        }
    }
}
