/*
 * Copyright 2016 Canonical Ltd.
 *
 * dialer-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * dialer-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3

AbstractButton {
    id: button

    readonly property string defaultColor: "#0F8B21"
    property alias color: shape.backgroundColor
    property alias icon: icon

    width: units.gu(5)
    height: units.gu(5)
    opacity: button.pressed ? 0.5 : (enabled ? 1 : 0.2)

    Behavior on opacity {
        UbuntuNumberAnimation { }
    }

    UbuntuShape {
        id: shape

        aspect: UbuntuShape.Flat
        anchors.fill: parent
        backgroundColor: defaultColor
        radius: "medium"
    }

    Icon {
        id: icon

        anchors.centerIn: parent
        width: units.gu(3)
        height: units.gu(3)
        color: "white"
        z: 1
    }
}
