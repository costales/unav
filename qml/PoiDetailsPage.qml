/*
 * uNav http://launchpad.net/unav
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
import Ubuntu.Components.Popups 1.3
import "js/utils.js" as QmlJs
import "components"
import "js/db.js" as UnavDB
import QtQuick.LocalStorage 2.0

Page {
    id: poiDetailsPage

    property string osm_type
    property string osm_id
    property string poiName

    // Property to indicate if the poi details page was opened directly (from a popup)
    // or as a child (from the search page)
    property bool isParentPage: false

    header: UNavHeader {
        title: poiName
        flickable: flickable
        trailingActionBar.actions: CloseHeaderAction {
            visible: mainPageStack.columns !== 1 && isParentPage
        }
    }

    anchors.fill: parent

    Component.onCompleted: mainPageStack.executeJavaScript("qml_set_route_status()")

    Component.onDestruction: {
        // Hide 2nd column when returning to the map to avoid an empty white column
        if (mainPageStack.columns === 1 && isParentPage)
            mainPageStack.hideSideBar()
    }

    XmlListModel {
        id: poiDetailsModel

        readonly property string baseUrl: "https://nominatim.openstreetmap.org/reverse?format=xml&addressdetails=1&email=marcos.costales@gmail.com&extratags=1"
        readonly property string url: baseUrl + "&osm_type=" + osm_type + "&osm_id=" + osm_id

        property string lat
        property string lng
        property string distance

        onStatusChanged:  {
            if (status === XmlListModel.Ready) {
                description.title = poiDetailsModel.get(0).description
                address.title = poiDetailsModel.get(0).address
                cuisine.title = poiDetailsModel.get(0).cuisine
                if (poiDetailsModel.get(0).phone !== '')
                    phone.title = poiDetailsModel.get(0).phone
                else
                    phone.title = poiDetailsModel.get(0).contactphone
                if (poiDetailsModel.get(0).website !== '')
                    website.title = poiDetailsModel.get(0).website
                else
                    website.title = poiDetailsModel.get(0).contactwebsite
                if (poiDetailsModel.get(0).email !== '')
                    email.title = poiDetailsModel.get(0).email
                else
                    email.title = poiDetailsModel.get(0).contactemail
                openingHours.title = poiDetailsModel.get(0).opening_hours
                internet.title = poiDetailsModel.get(0).internet_access
                wheelchair.title = poiDetailsModel.get(0).wheelchair
                lat = parseFloat(mainPageStack.clickedLat)
                lng = parseFloat(mainPageStack.clickedLng)

                distance = QmlJs.formatDistance(QmlJs.calcPoiDistance(mainPageStack.currentLat, mainPageStack.currentLng, lat, lng, 10), navApp.settings.unit)

                coordinates.title = "%1 %2, %3 %4".arg(i18n.tr("Lat, Long:")).arg(parseFloat(lat).toFixed(5)).arg(parseFloat(lng).toFixed(5)).arg((distance ? '| '+distance : ''))

                // Internet access values returned by OSM are (yes, no, wlan, terminal and wired) which
                // are too short and not translated. They are converted to meaningful phrases and also
                // used to set the icon colors for better visiblity.
                if (internet.title === "yes") {
                    internet.title = i18n.tr("Available")
                } else if (internet.title === "no") {
                    internet.title = i18n.tr("Not Available")
                } else if (internet.title === "wlan") {
                    internet.title = i18n.tr("Wi-Fi Hotspot Available")
                } else if (internet.title === "wired") {
                    internet.title = i18n.tr("Wired Connection Available (ethernet connection)")
                } else if (internet.title === "terminal") {
                    internet.title = i18n.tr("Computer Terminal Available")
                }

                // Wheelchair values returned by OSM are (yes, no, limited) which are too short
                // and not translated. They are converted to meaningful phrases and also used to
                // set the icon colors for better visibility.
                if (wheelchair.title === "yes") {
                    wheelchair.title = i18n.tr("Available")
                } else if (wheelchair.title === "no") {
                    wheelchair.title = i18n.tr("Not Available")
                    wheelchair.icon.source = Qt.resolvedUrl("../nav/img/poi/wheelchair-negative.svg")
                } else if (wheelchair.title === "limited") {
                    wheelchair.title = i18n.tr("Limited Availability")
                    wheelchair.icon.source = Qt.resolvedUrl("../nav/img/poi/wheelchair-negative.svg")
                }

                if (lat && lng) {
                    mapActionButtonModel.append({mode: "ROUTE", iconName: "send"})
                    mapActionButtonModel.append({mode: "SAVE", iconName: "non-starred"})
                    mapActionButtonModel.append({mode: "NEARBY", iconName: "location"})
                    mapActionButtonModel.append({mode: "SHARE", iconName: "share"})
                }

                if (mainPageStack.ptFromLat === "null" && lat && lng) {
                    mapActionButtonModel.append({mode: "PTFROM", iconName: "transfer-progress-upload"});
                }

                if (mainPageStack.ptFromLat !== "null" && lat && lng) {
                    mapActionButtonModel.append({mode: "PTTO", iconName: "transfer-progress-download"})
                }

                if (phone.title) {
                    poiActionButtonModel.append({mode: "CALL", iconName: "call-start"})
                }

                if (website.title) {
                    poiActionButtonModel.append({mode: "WEB", iconName: "stock_website"})
                }
                
                if (email.title) {
                    poiActionButtonModel.append({mode: "EMAIL", iconName: "email"})
                }
            }
        }

        source: url
        query: "/reversegeocode"

        XmlRole { name: "address"; query: "result/string()" }
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
        XmlRole { name: "lat"; query: "result/@lat/string()"; }
        XmlRole { name: "lng"; query: "result/@lon/string()"; }
    }

    Label {
        id: statusLabel
        wrapMode: Text.WordWrap
        anchors.centerIn: parent
        width: parent.width - units.gu(4)
        horizontalAlignment: Text.AlignHCenter
        visible: poiDetailsModel.status === XmlListModel.Loading
        text: i18n.tr("Loading POI details...")
    }

    // Indicator to show load activity
    ActivityIndicator {
        id: searchActivity
        running: poiDetailsModel.status === XmlListModel.Loading
        anchors { bottom: statusLabel.top; bottomMargin: units.gu (1); horizontalCenter: parent.horizontalCenter }
    }

    ListModel {
        id: mapActionButtonModel
    }

    ListModel{
        id: poiActionButtonModel
    }

    Flickable {
        id: flickable

        anchors.fill: parent
        contentHeight: mainColumn.height + units.gu(10)

        Column {
            id: mainColumn

            spacing: units.gu(3)
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: units.gu(2); topMargin: units.gu(3) }

            CustomGridView {
                id: mapButtonGrid

                itemWidth: units.gu(7)
                model: mapActionButtonModel
                anchors.horizontalCenter: parent.horizontalCenter

                delegate: GridIconDelegate {

                    icon.name: model.iconName

                    onClicked: {
                        if (model.mode === "ROUTE") {
                            if (navApp.settings.saveHistory) {
                                UnavDB.saveToSearchHistory(poiDetailsPage.poiName, mainPageStack.clickedLat, mainPageStack.clickedLng);
                            }
                            if (mainPageStack.columns === 1) {
                                mainPageStack.removePages(mainPageStack.primaryPage)
                            }
                            mainPageStack.center_onpos = 2;
                            mainPageStack.routeState = 'yes'
                            mainPageStack.executeJavaScript("calc2coord("+ mainPageStack.clickedLat + "," + mainPageStack.clickedLng + ");");
                        } else if (model.mode === "SAVE") {
                            var incubator = mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("SearchPage.qml"), {favLat: mainPageStack.clickedLat, favLng: mainPageStack.clickedLng, favName: poiName});
                            incubator.onStatusChanged = function(status) {
                                if (status == Component.Ready) {
                                    incubator.object.addFavorite();
                                }
                            }
                        } else if (model.mode === "SHARE") {
                            mainPageStack.addPageToCurrentColumn(poiDetailsPage, Qt.resolvedUrl("Share.qml"), {"lat": mainPageStack.clickedLat, "lon": mainPageStack.clickedLng})
                        } else if (model.mode === "NEARBY") {
                            mainPageStack.addPageToCurrentColumn(poiDetailsPage, Qt.resolvedUrl("PoiPage.qml"), {"lat": mainPageStack.clickedLat, "lng": mainPageStack.clickedLng})
                        } else if (model.mode === "PTFROM") {
                            if (mainPageStack.columns === 1) {
                                mainPageStack.removePages(mainPageStack.primaryPage)
                            }
                            mainPageStack.ptFromLat = mainPageStack.clickedLat;
                            mainPageStack.ptFromLng = mainPageStack.clickedLng;
                            notificationBar.text =  i18n.tr("Simulate from here! Now click on destination");
                            notificationBar.info();
                            notificationBarTimer.start();
                        } else if (model.mode === "PTTO") {
                            if (mainPageStack.columns === 1) {
                                mainPageStack.removePages(mainPageStack.primaryPage)
                            }
                            mainPageStack.routeState = 'simulate_calculating';
                            mainPageStack.executeJavaScript("simulate2coord(" + mainPageStack.ptFromLat + ", " + mainPageStack.ptFromLng + ", " + mainPageStack.clickedLat + ", " + mainPageStack.clickedLng + ");");
                            mainPageStack.ptFromLat = "null";
                        }
                    }
                }
            }

            CustomGridView {
                id: poiButtonGrid

                visible: poiActionButtonModel.count !== 0
                itemWidth: units.gu(9)
                model: poiActionButtonModel
                anchors.horizontalCenter: parent.horizontalCenter

                delegate: GridIconDelegate {

                    width: units.gu(9)
                    icon.name: model.iconName

                    onClicked: {
                        if (model.mode === "CALL")
                            Qt.openUrlExternally("tel:///" + QmlJs.parse_poi_phone(phone.title))
                        if (model.mode === "WEB")
                            Qt.openUrlExternally(QmlJs.parse_poi_url(website.title))
                        if (model.mode === "EMAIL")
                            Qt.openUrlExternally("mailto:" + email.title)
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: units.dp(0.5)
                color: UbuntuColors.slate
                visible: !searchActivity.running
            }

            PoiDetailRow {
                id: description
                icon.name: "info"
                visible: title
            }

            PoiDetailRow {
                id: address
                icon.name: "location"
                visible: title
            }

            PoiDetailRow {
                id: coordinates
                icon.name: "webbrowser-app-symbolic"
                visible: title
            }

            PoiDetailRow {
                id: cuisine
                icon.source: Qt.resolvedUrl("../nav/img/poi/Restaurant.svg")
                visible: title
            }

            PoiDetailRow {
                id: phone
                icon.name: "call-start"
                visible: title
            }

            PoiDetailRow {
                id: website
                icon.name: "stock_website"
                visible: title
            }

            PoiDetailRow {
                id: email
                icon.name: "email"
                visible: title
            }

            PoiDetailRow {
                id: openingHours
                icon.name: "clock"
                visible: title
            }

            PoiDetailRow {
                id: internet
                icon.name: "network-wifi-symbolic"
                visible: title
            }

            PoiDetailRow {
                id: wheelchair
                icon.source: Qt.resolvedUrl("../nav/img/poi/wheelchair.svg")
                visible: title
            }
        }
    }
}
