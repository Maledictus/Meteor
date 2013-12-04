import QtQuick 1.1
import org.LC.common 1.0

Flipable
{
	id: flipable

	property string frontImage;
	property string backImage;

	property int sideMargin: 5

	property bool flipped: false;
	property url icon;
	property bool scaleImage: true

	property alias location: locationText.text
	property alias weatherTemperature: weatherTempText.text

	width: frontRect.width

	front:Rectangle
	{
		id: frontRect
		anchors.fill: parent

		width: flipable.sideMargin + weatherImage.width + flipable.sideMargin +
			   flipable.sideMargin + locationText.paintedWidth +
			   flipable.sideMargin * 6 + weatherTempText.paintedWidth +
			   flipable.sideMargin + configureImage.width +
			   flipable.sideMargin + flipable.sideMargin

		gradient: Gradient
		{
			GradientStop
			{
				position: 0
				color: colorProxy.color_TextBox_TopColor
			}
			GradientStop
			{
				position: 1
				color: colorProxy.color_TextBox_BottomColor
			}
		}


		Image
		{
			id: weatherImage

			width: 64
			anchors.left: parent.left
			anchors.leftMargin: flipable.sideMargin
			anchors.bottom: parent.bottom
			anchors.bottomMargin: flipable.sideMargin
			anchors.top: parent.top
			anchors.topMargin: flipable.sideMargin

			fillMode: Image.PreserveAspectFit

			smooth: true
			source: scaleImage ? (icon + '/' + width) : icon
		}

		Text
		{
			id: locationText

			anchors.left: weatherImage.right
			anchors.leftMargin: flipable.sideMargin
			anchors.top: parent.top
			anchors.topMargin: flipable.sideMargin
			anchors.right: weatherTempText.left
			anchors.rightMargin: flipable.sideMargin * 3

			font.pixelSize: 22
			font.bold: true
			horizontalAlignment: Text.AlignLeft | Text.AlignVCenter

			color: colorProxy.color_TextBox_TitleTextColor
		}

		Text
		{
			id: weatherTempText

			anchors.top: parent.top
			anchors.topMargin: flipable.sideMargin
			anchors.right: configureImage.left
			anchors.rightMargin: flipable.sideMargin
			anchors.left: locationText.right
			anchors.leftMargin: flipable.sideMargin * 3

			font.pixelSize: 22
			font.bold: true
			horizontalAlignment: Text.AlignRight | Text.AlignVCenter

			color: colorProxy.color_TextBox_TextColor
		}

		ActionButton
		{
			id: configureImage

			anchors.top: parent.top
			anchors.topMargin: flipable.sideMargin
			anchors.right: parent.right
			anchors.rightMargin: flipable.sideMargin

			width: 24
			height: width

			actionIconURL: "image://ThemeIcons/configure"
			textTooltip: qsTr ("Configure location")

			onTriggered: flipped = !flipped
		}
	}


	back: Rectangle
	{
		id: backRect
		anchors.fill: parent
		gradient: Gradient
		{
			GradientStop
			{
				position: 0
				color: colorProxy.color_TextBox_TopColor
			}
			GradientStop
			{
				position: 1
				color: colorProxy.color_TextBox_BottomColor
			}
		}

		function parseLocationOutput (output)
		{

		}

		function searchLocation (location)
		{
			var request = new XMLHttpRequest ();
			request.onreadystatechange = function ()
			{
				if (request.readyState == XMLHttpRequest.DONE)
					if (request.status == 200)
						parseLocationOutput (JSON.parse (request.responseText));
					else
						console.log ("HTTP request failed", request.status);
			}
			request.open ("GET", "http://api.openweathermap.org/data/2.5/find?q=" + location);
			request.send ();
		}

		Rectangle
		{
			id: locationInputContainer

			anchors.left: parent.left
			anchors.leftMargin: flipable.sideMargin
			anchors.top: parent.top
			anchors.topMargin: flipable.sideMargin
			anchors.right: searchButton.left
			anchors.rightMargin: flipable.sideMargin

			border.width: 1
			height: 22
			radius: 3

			color: colorProxy.color_Panel_TopColor

			TextInput
			{
				id: locationInput
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.margins: 2
				font.pointSize: 10
				color: colorProxy.color_Panel_TextColor
				focus: true

				selectByMouse: true

				Keys.onReturnPressed: backRect.searchLocation(text);
			}
		}

		ActionButton
		{
			id: searchButton
			anchors.top: parent.top
			anchors.topMargin: flipable.sideMargin
			anchors.right: parent.right
			anchors.rightMargin: flipable.sideMargin

			width: 24
			height: width
			actionIconURL: "image://ThemeIcons/edit-find"
			textTooltip: qsTr ("Search location")

			onTriggered: backRect.searchLocation(locationInput.text)
		}

//		ActionButton
//		{
//			id: saveButton
//			anchors.bottom: parent.bottom
//			anchors.bottomMargin: flipable.sideMargin
//			anchors.right: cancelButton.left
//			anchors.rightMargin: flipable.sideMargin

//			width: 24
//			height: width
//			actionIconURL: "image://ThemeIcons/dialog-ok-apply"
//			textTooltip: qsTr ("Save")

////			visible: false
//		}

		ActionButton
		{
			id: cancelButton
			anchors.bottom: parent.bottom
			anchors.bottomMargin: flipable.sideMargin
			anchors.right: parent.right
			anchors.rightMargin: flipable.sideMargin

			width: 24
			height: width
			actionIconURL: "image://ThemeIcons/dialog-cancel"
			textTooltip: qsTr ("Cancel")
//			visible: false

			onTriggered: flipped = !flipped
		}
	}

	transform: Rotation
	{
		id: rotation
		origin.x: flipable.width / 2
		origin.y: flipable.height / 2
		axis.x: 1;
		axis.y: 0;
		axis.z: 0
		angle: 0
	 }

	states: State
	{
		name: "back"
		PropertyChanges { target: rotation; angle: 180 }
		when: flipable.flipped
	}

	transitions: Transition
	{
		NumberAnimation { target: rotation; property: "angle"; duration: 500 }
	}
}
