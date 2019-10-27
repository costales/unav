/*
 * GPS Navigation http://launchpad.net/unav
 * Copyright (C) 2015-2018 Marcos Alvarez Costales https://launchpad.net/~costales
 * Copyright (C) 2015-2016 JkB https://launchpad.net/~joergberroth
 * Copyright (C) 2016 Dan Chapman https://launchpad.net/~dpniel
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
import QtQuick.XmlListModel 2.0
import "components"

Page {
    id: routeInfoListPage

    property var routeList

    header: UNavHeader {
        title: i18n.tr("Route Info")
        flickable: resultsListView
        trailingActionBar.actions: CloseHeaderAction {}
    }

    anchors.fill: parent

    Component.onDestruction: {
        // Hide 2nd column when returning to the map to avoid an empty white column
        if (mainPageStack.columns === 1)
            mainPageStack.hideSideBar()
    }

    ListModel {
        id: routeInfoListModel

        function initializeList (){
            var item
            for ( var i = 0; i < routeList.length; i++) {
                item  = {
                    "type": routeList[i].type,
                    "lng": routeList[i].coordinates[0],
                    "lat": routeList[i].coordinates[1],
                    "instruction": routeList[i].instruction,
                    "distance": routeList[i].distance,
                    "duration": routeList[i].duration,
                    "speaked": routeList[i].speaked,
                }
                routeInfoListModel.append(item);
            }
        }
    }
    // Note: No need for UbuntuListView here as no expanding animations
    // are being used.
    ListView {
        id: resultsListView

        model: routeInfoListModel

        anchors.fill: parent
        visible: false

        delegate: ListItem {

            height: routeInfoLayout.implicitHeight

            ListItemLayout {
                id: routeInfoLayout

                title.text: instruction
                title.color: !speaked ? UbuntuColors.darkGrey : UbuntuColors.lightGrey
                title.textFormat: Text.RichText // Hack: Space character in translations
                title.wrapMode: Text.WordWrap

                UbuntuShape {
                    aspect: UbuntuShape.Flat
                    height: units.gu(6); width: height
                    sourceScale: Qt.vector2d(0.8, 0.8)
                    radius: "small"
                    backgroundColor: "#292929"
                    source: Image {
                        source: Qt.resolvedUrl("../nav/img/steps/" + type + ".svg")
                    }
                    sourceFillMode: UbuntuShape.PreserveAspectFit
                    sourceHorizontalAlignment: UbuntuShape.AlignHCenter

                    // We want this on the left side of the main slot
                    SlotsLayout.position: SlotsLayout.Leading
                }

                Item {
                    id: inner_infoCol

                    height: inner_timeLabel.height + units.gu(1) + inner_distanceLabel.height
                    width: Math.max(inner_timeLabel.width, inner_distanceLabel.width + units.gu(1))
                    SlotsLayout.overrideVerticalPositioning: true

                    Label {
                        id: inner_timeLabel
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(1.5)
                        anchors.right: parent.right
                        text: duration !== 0 ? ( (duration/60).toFixed(1) + " min" ) : ""
                        textSize: Label.Small
                    }

                    Label {
                        id: inner_distanceLabel
                        anchors.right: parent.right
                        anchors.top: inner_timeLabel.bottom
                        anchors.topMargin: units.gu(2)
                        text: distance !== 0 ? ( (distance/1000).toFixed(2) + (navApp.settings.unit === 1 ? " mi" : " km") ) : ""
                        textSize: Label.Small
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        routeInfoListModel.initializeList();
        resultsListView.visible = true
    }
}
