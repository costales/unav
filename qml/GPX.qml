/*
 * GPS Navigation https://github.com/costales/unav
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
import Lomiri.Components 1.3

Item {
	id: gpx
	
	Column {
		id: importGPX
		anchors.centerIn: parent
		spacing: units.gu(1)
		Button {
			id: btnImport
			text: i18n.tr("Import track")
			width: units.gu(30)
			anchors.horizontalCenter: parent.horizontalCenter
			color: theme.palette.normal.positive
			onClicked: {
				mainPageStack.addPageToCurrentColumn(searchPage, Qt.resolvedUrl("GPXImport.qml"));
			}
		}
	}
}
