/*
 * uNav https://github.com/costales/unav
 * Copyright (C) 2016 Nekhelesh Ramananthan https://launchpad.net/~nik90
 *
 * uNav is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * uNav is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Lomiri.Components 1.3

/*
 Component which extends the SDK Expandable list item and provides a easy
 to use component where the title, subtitle and a listview can be displayed. It
 matches the design specification provided for clock.
*/

ListItem {
	id: expandableListItem

	// Public APIs
	property ListModel model
	property Component delegate
	property alias titleText: expandableHeader.title
	property alias subText: expandableHeader.subtitle
	property alias listViewHeight: expandableListLoader.height

	height: headerListItem.height
	expansion.height: headerListItem.height + expandableListLoader.height
	onClicked: toggleExpansion()

	function toggleExpansion() {
		expansion.expanded = !expansion.expanded
	}

	ListItem {
		id: headerListItem
		height: expandableHeader.height + divider.height
		divider.visible: false
		ListItemLayout {
			id: expandableHeader

			subtitle.textSize: Label.Medium
			subtitle.visible: !expansion.expanded
			Icon {
				id: arrow

				width: units.gu(2)
				height: width
				SlotsLayout.position: SlotsLayout.Trailing
				name: "go-down"
				rotation: expandableListItem.expansion.expanded ? 180 : 0

				Behavior on rotation {
					LomiriNumberAnimation {}
				}
			}
		}
	}

	Loader {
		id: expandableListLoader
		width: parent.width
		asynchronous: true
		anchors.top: headerListItem.bottom
		sourceComponent: expandableListItem.expansion.expanded ? expandableListComponent : undefined
	}

	Component {
		id: expandableListComponent
		ListView {
			id: expandableList
			interactive: false
			model: expandableListItem.model
			delegate: expandableListItem.delegate
		}
	}
}
