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

Item {
    id: address
    
    width: parent.width
    height: Math.max(icon.height, title.implicitHeight)
    
    property alias icon: icon
    property alias title: title.text
    
    Icon {
        id: icon
        width: units.gu(2.5)
        height: width
        color: UbuntuColors.jet
        anchors { verticalCenter: parent.veticalCenter; left: parent.left }
    }
    
    Label {
        id: title
        text: ""
        wrapMode: Text.WordWrap
        anchors { left: icon.right; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: units.gu(2) }
    }
}
