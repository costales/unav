/*
 * GPS Navigation http://launchpad.net/unav
 * Copyright (C) 2015-2016 JkB https://launchpad.net/~joergberroth
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

Rectangle {
    id: notificationRectangle

    property alias text: notificationLabel.text

    signal info()
    signal warning()
    signal critical()

    onInfo: {
        notificationLabel.color = "#FFFFFF";
        notificationRectangle.color = "#292929";
        notificationRectangle.visible = true;
        notificationIcon.name = "";
        notificationLabel.fontSize = "large";
        notificationRectangle.height = notificationLabel.height + units.gu(1);
    }
    onWarning: {
        notificationLabel.color = "#FFFFFF";
        notificationRectangle.color = UbuntuColors.orange;
        notificationRectangle.visible = true;
        notificationLabel.fontSize = "large";
        notificationIcon.name = "dialog-warning-symbolic"
        notificationRectangle.height = notificationLabel.height + units.gu(4);
    }
    onCritical: {
        notificationLabel.color = "#FFFFFF";
        notificationRectangle.color = UbuntuColors.red;
        notificationRectangle.visible = true;
        notificationLabel.fontSize = "large";
        notificationIcon.name = "dialog-error-symbolic";
        notificationRectangle.height = notificationLabel.height + units.gu(4);
    }

    width: parent.width
    visible: false

    anchors {
        top: goThereActionPopover.isShown ? goThereActionPopover.bottom : navigationPage.header.bottom
    }

    Icon {
        id: notificationIcon
        width: units.gu(3.5)
        height: width
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: units.gu(2)
        }
        visible: name !== ""
        color: "#FFFFFF"

    }

    Label {
        id: notificationLabel
        anchors {
            left: notificationIcon.visible ? notificationIcon.right : parent.left
            margins: units.gu(1)
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        maximumLineCount: 3
        wrapMode: Text.WordWrap
        elide: Text.ElideRight
    }
}
