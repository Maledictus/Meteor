import QtQuick 1.1
import org.LC.common 1.0
import "Utils.js" as Utils


Flipable
{
	id: flipable

	property int sideMargin: 5

	property bool flipped: false
	property url icon
	property bool scaleImage: true
	property bool locationSelected: false
	property variant settingsObject
	property bool moreInfoShown: false

	property alias location: locationText.text
	property alias weatherTemperature: weatherTempText.text
	property alias description: descriptionText.text
	property alias temeperatureLimits: temperatureLimitsText.text

	width: Utils.getWidth()

	signal showDetailedInfo (bool show)

	front:Rectangle
	{
		id: frontRect
		width:  Utils.getWidth()
		height: parent.height

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

			font.pixelSize: 22
			font.bold: true
			horizontalAlignment: Text.AlignLeft | Text.AlignVCenter

			color: colorProxy.color_TextBox_TitleTextColor


			MouseArea
			{
				anchors.fill: parent
				hoverEnabled: true

				ToolTip
				{
					anchors.fill: parent
					text: qsTr ("Location")
				}
			}
		}

		Text
		{
			id: weatherTempText

			anchors.top: parent.top
			anchors.topMargin: flipable.sideMargin
			anchors.right: configureImage.left
			anchors.rightMargin: flipable.sideMargin

			font.pixelSize: 22
			font.bold: true
			horizontalAlignment: Text.AlignRight | Text.AlignVCenter

			color: colorProxy.color_TextBox_TextColor

			MouseArea
			{
				anchors.fill: parent
				hoverEnabled: true

				ToolTip
				{
					anchors.fill: parent
					text: qsTr ("Temperature")
				}
			}
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

		ActionButton
		{
			id: moreInfo

			anchors.top: configureImage.bottom
			anchors.topMargin: 3
			anchors.right: parent.right
			anchors.rightMargin: flipable.sideMargin

			width: 24
			height: width

			actionIconURL: moreInfoShown ?
					"image://ThemeIcons/arrow-up-double" :
					"image://ThemeIcons/arrow-down-double"
			textTooltip: moreInfoShown ?
					qsTr ("Show weather forecast") :
					qsTr ("Show more info...")

			onTriggered:
			{
				moreInfoShown = !moreInfoShown
				flipable.showDetailedInfo (moreInfoShown)
			}
		}

		Text
		{
			id: descriptionText

			anchors.left: weatherImage.right
			anchors.leftMargin: flipable.sideMargin
			anchors.bottom: parent.bottom
			anchors.bottomMargin: flipable.sideMargin
			horizontalAlignment: Text.AlignLeft | Text.AlignVCenter
			elide: Text.ElideRight

			color: colorProxy.color_TextBox_TextColor
		}

		Text
		{
			id: temperatureLimitsText

			anchors.right: moreInfo.right
			anchors.rightMargin: flipable.sideMargin
			anchors.bottom: parent.bottom
			anchors.bottomMargin: flipable.sideMargin
			horizontalAlignment: Text.AlignRight | Text.AlignVCenter

			color: colorProxy.color_TextBox_TextColor
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
			variantsModel.clear ();
			var count = output ["count"];
			for (var i = 0; i < count; ++i)
			{
				var variant = output ["list"][i];
				variantsModel.append ({ "location": variant ["name"] +
						"," + variant ["sys"]["country"] });
			}
			locationInput.text = variantsModel.get (0).location;
			variantsView.visible = true;
			variantsView.forceActiveFocus ()
		}

		function searchLocation (location)
		{
			if (locationInput.text == "")
				return;

			variantsView.visible = false;
			var request = new XMLHttpRequest ();
			request.onreadystatechange = function ()
			{
				if (request.readyState == XMLHttpRequest.DONE)
					if (request.status == 200)
						parseLocationOutput (JSON.parse (request.responseText));
					else
						console.log ("HTTP request failed", request.status);
			}
			request.open ("GET", "http://api.openweathermap.org/data/2.5/find?type=like&q=" + location);
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
				anchors.left: locationInputContainer.left
				anchors.right: locationInputContainer.right
				anchors.verticalCenter: locationInputContainer.verticalCenter
				anchors.margins: 3
				font.pointSize: 10
				color: colorProxy.color_Panel_TextColor
				focus: true

				selectByMouse: true

				Keys.onReturnPressed: backRect.searchLocation(text);

				onTextChanged:
				if (text == "")
					locationSelected = false;
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

			onTriggered:
			{
				locationSelected = false;
				backRect.searchLocation(locationInput.text)
			}
		}

		ListModel
		{
			id: variantsModel
		}

		Component
		{
			id: variantDelegate

			Rectangle
			{
				id: wrapper;
				width: locationInputContainer.width;
				height: 20
				radius: 2
				border.width: 1
				border.color: colorProxy.color_ToolButton_BorderColor

				gradient: Gradient
				{
					GradientStop
					{
						position: 0
						color: colorProxy.color_ToolButton_TopColor
					}
					GradientStop
					{
						position: 1
						color: colorProxy.color_ToolButton_BottomColor
					}
				}

				function selectItem (index)
				{
					variantsView.currentIndex = index;
					locationInput.text = variantsModel.get (index).location
					variantsView.visible = false
					locationSelected = true;
				}

				Text
				{
					anchors.left: parent.left
					anchors.leftMargin: 3
					anchors.right: parent.right
					anchors.rightMargin: 3
					anchors.verticalCenter: parent.verticalCenter

					text: location;
					color: colorProxy.color_ToolButton_TextColor
				}

				MouseArea
				{
					id: itemMouseArea
					anchors.fill: parent;
					hoverEnabled: true;

					onEntered: variantsView.currentIndex = index;
					onClicked: selectItem (index)
				}

				Keys.onReturnPressed: selectItem (index)
			}
		}

		Component
		{
			id: highlight

			Rectangle
			{
				gradient: Gradient
				{
					GradientStop
					{
						position: 0
						color: colorProxy.color_ToolButton_HoveredTopColor
					}
					GradientStop
					{
						position: 1
						color: colorProxy.color_ToolButton_HoveredBottomColor
					}
				}

				width: variantsView.width - 1
				height: 20
				border.color: colorProxy.color_ToolButton_HoveredBorderColor
				radius: 2
				opacity: 0.5
				z: 10
			}
		}

		ListView
		{
			id: variantsView

			anchors.left: locationInputContainer.left
			anchors.right: locationInputContainer.right
			anchors.top: locationInputContainer.bottom
			height: (variantsModel.count > 5) ? 100 : (variantsModel.count + 1) * 20
			clip: true
			focus: true
			visible: false

			z: 5

			model: variantsModel
			delegate: variantDelegate
			highlight: highlight

			Keys.onEscapePressed: visible = false

			onVisibleChanged:
				if (!visible)
					locationInput.forceActiveFocus ()
		}


		ActionButton
		{
			id: saveButton
			anchors.bottom: parent.bottom
			anchors.bottomMargin: flipable.sideMargin
			anchors.right: cancelButton.left
			anchors.rightMargin: flipable.sideMargin

			width: 24
			height: width
			actionIconURL: "image://ThemeIcons/dialog-ok-apply"
			textTooltip: qsTr ("Save")

			visible: locationSelected
			onTriggered:
			{
				settingsObject.setSettingsValue ("Location", locationInput.text)

				flipped = !flipped
				variantsModel.clear ()
				variantsView.visible = false
				locationInput.text = ""
			}

		}

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

			onTriggered:
			{
				flipped = !flipped
				variantsModel.clear ()
				variantsView.visible = false
				locationInput.text = ""
			}
		}

		MouseArea
		{
			anchors.fill: parent;
			z: -1
			onClicked:
				if (variantsView.visible)
					variantsView.visible = false;
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

//{
//"message":"like",
//"cod":"200",
//"count":8,
//"list":
//[
//	{
//		"id":2643743,
//		"name":"London",
//		"coord":{"lon":-0.12574,"lat":51.50853},
//		"main":{"temp":281.94,"pressure":1018,"humidity":76,"temp_min":281.15,"temp_max":282.59},
//		"dt":1386246959,
//		"wind":{"speed":10.8,"deg":250,"gust":15.9},
//		"sys":{"country":"GB"},
//		"rain":{"1h":13.84},
//		"clouds":{"all":40},
//		"weather":[{"id":502,"main":"Rain","description":"heavy intensity rain","icon":"10d"}]
//	},
//]	...
//}
