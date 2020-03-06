/*
 * GPS Navigation http://launchpad.net/unav
 * Copyright (C) 2015-2016 JkB https://launchpad.net/~joergberroth
 * Copyright (C) 2015-2018 Marcos Alvarez Costales https://launchpad.net/~costales
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
import QtQuick.LocalStorage 2.0
import "../js/db.js" as UnavDB
import QtQuick.XmlListModel 2.0

Grid {
    id: gridView

    readonly property int maxQuickAccessItems: 5

    property int itemWidth: units.gu(3.5)

    rowSpacing: units.gu(1)
    columnSpacing: units.gu(2)
    width: (columns * itemWidth) + columnSpacing * (columns - 1)

    columns: 2
    rows: 2
    layoutDirection: Qt.RightToLeft

    ListModel {
        id: quickAccessModel
        function initialize() {
            quickAccessModel.clear();
            var mode;
            if (navApp.settings.routingMode === 0) {mode = "Car"}
            if (navApp.settings.routingMode === 1) {mode = "Walk"}
            if (navApp.settings.routingMode === 2) {mode = "Bike"}
            var res = UnavDB.getQuickAccessItems( mode )
            var len = res.rows.length;
            for ( var i = 0; i < (len <= maxQuickAccessItems ? len : maxQuickAccessItems) ; ++i) {
                quickAccessModel.append(
                            {
                                label: i18n.tr(res.rows.item(i).type),
                                en_label: res.rows.item(i).type,
                                clause: res.rows.item(i).clause,
                                distance: res.rows.item(i).distance
                            }
                            );
            }
            quickAccessModel.insert(0,{label:"add"});
            var gridcolumns = Math.ceil(quickAccessModel.count/2);
            gridView.columns = gridcolumns > 2 ? gridcolumns : 2
        }
        Component.onCompleted: initialize()
    }

    XmlListModel {
        id: poiXmlModel
        property string distance
        property string clause
        property string en_label
        function allPOI() {
            var allPOI = [];
            for (var i = 0; i < poiXmlModel.count; i++) {
                allPOI.push({
                                title: poiXmlModel.get(i).name.split(',')[0],
                                lat: parseFloat(poiXmlModel.get(i).lat),
                                lng: parseFloat(poiXmlModel.get(i).lng),
                                osm_id: poiXmlModel.get(i).osm_id,
                                osm_type: poiXmlModel.get(i).osm_type.charAt(0).toUpperCase(),
                                phone: poiXmlModel.get(i).phone,
                                distance: poiXmlModel.distance
                            });
            }
            return allPOI;
        }

        onStatusChanged: {

            if (status === XmlListModel.Error) {
                console.log(errorString());
                source = "";
                notificationBarTimer.start();
                notificationBar.text = i18n.tr("Error getting results. Please, check your data connection.");
                notificationBar.critical();
            }
            if (status === XmlListModel.Ready && count === 0) {
                notificationBarTimer.start();
                notificationBar.text = i18n.tr("Sorry, no results found nearby.");
                notificationBar.info();
            }
            if (status === XmlListModel.Ready && count >> 0) {
                notificationBar.visible = false;
                mainPageStack.executeJavaScript("ui.markers_POI_set(" + JSON.stringify(poiXmlModel.allPOI()) + ", \"" + poiXmlModel.en_label + "\")");
                mainPageStack.center_onpos = 1;
                goThereActionPopover.hide();
            }
        }

        readonly property string baseUrl: "https://nominatim.openstreetmap.org/search?format=xml&bounded=1&limit=50&email=marcos.costales@gmail.com&extratags=1"
        readonly property double geoDist: navApp.settings.unit === 0 ? 0.01 : 0.01 / 0.621371192
        // geographic distance ~1.1km / ~1.1mi
        // rough estimation only. Could be redefined.

        function search() {
            // Boxed area in which to search for PoI
            var bbox = ( Number(mainPageStack.currentLng) - geoDist*distance).toString() + ","
                    + ( Number(mainPageStack.currentLat) - geoDist*distance).toString() + ","
                    + ( Number(mainPageStack.currentLng) + geoDist*distance).toString() + ","
                    + ( Number(mainPageStack.currentLat) + geoDist*distance).toString();
            source = (baseUrl + "&q=" + clause + "&viewbox=" + bbox);
        }
        function clear() {
            source = "";
        }

        source: ""
        query: "/searchresults/place"

        XmlRole { name: "osm_type"; query: "@osm_type/string()"; }
        XmlRole { name: "osm_id"; query: "@osm_id/string()"; }
        XmlRole { name: "name"; query: "@display_name/string()"; }
        XmlRole { name: "phone"; query: "extratags/tag[@key='phone']/@value/string()"; }
        XmlRole { name: "lat"; query: "@lat/string()"; }
        XmlRole { name: "lng"; query: "@lon/string()"; }
    }

    Repeater {

        model: quickAccessModel

        delegate: AbstractButton {
            id: button
            width: units.gu(4)
            height: width
            opacity: button.pressed ? 0.5 : (enabled ? 1 : 0.2)

            Behavior on opacity {
                UbuntuNumberAnimation { }
            }

            UbuntuShape {
                id: shape

                aspect: UbuntuShape.Flat
                anchors.fill: parent
                radius: "medium"
            }

            Icon {
                source: model.label !== "add" ? Qt.resolvedUrl("../../nav/img/poi/" + model.en_label + ".svg"): "../../nav/img/header/poiConfig.svg"
                opacity: 0.6 //model.label === "add" ? 1 :0.6
                width: units.gu(3.25)
                enabled: navigationPage.buttonsEnabled

                anchors.centerIn: parent
                color: UbuntuColors.slate
            }
            onClicked: {
                if (model.label === "add") {
                    goThereActionPopover.hide();
                    mainPageStack.showSideBar();
                    mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("../PoiQuickAccessPage.qml"));
                } else {
                    if (mainPageStack.currentLat === 'null' || mainPageStack.currentLng === 'null') {
                        goThereActionPopover.hide();
                        notificationBar.text = i18n.tr("Current position unknown. Try again after a position update.");
                        notificationBar.info();
                        notificationBarTimer.start();
                    }
                    else {
                        poiXmlModel.clear();
                        notificationBar.text = i18n.tr("Searching…");
                        notificationBar.info();
                        poiXmlModel.distance = model.distance;
                        poiXmlModel.clause = model.clause;
                        poiXmlModel.en_label = model.en_label;
                        poiXmlModel.search();
                        mainPageStack.executeJavaScript("ui.markers_POI_clear()");
                    }
                }
            }
        }
    }
}

    
