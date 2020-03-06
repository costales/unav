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

// Slide 4
Component {
    id: slide4
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
            source: Qt.resolvedUrl("img/4.png")
        }

        Label {
            id: introductionText
            anchors.centerIn: parent
            elide: Text.ElideRight
            fontSize: "x-large"
            maximumLineCount: 2
            text: i18n.tr("Touch Everything!")
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            wrapMode: Text.WordWrap
        }

        Label {
            id: finalMessage
            anchors {
                top: introductionText.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: units.gu(1)
                topMargin: units.gu(4)
            }
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: i18n.tr("Touch summary to show current speed\n\nTouch step indications to review route steps")
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}
