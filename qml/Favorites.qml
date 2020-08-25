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
import Ubuntu.Components.Popups 1.3
import QtQuick.LocalStorage 2.0
import "js/db.js" as UnavDB
import "components"

Item {
    id: favoritesPage

    property string lat
    property string lng
    property string favName
    property string favName_edit: ""

    property ListView flickable: favoritesListView

    function addFavoriteDialog() {
        PopupUtils.open(addFavorite)
    }

    ListModel {
        id: favoritesModel
        Component.onCompleted: initialize()
        function initialize() {
            favoritesModel.clear();
            var res = UnavDB.getFavorites();
            for (var i = 0; i < res.rows.length; ++i) {
                favoritesModel.append({ 
                    name: res.rows.item(i).key,
                    lat:  res.rows.item(i).lat,
                    lng:  res.rows.item(i).lng
                });
            }
        }
    }

    ListView {
        id: favoritesListView

        model: favoritesModel
        anchors.fill: parent
        clip: true

        displaced: Transition {
            UbuntuNumberAnimation { property: "y"; duration: UbuntuAnimation.BriskDuration }
        }

        delegate: ListItem {
            id: delegate

            height: favouriteDelegateLayout.height + divider.height
            leadingActions:  ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"
                        onTriggered: {
                            UnavDB.removeFavorite(model.name);
                            favoritesModel.remove(index, 1)
                        }
                    }
                ]
            }

            trailingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "send"
                        onTriggered: {
                            if (mainPageStack.columns === 1)
                                mainPageStack.removePages(searchPage);
                            mainPageStack.executeJavaScript("BtnGo(" + model.lng + "," + model.lat + ")");
                        }
                    },
                    Action {
                        iconName: "share"
                        onTriggered: {
                            mainPageStack.addPageToCurrentColumn(searchPage, Qt.resolvedUrl("Share.qml"), {"lat": model.lat, "lng": model.lng});
                        }
                    },
                    Action {
                        iconName: "edit"
                        onTriggered: {
                            favoritesPage.lat = model.lat;
                            favoritesPage.lng = model.lng;
                            favoritesPage.favName_edit = model.name;
                            favoritesPage.favName = model.name;
                            PopupUtils.open(addFavorite, favoritesPage);
                        }
                    }
                ]
            }

            ListItemLayout {
                id: favouriteDelegateLayout
                title.text: model.name

                Icon {
                    name: "starred"
                    width: units.gu(2.5)
                    height: width
                    color: UbuntuColors.jet
                    SlotsLayout.position: SlotsLayout.First
                    SlotsLayout.overrideVerticalPositioning: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            onClicked: {
                if (mainPageStack.columns === 1)
                    mainPageStack.removePages(searchPage);
                mainPageStack.executeJavaScript("import_marker(" + model.lng + "," + model.lat + ",\"" + model.name + "\", \"\", true)");
            }
        }
    }

    Component {
        id: addFavorite
        Dialog {
            id: dialogue

            property bool isOverwriteMode: false

            title: i18n.tr("Edit Favorite")
            text: isOverwriteMode ? i18n.tr("There is already a favorite with that name. You can either overwrite it or enter a different name.") : ""

            Component.onCompleted: favNameField.forceActiveFocus()

            // Function to check if the name entered by the user is already used by any other favorite
            function checkFavoriteNameConflict() {
                var exist_fav = UnavDB.getFavorite(favNameField.text)
                if (exist_fav[0] === null || exist_fav[1] === null) {
                    return false
                } else {
                    return true
                }
            }

            // Function to clear all used variables and reset state
            function clear() {
                favoritesPage.favName = ""
                favoritesPage.favName_edit = ""
                favoritesPage.lat = ""
                favoritesPage.lng = ""
            }

            // Function to delete the edited favorite
            function deleteExistingFavorite() {
                if (favoritesPage.favName_edit !== "") {
                    UnavDB.removeFavorite(favoritesPage.favName_edit)
                }
            }

            TextField {
                id: favNameField
                width: parent.width
                hasClearButton: true
                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: i18n.tr("Favorite Name")
                text: favoritesPage.favName
                onTextChanged: {
                    var isTextValid = favNameField.text.trim() && favoritesPage.favName_edit !== favNameField.text
                    if (isTextValid) {
                        isOverwriteMode = checkFavoriteNameConflict()
                    }
                }
            }

            Column {
                width: parent.width
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: units.gu(2)
                    Button {
                        text: i18n.tr("Cancel")
                        onClicked: {
                            clear()
                            PopupUtils.close(dialogue)
                        }
                    }
                    Button {
                        text: isOverwriteMode ? i18n.tr("Overwrite") : i18n.tr("Update")
                        color: isOverwriteMode ? UbuntuColors.red : UbuntuColors.green
                        enabled: favNameField.text.trim() && favoritesPage.favName_edit !== favNameField.text
                        onClicked: {
                            UnavDB.saveFavorite(favNameField.text, favoritesPage.lat, favoritesPage.lng);
                            deleteExistingFavorite()
                            favoritesModel.initialize()
                            clear()
                            PopupUtils.close(dialogue)
                        }
                    }
                }
            }
        }
    }

}

