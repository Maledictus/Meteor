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

	property variant settingsObject: settings

	height: 300
	width: flipableRect.width + sideMargin * 2

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

		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
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
			height: parent.height

			settingsObject: rootRect.settingsObject

			icon: rootRect.icon
			scaleImage: rootRect.scaleImage

			location:
				(typeof (rootRect.weatherData) != "undefined") ?
					rootRect.weatherData ["name"] + ", " + rootRect.weatherData ["sys"]["country"] :
					qsTr ("N/A");
			weatherTemperature:
				(typeof (rootRect.weatherData) != "undefined") ?
					Utils.getTemperatureString (rootRect.weatherData ["main"]["temp"],
						temperatureUnit) :
					qsTr ("N/A");
			description:
				(typeof (rootRect.weatherData) != "undefined") ?
					rootRect.weatherData ["weather"][0]["description"]:
					qsTr ("N/A");
			temeperatureLimits:
				(typeof (rootRect.weatherData) != "undefined") ?
					"H: " + Utils.getTemperatureString (rootRect.weatherData ["main"]["temp_min"], temperatureUnit) +
							" L: " + Utils.getTemperatureString (rootRect.weatherData ["main"]["temp_max"], temperatureUnit):
					qsTr ("N/A");
		}

		Connections
		{
			target: flipableRect
			onShowDetailedInfo:
			{
				console.log ("show:", show)
			}
		}
	}


}
