import QtQuick 1.1
import "Utils.js" as Utils

Rectangle
{
	id: rootRect

	property int sideMargin: 5
	property url icon: weatherIcon
	property bool scaleImage: weatherScaleImage

	property variant weatherData: weatherInfo
	property string temperatureUnit: tempUnit

	height: 300
	width: headerRect.width

	smooth: true
	radius: 5

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

	signal closeRequested()

	Rectangle
	{
		id: headerRect

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.margins: sideMargin

		property int sideMargins: 3

		height: 70
		width: flipableRect.width

		smooth: true
		radius: 5

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

		FlipableRectangle
		{
			id: flipableRect

			anchors.fill: parent

			icon: rootRect.icon
			scaleImage: rootRect.scaleImage
			location: rootRect.weatherData ["name"] + ", " +
					rootRect.weatherData ["sys"]["country"]
			weatherTemperature: Utils.getTemperatureString (rootRect.weatherData, temperatureUnit)
		}
	}
}
