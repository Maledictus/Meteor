import QtQuick 1.1
import org.LC.common 1.0
import "Utils.js" as Utils

Rectangle
{
	id: rootRect

	property bool useSystemIconSet: UseSystemIconSet
	property int forecastDaysCount: ForecastDaysCount
	property variant forecastInfo;

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

	ListModel
	{
		id: forecastModel
	}

	Component
	{
		id: forecastDelegate

		Rectangle
		{
			id: wrapper;

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

			height: forecastView.height
			width: Math.round (rootRect.width / forecastDaysCount) < 70 ?
					Math.round (rootRect.width / 4) :
					Math.round (rootRect.width / forecastDaysCount)

			Image
			{
				id: weatherImage

				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.margins: 5


				fillMode: Image.PreserveAspectFit
				smooth: true
				source: scaleImage ?
					(Utils.getImage (iconId, useSystemIconSet) + '/' + width) :
					Utils.getImage (iconId, useSystemIconSet)
				MouseArea
				{
					anchors.fill: parent
					hoverEnabled: true
					ToolTip
					{
						anchors.fill: parent
						text: description
					}
				}

			}
		}
	}

	ListView
	{
		id: forecastView
		anchors.fill: parent
		orientation: ListView.Horizontal
		clip: true

		model: forecastModel
		delegate: forecastDelegate
	}

	onForecastInfoChanged:
	{
		if (typeof (forecastInfo) == "undefined")
			return;

		forecastModel.clear ();

		var count = forecastInfo ["cnt"];
		for (var i = 0; i < count; ++i)
		{
			var variant = forecastInfo ["list"][i];
			var date = new Date (variant ["dt"] * 1000);
			forecastModel.append ({
					"date" : date.getDate (),
					"iconId" : variant ["weather"][0]["icon"],
					"tempDay": variant ["temp"]["day"],
					"tempNight": variant ["temp"]["night"],
					"description": variant ["weather"][0]["description"]
					});
		}
//		forecastView.forceActiveFocus ()
	}
}
