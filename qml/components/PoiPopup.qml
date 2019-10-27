/*
 * GPS Navigation http://launchpad.net/unav
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

Rectangle {
    id: popup

    color: "White"
    width: parent.width

    property int showPosition
    property int hidePosition

    property bool isShown: false

    function show() {
        isShown = true
        entranceAnimation.start()
    }

    function hide() {
        exitAnimation.start()
        isShown = false
    }

    Component.onCompleted: {
        // Without this, the popup hides when the height is changed after the popup is visible
        popup.anchors.topMargin = hidePosition
    }

    // This mouse area is to stop any user input from leaking from the popup into the map.
    MouseArea {
        z: -1
        anchors.fill: parent
    }

    UbuntuNumberAnimation {
        id: entranceAnimation
        target: popup
        property: "anchors.topMargin"
        to: showPosition
    }

    UbuntuNumberAnimation {
        id: exitAnimation
        target: popup
        property: "anchors.topMargin"
        to: hidePosition
    }
}
