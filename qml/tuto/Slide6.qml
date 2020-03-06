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

// Slide 6
Component {
    id: slide6
    Item {
        id: slide1Container

        Image {
            anchors {
                top: parent.top
                bottom: introductionText.top
                bottomMargin: units.gu(3)
                horizontalCenter: parent.horizontalCenter
            }
            fillMode: Image.PreserveAspectFit
            source: Qt.resolvedUrl("img/1.png")
        }

        Label {
            id: introductionText
            anchors.centerIn: parent
            elide: Text.ElideRight
            fontSize: "x-large"
            maximumLineCount: 2
            text: i18n.tr("uNav doesn't track you!")
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            wrapMode: Text.WordWrap
        }

        Label {
            id: finalMessage
            anchors {
                top: introductionText.bottom
                bottom: continueButton.top
                left: parent.left
                right: parent.right
                margins: units.gu(1)
                topMargin: units.gu(4)
            }
            horizontalAlignment: Text.AlignHCenter
            text: i18n.tr("It is licensed under the GNU GPL\n\nand based completely on libre projects!") + " :)"
            wrapMode: Text.WordWrap
        }

        Button {
            id: continueButton
            anchors {
                bottom: parent.bottom
                bottomMargin: units.gu(3)
                horizontalCenter: parent.horizontalCenter
            }
            height: units.gu(6)
            width: parent.width/1.3
            color: UbuntuColors.green
            text: i18n.tr("Enjoy the Freedom!")
            onClicked: finished()
        }
    }
}
