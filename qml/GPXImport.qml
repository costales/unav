/*
 * uNav https://github.com/costales/unav
 * Copyright (C) 2015-2020 Marcos Alvarez Costales https://costales.github.io
 *
 * uNav is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 * 
 * uNav is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
 * GNU General Public License for more details.
 */

import QtQuick 2.4
import Ubuntu.Content 1.3
import Ubuntu.Components 1.3
import "components"

Page {
	id: picker

	// Property to indicate if the share page was opened directly (from a popup) or as a child (from the search page)
	property bool isParentPage: false

	header: UNavHeader {
		title: i18n.tr("Import GPX from")
	}

	ContentPeerPicker {
		id: peerPicker

		showTitle: false
		contentType: ContentType.Documents
		handler: ContentHandler.Source

		anchors.topMargin: picker.header.height

		onPeerSelected: {
			peer.selectionType = ContentTransfer.Single;
			picker.activeTransfer = peer.request();
			stateChangeConnection.target = picker.activeTransfer;
		}

		onCancelPressed: {
			mainPageStack.removePages(picker);
		}

	}

	Connections {
		target: ContentHub

		onImportRequested: {
			var filePath = String(transfer.items[0].url).replace('file://', '')
			if (filePath.toLowerCase().endsWith(".gpx"))
				mainPageStack.executeJavaScript("import_gpx('" + filePath + "')");

			if (mainPageStack.columns === 1) {
				mainPageStack.removePages(searchPage);
			}
		 }
	}
}
