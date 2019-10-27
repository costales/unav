/*
 * uNav http://launchpad.net/unav
 * Copyright (C) 2015-2018 Marcos Alvarez Costales https://launchpad.net/~costales
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
import "js/utils.js" as QmlJs
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
            creditsModel.append({ category: i18n.tr("Resources"), name: i18n.tr("Translations"), link: "https://translations.launchpad.net/unav" })
            creditsModel.append({ category: i18n.tr("Resources"), name: i18n.tr("Answers"), link: "https://answers.launchpad.net/unav" })
            creditsModel.append({ category: i18n.tr("Resources"), name: i18n.tr("Bugs"), link: "https://bugs.launchpad.net/unav" })
            creditsModel.append({ category: i18n.tr("Resources"), name: i18n.tr("Contact"), link: "mailto:costales.marcos@gmail.com" })

            // Developers
            creditsModel.append({ category: i18n.tr("Developers"), name: "Dan Chapman", link: "https://launchpad.net/~dpniel" })
            creditsModel.append({ category: i18n.tr("Developers"), name: "JkB", link: "https://launchpad.net/~joergberroth" })
            creditsModel.append({ category: i18n.tr("Developers"), name: "Marcos Costales (" + i18n.tr("Founder") + ")", link: "https://wiki.ubuntu.com/costales" })
            creditsModel.append({ category: i18n.tr("Developers"), name: "Nekhelesh Ramananthan", link: "https://launchpad.net/~nik90" })
            creditsModel.append({ category: i18n.tr("Developers"), name: "Olivier Tilloy", link: "https://launchpad.net/~osomon" })

            // Voices
            creditsModel.append({ category: i18n.tr("Voice"), name: navApp.settings.currentVoice });
            
            // Artwork
            creditsModel.append({ category: i18n.tr("Logo"), name: "Sam Hewitt", link: "http://samuelhewitt.com/" })
            // States
            creditsModel.append({ category: i18n.tr("Icons for empty states"), name: "Anush Arutunyan", link: "https://thenounproject.com/term/star/152176/" })
            creditsModel.append({ category: i18n.tr("Icons for empty states"), name: "Gustavo da Cunha Pimenta", link: "https://www.flickr.com/photos/guspim/3428847582/" })
            creditsModel.append({ category: i18n.tr("Icons for empty states"), name: "Albertsab", link: "https://commons.wikimedia.org/wiki/File:Pac_Man.svg" })
            
            // Translators
            var translators = QmlJs.getTranslators( i18n.tr("translator-credits") )
            translators.forEach(function(translator) {
                creditsModel.append({ category: i18n.tr("Translators"), name: translator['name'], link: translator['link'] });
            });

            // Powered By
            creditsModel.append({ category: i18n.tr("Powered by"), name: "OpenStreetMap & Contributors", link: "http://www.openstreetmap.org" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "Openroute Service", link: "https://openrouteservice.org" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "Carto", link: "https://carto.com" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "Stamen", link: "http://stamen.com" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "OpenTopoMap", link: "https://opentopomap.org" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "Mapbox", link: "https://www.mapbox.com" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "OpenStreetMap Nominatin", link: "http://open.mapquestapi.com/nominatim" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "Overpass API", link: "http://wiki.openstreetmap.org/wiki/Overpass_API/XAPI_Compatibility_Layer" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "OpenLayers", link: "http://openlayers.org" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "Turf.js", link: "http://turfjs.org" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "JQuery", link: "https://jquery.com" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "jquery.localize.js", link: "https://github.com/coderifous/jquery-localize" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "The Noun Project", link: "https://thenounproject.com" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "Wikimedia", link: "https://commons.wikimedia.org/wiki/Category:Multi-touch_gestures" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "IconFinder", link: "https://www.iconfinder.com/icons/172062/navigation_icon" })
            creditsModel.append({ category: i18n.tr("Powered by"), name: "Leaflet Marker", link: "https://github.com/Leaflet/Leaflet" })
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
                    //TRANSLATORS: %1 and %2 are links that do not have to be translated: Year + Project + License
                    text: "© <a href='http://unav.me'>uNav</a> 2015-" + new Date().getFullYear()
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    //TRANSLATORS: %1 and %2 are links that do not have to be translated: Year + Project + License
                    text: i18n.tr("Version %1. Under license %2").arg(navApp.applicationVersion).arg("<a href=\"http://www.gnu.org/licenses/gpl-3.0.en.html\">GPL3</a>")
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

