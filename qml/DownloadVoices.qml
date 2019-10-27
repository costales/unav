/*
 * uNav http://launchpad.net/unav
 * Copyright (C) 2015-2018 Marcos Alvarez Costales https://launchpad.net/~costales
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
import QtQuick.XmlListModel 2.0
import Ubuntu.Components.Popups 1.3
import Ubuntu.DownloadManager 1.2
import io.thp.pyotherside 1.4
import "components"


Page {
    id: downloadVoices

    property string voice: ''
    property bool downloading: false
    property bool canceled: false

    Component.onDestruction: { // Return to Settings
        mainPageStack.executeJavaScript("load_custom_voices(false)");
        if (mainPageStack.columns === 1) {
            mainPageStack.showSideBar();
            mainPageStack.addPageToNextColumn(mainPageStack.primaryPage, Qt.resolvedUrl("SettingsPage.qml"));
        }
    }

    SingleDownload {
        id: singleDownload
        onFinished: {
            downloadVoices.downloading = false;
            if (!downloadVoices.canceled) {
                navApp.settings.currentVoice = downloadVoices.voice;
                py.mvVoice(path);
            }
        }
    }

    header: UNavHeader {
        id: headerDownload
        title: i18n.tr("Download voices")
        flickable: voicesListView
        trailingActionBar.actions: [
            CloseHeaderAction {},
            Action {
                id: actionInfo
                visible: !downloadVoices.downloading
                iconName: "media-playback-start"
                text: i18n.tr("Play current voice")
                onTriggered: {
                    mainPageStack.executeJavaScript("ui.play_test(true)");
                }
            },
            Action {
                id: actionPlay
                visible: !downloadVoices.downloading
                iconName: "info"
                text: i18n.tr("How to add a voice")
                onTriggered: PopupUtils.open(addVoiceComponent);
            }
        ]
    }

    Python {
        id: py

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("./py"));
            importModule("fsutils", function() {});
        }

        function rmOlder() {
            py.call("fsutils.rm_older", [], function () {});
        }

        function mvVoice(tar) {
            py.call("fsutils.mv_voice", [tar], function () {});
        }
    }

    ActivityIndicator {
        id: searchActivity
        anchors {
            centerIn: parent
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        running: voicesModel.status === XmlListModel.Loading
    }

    XmlListModel {
        id: voicesModel
        source: "http://people.ubuntu.com/~costales/unav/voices/voices.xml?date=" + Date.now()
        query: "/Voices/Voice"

        XmlRole { name: "starred";     query: "@starred/string()" }
        XmlRole { name: "voice_code";  query: "@voice_code/string()" }
        XmlRole { name: "iso";         query: "@iso/string()" }
        XmlRole { name: "lang";        query: "@lang/string()" }
        XmlRole { name: "gender";      query: "@gender/string()" }
        XmlRole { name: "author";      query: "@author/string()" }
        XmlRole { name: "kb";          query: "@kb/string()" }
        XmlRole { name: "version";     query: "@version/string()" }
    }

    SortFilterModel {
        id: sortedVoicesModel
        model: voicesModel
        sort.property: "lang"
    }

    ListView {
        id: voicesListView
        anchors.fill: parent
        visible: !downloadVoices.downloading
        model: sortedVoicesModel
        delegate: ListItem {

            ListItemLayout {
                id: listItemVoice

                title.text: model.lang
                title.color: UbuntuColors.darkGrey
                title.textFormat: Text.RichText
                title.wrapMode: Text.WordWrap

                UbuntuShape {
                    aspect: UbuntuShape.Flat
                    height: units.gu(3); width: height
                    sourceScale: Qt.vector2d(0.8, 0.8)
                    radius: "small"
                    source: Image {
                        source: model.author === navApp.settings.currentVoice ? Qt.resolvedUrl("../nav/img/voices/tick.svg") : Qt.resolvedUrl("../nav/img/voices/no-tick.svg")
                    }
                    sourceHorizontalAlignment: UbuntuShape.AlignHCenter
                    SlotsLayout.position: SlotsLayout.Leading
                }
                Item {
                    id: inner_infoCol
                    height: inner_author.height + units.gu(1) + inner_size.height
                    width: Math.max(inner_author.width, inner_size.width + units.gu(1))
                    SlotsLayout.overrideVerticalPositioning: true

                    Label {
                        id: inner_author
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(1.1)
                        anchors.right: parent.right
                        text: i18n.tr("By ") + model.author
                        textSize: Label.Small
                    }

                    Label {
                        id: inner_size
                        anchors.right: parent.right
                        anchors.top: inner_author.bottom
                        anchors.topMargin: units.gu(0)
                        text: (model.gender === 'm' ? '♂' : '♀') + ' ‧ ' + model.version + ' ‧ ' + model.kb + "KB"
                        textSize: Label.Small
                    }
                }

            }

            onClicked: {
                console.log('Downloading voice: ' + model.voice_code);

                downloadVoices.voice = model.author;
                downloadVoices.downloading = true;
                downloadVoices.canceled = false;

                py.rmOlder();

                singleDownload.download("http://people.ubuntu.com/~costales/unav/voices/unav_" + model.voice_code + ".tar.gz");
            }
        }
    }

    Column {
        id: pgbar
        visible: downloadVoices.downloading
        anchors.centerIn: parent
        width: units.gu(20)
        spacing: units.gu(3)
        Row {
            ProgressBar {
                id: pg_down
                minimumValue: 0
                maximumValue: 100
                value: singleDownload.progress
                width: pgbar.width
            }
        }
        Row {
            Button {
                text: i18n.tr("Cancel Download")
                color: UbuntuColors.red
                width: pgbar.width
                onClicked: {
                    singleDownload.cancel
                    downloadVoices.downloading = false;
                    downloadVoices.canceled = true;
                }
            }
        }
    }

    Component {
         id: addVoiceComponent
         Dialog {
            id: addVoice
            title: i18n.tr("About the voices")
            Label {
                width: parent.width
                color: UbuntuColors.slate
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: i18n.tr("The stars are for the recommended voices.")
                onLinkActivated: Qt.openUrlExternally(link)
            }
            Label {
                width: parent.width
                color: UbuntuColors.slate
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: i18n.tr("You can add a new voice to uNav following these steps:")
                onLinkActivated: Qt.openUrlExternally(link)
            }
            Label {
                width: parent.width
                color: UbuntuColors.slate
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: "<a href='http://people.ubuntu.com/~costales/unav/voices/'>" + i18n.tr("How to add a voice") + "</a>"
                onLinkActivated: Qt.openUrlExternally(link)
            }
            Button {
                text: i18n.tr("Close")
                onClicked: {
                    PopupUtils.close(addVoice)
                }
            }
        }
    }

}
