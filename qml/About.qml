/*
 * uNav http://launchpad.net/unav
 * Copyright (C) 2015-2020 Marcos Alvarez Costales https://costales.github.io
 * Copyright (C) 2015-2016 JkB https://launchpad.net/~joergberroth
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
import "components"

Page {
    id: aboutPage

    header: UNavHeader {
        title: i18n.tr("About")
        flickable: creditsListView
    }

    ListModel {
        id: creditsModel

        Component.onCompleted: initialize()

        function initialize() {
            // Resources
            creditsModel.append({ category: i18n.tr("Resources"), name: i18n.tr("Translations"), link: "https://poeditor.com/join/project/fzREtiyZVY" })
            creditsModel.append({ category: i18n.tr("Resources"), name: i18n.tr("Code"), link: "https://github.com/costales/unav" })
            creditsModel.append({ category: i18n.tr("Resources"), name: i18n.tr("Bugs"), link: "https://github.com/costales/unav/issues" })

            // Developers
            creditsModel.append({ category: i18n.tr("Developers"), name: "Aaron", link: "https://nanu-c.org/" })
            creditsModel.append({ category: i18n.tr("Developers"), name: "Dan Chapman", link: "https://launchpad.net/~dpniel" })
            creditsModel.append({ category: i18n.tr("Developers"), name: "JkB", link: "https://launchpad.net/~joergberroth" })
            creditsModel.append({ category: i18n.tr("Developers"), name: "Joan CiberSheep", link: "https://gitlab.com/cibersheep" })
            creditsModel.append({ category: i18n.tr("Developers"), name: "Marcos Costales (" + i18n.tr("Founder") + ")", link: "https://costales.github.io/" })
            creditsModel.append({ category: i18n.tr("Developers"), name: "Nekhelesh Ramananthan", link: "https://launchpad.net/~nik90" })
            creditsModel.append({ category: i18n.tr("Developers"), name: "Olivier Tilloy", link: "https://launchpad.net/~osomon" })

            // Voices
            creditsModel.append({ category: i18n.tr("Voice"), name: navApp.settings.speakVoice });
            
            // Artwork
            creditsModel.append({ category: i18n.tr("Logo"), name: "Sam Hewitt", link: "http://samuelhewitt.com/" })
            
            // Translators
            creditsModel.append({ category: i18n.tr("Translators"), name: "Ubuntu Translators Community", link: "https://translations.launchpad.net/unav" })
            
            // Powered By
            creditsModel.append({ category: i18n.tr("Powered by"), name: "OpenStreetMap & Contributors", link: "http://www.openstreetmap.org" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "OSM Scout Server", link: "https://open-store.io/app/osmscout-server.jonnius" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "Carto Maps", link: "https://carto.com" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "Stadia Maps", link: "https://stadiamaps.com" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "OpenStreetMap Nominatin", link: "https://nominatim.org" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "Photon", link: "http://photon.komoot.de" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "Overpass API", link: "http://wiki.openstreetmap.org/wiki/Overpass_API/XAPI_Compatibility_Layer" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "OpenLayers", link: "http://openlayers.org" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "ol-ext", link: "https://viglino.github.io/ol-ext/" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "Turf", link: "http://turfjs.org" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "GPXParser", link: "https://luuka.github.io/GPXParser.js" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "doTimeout", link: "http://benalman.com/projects/jquery-dotimeout-plugin" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "JQuery", link: "https://jquery.com" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "jQuery Localize", link: "https://github.com/coderifous/jquery-localize" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "The Noun Project", link: "https://thenounproject.com" })
        }
    }

    ListView {
        id: creditsListView

        model: creditsModel
        anchors.fill: parent
        section.property: "category"
        section.criteria: ViewSection.FullString
        section.delegate: ListItemHeader {
            title: section
        }

        header: Item {
            width: parent.width
            height: appColumn.height + units.gu(10)
            Column {
                id: appColumn
                spacing: units.gu(1)
                anchors {
                    top: parent.top; left: parent.left; right: parent.right; topMargin: units.gu(5)
                }
                Image {
                    id: appImage
                    source: "../nav/img/about/logo.png"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: "© uNav 2015-%2".arg(new Date().getFullYear())
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("Version %1 Licensed under %2").arg(navApp.applicationVersion).arg("<a href=\"http://www.gnu.org/licenses/gpl-3.0.en.html\">GPL3</a>")
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: "<i>" + i18n.tr("Dedicated to the memory of") + " Sergi Quilles</i>"
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
        }

        delegate: ListItem {
            height: creditsDelegateLayout.height
            divider.visible: false
            ListItemLayout {
                id: creditsDelegateLayout
                title.text: model.name
                ProgressionSlot {}
            }
            onClicked: Qt.openUrlExternally(model.link)
        }
    }
}

