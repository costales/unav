/*
 * uNav http://launchpad.net/unav
 * Copyright (C) 2015-2020 Marcos Alvarez Costales https://costales.github.io
 * This code is based on Podbird app code
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

// Slide 1
Component {
    id: slide1
    Item {
        id: slide1Container

        Image {
            anchors {
                top: parent.top
                bottom: introductionText.top
                bottomMargin: units.gu(3)
                horizontalCenter: parent.horizontalCenter
            }
            source: Qt.resolvedUrl("img/1.png")
            fillMode: Image.PreserveAspectFit
            antialiasing: true
        }

        Label {
            id: introductionText
            text: i18n.tr("Welcome to uNav")
            fontSize: "x-large"
            height: contentHeight
            anchors.centerIn: parent
        }

        Label {
            id: bodyText
            text: i18n.tr("A map viewer & GPS navigator\n\nLet's look at a few features together :)")
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: units.gu(1)
            anchors.top: introductionText.bottom
            anchors.topMargin: units.gu(4)
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
