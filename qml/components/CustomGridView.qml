/*
 * Copyright (C) 2016 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4

/*
 This component provide a grid view similar to the ubuntu settings app. It was adapted from the ubuntu-settings-app found at
 http://bazaar.launchpad.net/~system-settings-touch/ubuntu-system-settings/trunk/view/head:/src/qml/CategoryGrid.qml
*/

Grid {
    id: gridView

    // Public APIs
    property alias model: repeater.model
    property alias delegate: repeater.delegate

    //from system-settings (lp:ubuntu-system-settings)
    property int itemWidth: units.gu(12)

    // The amount of whitespace, including column spacing
    property int space: Math.min(units.gu(5), parent.width - columns * itemWidth)

    // The column spacing is 1/n of the left/right margins
    property int n: 1

    rowSpacing: units.gu(6)
    columnSpacing: space / ((2 * n) + (columns - 1))
    width: (columns * itemWidth) + columnSpacing * (columns - 1)

    columns: {
        var items = Math.floor(parent.width / itemWidth)
        var count = repeater.count
        return count < items ? count : items
    }
    
    Repeater {
        id: repeater
    }
}
