import QtQuick 1.1
import "Utils.js" as Utils

Rectangle
{
	id: rootRect

	property variant weatherInfo;

	property alias movementToValue: animateMovement.to
	property alias movementDuration: animateMovement.duration

	property alias opacityFromValue: animateOpacity.from
	property alias opacityToValue: animateOpacity.to
	property alias opacityDuration: animateOpacity.duration

	opacity: 0.0

	function show ()
	{
		animateMovement.start ()
		animateOpacity.start ()
	}

	function hide ()
	{
		animateMovement.start ()
		animateOpacity.start ()
	}

	gradient: Gradient
	{
		GradientStop
		{
			position: 0
			color: colorProxy.color_TextView_TopColor
		}
		GradientStop
		{
			position: 1
			color: colorProxy.color_TextView_BottomColor
		}
	}

	Text
	{
		id: pressureText
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.margins: 5
		horizontalAlignment: Text.AlignHCenter | Text.AlignVCenter

		text:
			typeof (weatherInfo) == "undefined" ?
				qsTr ("N/A") :
				Utils.getPressureString (weatherInfo ["main"]["pressure"], rootRect.parent.pressureUnit)
	}

	Text
	{
		id: humidityText
	}

	Text
	{
		id: windText
	}

	PropertyAnimation
	{
		id: animateMovement;
		target: detailedInfoRect;
		properties: "y";
	}

	NumberAnimation
	{
		id: animateOpacity
		target: detailedInfoRect
		properties: "opacity"
	}
}

