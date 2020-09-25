/*
 * GPS Navigation https://github.com/costales/unav
 * Copyright (C) 2015-2020 Marcos Alvarez Costales https://costales.github.io
 * Copyright (C) 2016 Nekhelesh Ramananthan https://launchpad.net/~nik90
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

Item {
    id: coordPage

    Row {
        anchors { bottom: coordinateLoader.top; horizontalCenter: coordinateLoader.horizontalCenter; bottomMargin: units.gu(2) }
        height: abstractButton.height

        AbstractButton {
            id: abstractButton
            width: buttonLabel.implicitWidth + units.gu(3)
            height: buttonLabel.implicitHeight + units.gu(2)
            Label {
                id: buttonLabel
                text: i18n.tr("Decimal")
                anchors.centerIn: parent
                color: coordinateLoader.sourceComponent === colCoordDecComponent ? theme.palette.normal.activity : theme.palette.normal.backgroundTertiaryText
            }
            onClicked: coordinateLoader.sourceComponent = colCoordDecComponent
        }

        AbstractButton {
            width: buttonLabel2.implicitWidth + units.gu(3)
            height: buttonLabel2.implicitHeight + units.gu(2)
            Label {
                id: buttonLabel2
                text: i18n.tr("Sexagesimal")
                anchors.centerIn: parent
                color: coordinateLoader.sourceComponent === colCoordPolarComponent ? theme.palette.normal.activity : theme.palette.normal.backgroundTertiaryText
            }
            onClicked: coordinateLoader.sourceComponent = colCoordPolarComponent
        }
    }

    Loader {
        id: coordinateLoader
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: abstractButton.height + units.gu(4)
        }
        height: units.gu(10)
        width: coordinateLoader.sourceComponent === colCoordDecComponent ? units.gu(28) : units.gu(35)
        Component.onCompleted: sourceComponent = colCoordDecComponent
    }

    Component {
        id: colCoordDecComponent
        Column {
            id: colCoordDec

            spacing: units.gu(2)

            Row {
                spacing: units.gu(1)

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: i18n.tr("Lat:")
                    width: units.gu(5)
                }

                TextField {
                    id: lat1
                    maximumLength: 15
                    width: units.gu(22)
                    placeholderText: navApp.settings.default_coord_0a
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }
            }

            Row {
                spacing: units.gu(1)
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: i18n.tr("Long:")
                    width: units.gu(5)
                }

                TextField {
                    id: lng1
                    maximumLength: 15
                    width: units.gu(22)
                    placeholderText: navApp.settings.default_coord_1a
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }
            }

            Button {
                id: showCoordDec
                text: i18n.tr("Show on Map")
                width: units.gu(26)
                anchors.topMargin: units.gu(5)
                anchors.horizontalCenter: parent.horizontalCenter
                color: theme.palette.normal.positive
                onClicked: {
                    lat1.text === "" ? lat1.text = lat1.placeholderText : undefined;
                    lng1.text === "" ? lng1.text = lng1.placeholderText : undefined;

                    navApp.settings.default_coord_0a = lat1.text;
                    navApp.settings.default_coord_1a = lng1.text;

                    try {
                        var aux_lat = lat1.text;
                        var aux_lng = lng1.text;
                        if (!isNaN(aux_lat) && aux_lat.toString().indexOf('.') != -1 && !isNaN(aux_lng) && aux_lng.toString().indexOf('.') != -1 && aux_lat >= -90 && aux_lat <= 90 && aux_lng >= -180 && aux_lng <= 180) { // It's a float
                            if (mainPageStack.columns === 1)
                                mainPageStack.removePages(mainPageStack.primaryPage)
                            mainPageStack.executeJavaScript("import_marker(" + aux_lng + "," + aux_lat + ")");
                        }
                        else {
                            PopupUtils.open(coordDecNotValid)
                        }
                    }
                    catch(e){
                        PopupUtils.open(coordDecNotValid)
                    }
                }
            }

            Component {
                id: coordDecNotValid
                Dialog {
                    id: dialogue
                    title: i18n.tr("Coordinates are not valid")
                    text: i18n.tr("Enter valid decimal coordinates\n\nExpected format is:") + "\n51.506177\n-0.100236"
                    Button {
                        text: i18n.tr("Close")
                        onClicked: PopupUtils.close(dialogue)
                    }
                }
            }
        }
    }

    Component {
        id: colCoordPolarComponent

        Column {
            id: colCoordPolar

            spacing: units.gu(2)

            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: i18n.tr("Lat:")
                    width: units.gu(5)
                }

                TextField {
                    id: lat2a
                    hasClearButton: false
                    width: units.gu(6)
                    placeholderText: navApp.settings.default_coord_2a
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }
                Label {
                    anchors.top: parent.top
                    text: "º"
                    width: units.gu(1)
                }

                TextField {
                    id: lat2b
                    hasClearButton: false
                    width: units.gu(8)
                    placeholderText: navApp.settings.default_coord_2b
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }
                Label {
                    anchors.top: parent.top
                    text: "'"
                    width: units.gu(1)
                }

                TextField {
                    id: lat2c
                    hasClearButton: false
                    width: units.gu(8)
                    placeholderText: navApp.settings.default_coord_2c
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }
                Label {
                    anchors.top: parent.top
                    text: "\""
                    width: units.gu(1)
                }

                UbuntuShape {
                    width: units.gu(4)
                    height: lat2c.height
                    backgroundColor: lat2dMouseArea.pressed ? theme.palette.normal.activity : theme.palette.normal.foreground

                    Label {
                        id: lat2d
                        anchors.centerIn: parent
                        text: navApp.settings.default_coord_2d
                        color: lat2dMouseArea.pressed ? theme.palette.normal.foreground :  theme.palette.normal.backgroundSecondaryText
                    }

                    MouseArea {
                        id: lat2dMouseArea
                        anchors.fill: parent
                        onClicked: {
                            if (lat2d.text === "N")
                                lat2d.text = "S"
                            else
                                lat2d.text = "N"
                        }
                    }
                }
            }

            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: i18n.tr("Long:")
                    width: units.gu(5)
                }

                TextField {
                    id: lng2a
                    hasClearButton: false
                    width: units.gu(6)
                    placeholderText: navApp.settings.default_coord_3a
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }
                Label {
                    anchors.top: parent.top
                    text: "º"
                    width: units.gu(1)
                }

                TextField {
                    id: lng2b
                    hasClearButton: false
                    width: units.gu(8)
                    placeholderText: navApp.settings.default_coord_3b
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }
                Label {
                    anchors.top: parent.top
                    text: "'"
                    width: units.gu(1)
                }

                TextField {
                    id: lng2c
                    hasClearButton: false
                    width: units.gu(8)
                    placeholderText: navApp.settings.default_coord_3c
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }
                Label {
                    anchors.top: parent.top
                    text: "\""
                    width: units.gu(1)
                }

                UbuntuShape {
                    width: units.gu(4)
                    height: lng2c.height
                    backgroundColor: lng2dMouseArea.pressed ? theme.palette.normal.activity : theme.palette.normal.foreground

                    Label {
                        id: lng2d
                        anchors.centerIn: parent
                        text: navApp.settings.default_coord_3d
                        color: lng2dMouseArea.pressed ? theme.palette.normal.foreground :  theme.palette.normal.backgroundSecondaryText
                    }

                    MouseArea {
                        id: lng2dMouseArea
                        anchors.fill: parent
                        onClicked: {
                            if (lng2d.text === "W")
                                lng2d.text = "E"
                            else
                                lng2d.text = "W"
                        }
                    }
                }
            }

            Button {
                id: showCoordPolar
                text: i18n.tr("Show on Map")
                width: units.gu(26)
                anchors.topMargin: units.gu(5)
                anchors.horizontalCenter: parent.horizontalCenter
                color: theme.palette.normal.positive
                onClicked: {
                    lat2a.text === "" ? lat2a.text = lat2a.placeholderText : undefined;
                    lng2a.text === "" ? lng2a.text = lng2a.placeholderText : undefined;
                    lat2b.text === "" ? lat2b.text = lat2b.placeholderText : undefined;
                    lng2b.text === "" ? lng2b.text = lng2b.placeholderText : undefined;
                    lat2c.text === "" ? lat2c.text = lat2c.placeholderText : undefined;
                    lng2c.text === "" ? lng2c.text = lng2c.placeholderText : undefined;

                    navApp.settings.default_coord_2a = lat2a.text;
                    navApp.settings.default_coord_2b = lat2b.text;
                    navApp.settings.default_coord_2c = lat2c.text;
                    navApp.settings.default_coord_2d = lat2d.text.toUpperCase();
                    navApp.settings.default_coord_3a = lng2a.text;
                    navApp.settings.default_coord_3b = lng2b.text;
                    navApp.settings.default_coord_3c = lng2c.text;
                    navApp.settings.default_coord_3d = lng2d.text.toUpperCase();

                    try {
                        var aux_lat_day = parseInt(lat2a.text);
                        var aux_lat_min = parseFloat(lat2b.text);
                        var aux_lat_sec = lat2c.text === "" ? 0 : parseFloat(lat2c.text);
                        var aux_lat_dir = lat2d.text.toUpperCase();
                        var aux_lng_day = parseInt(lng2a.text);
                        var aux_lng_min = parseFloat(lng2b.text);
                        var aux_lng_sec = lng2c.text === "" ? 0 : parseFloat(lng2c.text);
                        var aux_lng_dir = lng2d.text.toUpperCase();

                        if ((!isNaN(aux_lat_day) && !isNaN(aux_lat_min) && !isNaN(aux_lat_sec) && (aux_lat_dir === 'S' || aux_lat_dir === 'N')) &&
                                (!isNaN(aux_lng_day) && !isNaN(aux_lng_min) && !isNaN(aux_lng_sec) && (aux_lng_dir === 'W' || aux_lng_dir === 'E'))) {
                            var aux_lat = aux_lat_day + aux_lat_min/60 + aux_lat_sec/(60*60);
                            if (aux_lat_dir === "S" || aux_lat_dir === "W")
                                aux_lat = aux_lat * -1;

                            var aux_lng = aux_lng_day + aux_lng_min/60 + aux_lng_sec/(60*60);
                            if (aux_lng_dir === "S" || aux_lng_dir === "W")
                                aux_lng = aux_lng * -1;

                            if (aux_lat >= -90 && aux_lat <= 90 && aux_lng >= -180 && aux_lng <= 180) {
                                if (mainPageStack.columns === 1)
                                    mainPageStack.removePages(mainPageStack.primaryPage)
                                mainPageStack.executeJavaScript("import_marker(" + aux_lng + "," + aux_lat + ")");
                            }
                            else {
                                PopupUtils.open(coordPolarNotValid)
                            }
                        }
                        else {
                            PopupUtils.open(coordPolarNotValid)
                        }
                    }
                    catch(e){
                        PopupUtils.open(coordPolarNotValid)
                    }
                }
            }

            Component {
                id: coordPolarNotValid
                Dialog {
                    id: dialogue
                    title: i18n.tr("Coordinates are not valid")
                    text: i18n.tr("Enter valid sexagesimal coordinates\n\nExpected format is:") + "\n51° 30' 22.23'' N\n0° 6' 0.84'' W"
                    Button {
                        text: i18n.tr("Close")
                        onClicked: PopupUtils.close(dialogue)
                    }
                }
            }
        }
    }
}

