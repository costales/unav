import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Content 1.3
import Lomiri.Components.Popups 1.3
import "../components"

Item {

	id: shareController
	property url uri: ""
	property alias clipboardText: mimeData.text

	signal done ()
	signal shareRequested ( var transfer )

	function toClipboard ( text ) {
		mimeData.text = text
		Clipboard.push( mimeData )
	}

	function share(url, text, contentType) {
		uri = url
		var sharePopup = PopupUtils.open(shareDialog, shareController, {"contentType" : contentType})
		sharePopup.items.push(contentItemComponent.createObject(shareController, {"url" : uri, "text": text}))
	}

	function shareLink( url ) {
		share( url, url, ContentType.Links)
	}

	function shareText( text ) {
		share( "", text, ContentType.Text)
	}

	function sharePicture( url, title ) {
		share( url, title, ContentType.Pictures)
	}

	function shareAudio( url, title ) {
		share( url, title, ContentType.Music)
	}

	function shareVideo( url, title ) {
		share( url, title, ContentType.Videos)
	}

	function shareFile( url, title ) {
		share( url, title, ContentType.Documents)
	}

	function shareAll( url, title ) {
		share( url, title, ContentType.All)
	}

	Connections {
		target: ContentHub
		onShareRequested: shareRequested(transfer)
	}

	Component {
		id: shareDialog
		PopupBase {
			id: sharePopUp
			anchors.fill: parent
			property var activeTransfer
			property var items: []
			property alias contentType: peerPicker.contentType

			Rectangle {
				anchors.fill: parent
				ContentPeerPicker {
					id: peerPicker
					handler: ContentHandler.Share
					visible: parent.visible

					onPeerSelected: {
						activeTransfer = peer.request()
						activeTransfer.items = sharePopUp.items
						activeTransfer.state = ContentTransfer.Charged
						PopupUtils.close(sharePopUp)
					}

					onCancelPressed: {
						PopupUtils.close(sharePopUp)
					}
				}
			}
		}
	}

	Component {
		id: contentItemComponent
		ContentItem { }
	}

	MimeData {
		id: mimeData
		text: ""
	}

}
