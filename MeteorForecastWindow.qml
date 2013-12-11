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
	property string pressureUnit: pressUnit
	property string windSpeedUnit: windUnit

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
				(typeof (weatherData) != "undefined") ?
					weatherData ["name"] + ", " + weatherData ["sys"]["country"] :
					qsTr ("N/A");
			weatherTemperature:
				(typeof (weatherData) != "undefined") ?
					Utils.getTemperatureString (weatherData ["main"]["temp"], temperatureUnit) :
					qsTr ("N/A");
			description:
				(typeof (weatherData) != "undefined") ?
					weatherData ["weather"][0]["description"]:
					qsTr ("N/A");
			temeperatureLimits:
				(typeof (weatherData) != "undefined") ?
					"H: " + Utils.getTemperatureString (weatherData ["main"]["temp_min"], temperatureUnit) +
							" L: " + Utils.getTemperatureString (weatherData ["main"]["temp_max"], temperatureUnit):
					qsTr ("N/A");
		}
	}

	DetailedInfoRectangle
	{
		id: detailedInfoRect
		width: parent.width
		height: rootRect.height - headerRect.height - rootRect.sideMargin * 3

		y: rootRect.y

		anchors.left: parent.left
		anchors.right: parent.right

		movementToValue: headerRect.y + headerRect.height
		movementDuration: 500

		opacityToValue: 1.0
		opacityFromValue: 0.0
		opacityDuration: 500

		weatherInfo: rootRect.weatherData
	}

	Connections
	{
		target: flipableRect
		onShowDetailedInfo:
		{
			if (show)
			{
				detailedInfoRect.movementToValue = headerRect.y + headerRect.height;
				detailedInfoRect.opacityFromValue = 0.0;
				detailedInfoRect.opacityToValue = 1.0;
				detailedInfoRect.show ()
			}
			else
			{
				detailedInfoRect.opacityFromValue = 1.0;
				detailedInfoRect.opacityToValue = 0.0;
				detailedInfoRect.movementToValue = rootRect.y;
				detailedInfoRect.hide ()
			}

		}
	}
}
