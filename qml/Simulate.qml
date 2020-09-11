/*
 * GPS Navigation http://launchpad.net/unav
 * Copyright (C) 2015-2020 Marcos Alvarez Costales https://costales.github.io
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

Item {
    id: gpx
    
    Column {
        id: simulate
        anchors.centerIn: parent
        spacing: units.gu(1)
        Label {
            text: i18n.tr("Simulate a route picking positions on the map")
            anchors.horizontalCenter: parent.horizontalCenter
       }
        Button {
            id: btnFrom
            text: i18n.tr("Pick positions")
            enabled: !mainPageStack.simulateRoute
            width: units.gu(30)
            anchors.topMargin: units.gu(35)
            anchors.horizontalCenter: parent.horizontalCenter
            color: theme.palette.normal.positive
            onClicked: {
                if (mainPageStack.columns === 1)
                    mainPageStack.removePages(searchPage);
                mainPageStack.executeJavaScript("ui.set_pickingOnMap(1)");
            }
        }
    }
}