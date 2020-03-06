/*
 * GPS Navigation http://launchpad.net/unav
 * Copyright (C) 2015-2018 Marcos Alvarez Costales https://launchpad.net/~costales
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
import "js/utils.js" as QmlJs
import "components"
import "js/db.js" as UnavDB
import QtQuick.LocalStorage 2.0

Page {
    id: poiListPage

    property var lat
    property var lng
    property string poiType: ""
    property string clause: ""
    property string en_label: ""

    property double geoDistFactor: 1.0

    header: UNavHeader {
        title: poiType
        flickable: resultsListView

        trailingActionBar.actions: Action {
            id: routeAction
            iconSource: "../nav/img/header/poimap.svg"
            text: i18n.tr("Show POIs on map")
            visible: sortedPoiModel.count !== 0
            onTriggered: {
                goThereActionPopover.hide();
                
                if (mainPageStack.columns === 1) {
                    mainPageStack.removePages(mainPageStack.primaryPage)
                }
                if (mainPageStack.center_onpos === 2)
                    mainPageStack.center_onpos = 1;
                    
                mainPageStack.executeJavaScript("ui.markers_POI_set(" + JSON.stringify(sortedPoiModel.allPOI()) + ", \"" + poiListPage.en_label + "\")");
            }
        }
    }

    anchors.fill: parent

    Component.onCompleted: {
        resultsListView.visible = false
        if (poiListPage.lat !== "null" && poiListPage.lng !== "null") {
            poiXmlModel.search();
        } else {
            statusLabel.text = i18n.tr("Unknown current position")
            statusLabel.visible = true;
        }
    }

    Label {
        id: statusLabel
        anchors {
            centerIn: parent
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        width: parent.width - units.gu(4)
        visible: poiXmlModel.status === XmlListModel.Loading
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        text: i18n.tr("Something went wrong. Please, try again…")
    }

    // Indicator to show load activity
    ActivityIndicator {
        id: searchActivity
        anchors {
            bottom: statusLabel.top
            bottomMargin: units.gu (1)
            horizontalCenter: parent.horizontalCenter
        }
        running: poiXmlModel.status === XmlListModel.Loading
    }

    Slider {
        id: distSlider
        width: parent.width - units.gu(4)
        anchors {
            top: statusLabel.bottom
            topMargin: units.gu (4)
            horizontalCenter: parent.horizontalCenter
        }
        visible: false
        z: 500

        function formatValue(v) {
            return v.toFixed(0).toString() + (navApp.settings.unit === 0 ? " km" : " mi" )
        }
        minimumValue: 5.0
        maximumValue: 100.0
        value: geoDistFactor <= 25 ? 25.0 : geoDistFactor
        live: true
    }

    Button {
        id: distButton
        visible: false
        z: 500
        width: parent.width *5/8
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: distSlider.bottom
            topMargin: units.gu (3)
        }
        iconName: "reload"
        onClicked: {
            poiListPage.geoDistFactor = distSlider.value
            poiXmlModel.search()
            distButton.visible = false;
            distSlider.visible = false;
        }
    }


    //OSMTouch (lp:osmtouch) POIModel:
    XmlListModel {
        id: poiXmlModel

        onStatusChanged: {

            if (status === XmlListModel.Error) {
                console.log(errorString())
                statusLabel.text = i18n.tr("Time out! Please try again");
                statusLabel.visible = true;
                resultsListView.visible = false;
            }
            if (status === XmlListModel.Ready && count === 0) {
                //TRANSLATORS: This string is search shown when no POIs are found with the chosen search radius. %1 is the POI type eg..Pub, Airport
                // Example string, "Sorry, no Airport found nearby. Try again with a larger search radius"
                statusLabel.text = i18n.tr("Sorry, no %1 found nearby. Try again with a larger search radius").arg(poiType);
                statusLabel.visible = true;
                distButton.visible = true;
                distSlider.visible = true;
                resultsListView.visible = false;
            }
            if (status === XmlListModel.Ready && count >> 0) {
                statusLabel.visible = false;
                sortedPoiModel.sortXmlList();
            }
            if (status === XmlListModel.Loading) { statusLabel.text =  i18n.tr("Searching…") }
        }

        readonly property string baseUrl: "https://nominatim.openstreetmap.org/search?format=xml&bounded=1&limit=50&email=marcos.costales@gmail.com&extratags=1"
        readonly property double geoDist: navApp.settings.unit === 0 ? 0.01 : 0.01 / 0.621371192
        // geographic distance ~1.1km / ~1.1mi
        // rough estimation only. Could be redefined.
        function search() {
            clear();
            // Boxed area in which to search for PoI
            var bbox = ( Number(poiListPage.lng) - geoDist*geoDistFactor).toString() + ","
                     + ( Number(poiListPage.lat) - geoDist*geoDistFactor).toString() + ","
                     + ( Number(poiListPage.lng) + geoDist*geoDistFactor).toString() + ","
                     + ( Number(poiListPage.lat) + geoDist*geoDistFactor).toString();
            source = (baseUrl + "&q=" + clause + "&viewbox=" + bbox);
        }
        function clear() {
            source: "";
        }

        source: ""
        query: "/searchresults/place"

        XmlRole { name: "osm_type"; query: "@osm_type/string()"; }
        XmlRole { name: "osm_id"; query: "@osm_id/string()"; }
        XmlRole { name: "name"; query: "@display_name/string()"; }
        XmlRole { name: "description"; query: "extratags/tag[@key='description']/@value/string()"; }
        XmlRole { name: "phone"; query: "extratags/tag[@key='phone']/@value/string()"; }
        XmlRole { name: "website"; query: "extratags/tag[@key='website']/@value/string()"; }
        XmlRole { name: "email"; query: "extratags/tag[@key='email']/@value/string()"; }
        XmlRole { name: "contactphone"; query: "extratags/tag[@key='contact:phone']/@value/string()"; }
        XmlRole { name: "contactwebsite"; query: "extratags/tag[@key='contact:website']/@value/string()"; }
        XmlRole { name: "contactemail"; query: "extratags/tag[@key='contact:email']/@value/string()"; }
        // XmlRole { name: "cuisine"; query: "extratags/tag[@key='cuisine']/@value/string()"; }
        XmlRole { name: "wheelchair"; query: "extratags/tag[@key='wheelchair']/@value/string()"; }
        XmlRole { name: "openinghours"; query: "extratags/tag[@key='opening_hours']/@value/string()"; }
        XmlRole { name: "lat"; query: "@lat/string()"; }
        XmlRole { name: "lng"; query: "@lon/string()"; }
    }

    ListModel {
        id: sortedPoiModel

        function allPOI() {
            var allPOI = [];
            for (var i = 0; i < sortedPoiModel.count; i++) {
                allPOI.push({
                    title: sortedPoiModel.get(i).name,
                    lat: parseFloat(sortedPoiModel.get(i).lat),
                    lng: parseFloat(sortedPoiModel.get(i).lng),
                    osm_id: sortedPoiModel.get(i).osm_id,
                    osm_type: sortedPoiModel.get(i).osm_type.charAt(0).toUpperCase(),
                    phone: sortedPoiModel.get(i).phone
                });
            }
            return allPOI;
        }

        function sortXmlList (){
            var item;
            var aux_phone;
            var aux_website;
            var aux_email;
            for (var i = 0; i < poiXmlModel.count; i++) {
                if (poiXmlModel.get(i).phone !== '')
                    aux_phone = poiXmlModel.get(i).phone;
                else
                    aux_phone = poiXmlModel.get(i).contactphone;
                if (poiXmlModel.get(i).website !== '')
                    aux_website = poiXmlModel.get(i).website;
                else
                    aux_website = poiXmlModel.get(i).contactwebsite;
                if (poiXmlModel.get(i).email !== '')
                    aux_email = poiXmlModel.get(i).email;
                else
                    aux_email = poiXmlModel.get(i).contactemail;
                item  = {"osm_id":       poiXmlModel.get(i).osm_id,
                         "osm_type":     poiXmlModel.get(i).osm_type.charAt(0).toUpperCase(),
                         "name":         poiXmlModel.get(i).name.split(',')[0],
                         "description":  poiXmlModel.get(i).description,
                         "phone":        aux_phone,
                         "website":      aux_website,
                         "email":        aux_email,
                         // "cuisine":   poiXmlModel.get(i).cuisine,
                         "wheelchair":   poiXmlModel.get(i).wheelchair,
                         "openinghours": poiXmlModel.get(i).openinghours,
                         "lat":          poiXmlModel.get(i).lat,
                         "lng":          poiXmlModel.get(i).lng,
                         "distance":     QmlJs.calcPoiDistance(
                                                                poiListPage.lat,
                                                                poiListPage.lng,
                                                                poiXmlModel.get(i).lat,
                                                                poiXmlModel.get(i).lng,
                                                                10
                                                            ),
                    }
                if (i === 0) {
                    sortedPoiModel.append(item)
                        } else { // sort model by distance
                    var j = 0;
                    while (j <= sortedPoiModel.count) {
                        if (j === sortedPoiModel.count) {
                            sortedPoiModel.append(item)
                            break;
                        } else if (item.distance < sortedPoiModel.get(j).distance){
                           sortedPoiModel.insert(j,item)
                           break;
                        } else {
                            j++;
                        }
                    }
                }
                poiXmlModel.clear();
                resultsListView.visible = true;
            }
        }
    }

    UbuntuListView {
        id: resultsListView

        model: sortedPoiModel
        anchors.fill: parent
        visible: false
        clip: true

        delegate: ListItem {
            height: poiListItemLayout.height + divider.height
            trailingActions:  ListItemActions {
                actions: [
                    Action {
                        iconName: "send"
                        onTriggered: {
                            if (navApp.settings.saveHistory) {
                                UnavDB.saveToSearchHistory(model.name, model.lat, model.lng);
                            }
                            if (mainPageStack.columns === 1)
                                mainPageStack.removePages(mainPageStack.primaryPage)
                            mainPageStack.center_onpos = 2;
                            mainPageStack.routeState = 'yes'
                            mainPageStack.executeJavaScript("calc2coord("+ model.lat + "," + model.lng + ");");
                        }
                    },
                    Action {
                        iconName: "call-start"
                        visible: (model.phone !== "" && model.contactphone !== "")
                        onTriggered: {
                            if (model.phone !== "")
                                Qt.openUrlExternally("tel:///" + QmlJs.parse_poi_phone(model.phone))
                            else
                                Qt.openUrlExternally("tel:///" + QmlJs.parse_poi_phone(model.contactphone))
                        }
                    },
                    Action {
                        iconName: "stock_website"
                        visible: (model.website !== "" && model.contactwebsite !== "")
                        onTriggered: {
                            if (model.website !== "")
                                Qt.openUrlExternally(QmlJs.parse_poi_url(model.website))
                            else
                                Qt.openUrlExternally(QmlJs.parse_poi_url(model.contactwebsite))
                        }
                    },
                    Action {
                        iconName: "email"
                        visible: (model.email !== "" && model.contactemail !== "")
                        onTriggered: {
                            if (model.email !== "")
                                Qt.openUrlExternally("mailto:" + model.email)
                            else
                                Qt.openUrlExternally("mailto:" + model.contactemail)
                        }
                    }
                ]
            }

            onClicked: {
                if (mainPageStack.columns === 1)
                    mainPageStack.removePages(mainPageStack.primaryPage)
                if (mainPageStack.center_onpos === 2)
                    mainPageStack.center_onpos = 1;
                    
                mainPageStack.executeJavaScript("ui.markers_POI_set([{title: \"" + model.name + "\", lat: " + model.lat + ", lng: " + model.lng + ", osm_type: '" + model.osm_type + "', osm_id: " + model.osm_id + ", phone: \"" + model.phone + "\"}], \"" + poiListPage.en_label + "\")");
            }

            ListItemLayout {
                id: poiListItemLayout

                function getOpeningHours(openinghours) {
                    openinghours.replace("Mo", Qt.locale().dayName(1, Locale.ShortFormat)).
                    replace("Tu", Qt.locale().dayName(2, Locale.ShortFormat)).
                    replace("We", Qt.locale().dayName(3, Locale.ShortFormat)).
                    replace("Th", Qt.locale().dayName(4, Locale.ShortFormat)).
                    replace("Fr", Qt.locale().dayName(5, Locale.ShortFormat)).
                    replace("Sa", Qt.locale().dayName(6, Locale.ShortFormat)).
                    replace("Su", Qt.locale().dayName(0, Locale.ShortFormat)).
                    //TRANSLATORS: Abbreviation for Public Holiday. This string is used while showing the opening hours
                    // of a place which might be closed during public holidays.
                    replace("PH", i18n.tr("PH")).
                    //TRANSLATORS: This string indicates that a place is closed.
                    replace("off", i18n.tr("Closed"))

                    return openinghours
                }

                title.text: model.name !== "" ? model.name : poiListPage.poiType
                subtitle.text: model.openinghours !== "" ? "%1 | %2".arg(getOpeningHours(model.openinghours)).arg(QmlJs.formatDistance(model.distance, navApp.settings.unit))
                                                         : QmlJs.formatDistance(model.distance, navApp.settings.unit)
                subtitle.maximumLineCount: 2
                subtitle.wrapMode: Text.WordWrap
                summary.text: model.description
                summary.maximumLineCount: 3

                Icon {
                    id: acessibilityIcon
                    name: "preferences-desktop-accessibility-symbolic"
                    visible: model.wheelchair === "yes" || model.wheelchair === "limited" // is limited enough as criteria?
                    width: units.gu(2)
                    SlotsLayout.position: SlotsLayout.Last
                }
            }
        }

        Scrollbar {
            flickableItem: resultsListView
            align: Qt.AlignTrailing
        }
    }
}
