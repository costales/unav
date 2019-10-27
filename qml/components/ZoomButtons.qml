/*
 * GPS Navigation http://launchpad.net/unav
 * Copyright (C) 2015-2018 Marcos Alvarez Costales https://launchpad.net/~costales
 * Copyright (C) 2016 Nekhelesh Ramananthan https://launchpad.net/~nik90
 * Copyright (C) 2015-2016 JkB https://launchpad.net/~joergberroth
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

Rectangle {
    id: zoomButtons
    
    // Check to ensure zoom animation is executed on app startup
    property bool isColdStart: true

    // Signals to zoom in/out
    signal zoomedIn()
    signal zoomedOut()
    
    color: "Transparent"
    radius: units.gu(2)
    width: zoomIn.width + units.gu(2)
    height: zoomIn.height + zoomOut.height

    anchors {
        right: parent.right
        verticalCenter: parent.verticalCenter
    }
    
    onVisibleChanged: {
        if (visible && isColdStart) {
            zoomAnimation.start()
            isColdStart = false
        }
    }
    
    Rectangle {
        opacity: 0.5
        radius: parent.radius
        anchors.fill: parent
        color: UbuntuColors.jet
    }
    
    ActionIcon {
        id: zoomIn
        icon.name: "zoom-in"
        icon.width: units.gu(3)
        icon.color: "white"
        onClicked: zoomedIn()
        anchors { top: parent.top; left: parent.left }
    }
    
    ActionIcon {
        id: zoomOut
        icon.name: "zoom-out"
        icon.width: units.gu(3)
        icon.color: "white"
        onClicked: zoomedOut()
        anchors { bottom: parent.bottom; left: parent.left }
    }
    
    UbuntuNumberAnimation {
        id: zoomAnimation
        target: zoomButtons
        property: "anchors.rightMargin"
        from: -zoomButtons.width
        to: units.gu(-2)
    }
}
