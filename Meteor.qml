import QtQuick 1.1
import org.LC.common 1.0
import "Utils.js" as Utils

Item
{
	id: rootRect

	implicitWidth: parent.quarkBaseSize
	implicitHeight: parent.quarkBaseSize

	property string timePrefix;
	property string themePrefix: "colorful";

	property bool showToolTip: false;
	property bool showForecastWindow: false;

	property bool useSystemIconSet: UseSystemIconSet

	property string iconID;

	property variant weatherData;

	function updateWeatherQuark (info)
	{
		iconID = info ["weather"][0]["icon"];
	}

	function requestNewWeather ()
	{
		var request = new XMLHttpRequest ();
		request.onreadystatechange = function ()
		{
			if (request.readyState == XMLHttpRequest.DONE)
				if (request.status == 200)
				{
					rootRect.weatherData = JSON.parse (request.responseText);
					updateWeatherQuark (rootRect.weatherData);
				}
				else
					console.log ("HTTP request failed", request.status);
		}
		//TODO change city
		request.open ("GET", "http://api.openweathermap.org/data/2.5/weather?q=Minsk");
		request.send ();
	}

	Timer
	{
		interval: UpdateTemperatureInterval * 60 * 1000
		repeat: true
		running: true
		triggeredOnStart: true
		onTriggered: requestNewWeather ()
	}

	Timer
	{
		id: toolTipShowTimer
		interval: 1000
		repeat: false
		running: false
		onTriggered: showWeatherToolTip ()
	}

	Timer
	{
		id: toolTipHideTimer
		interval: 1000
		repeat: false
		running: false
		onTriggered: hideWeatherToolTip ()
	}

	Common { id: commonJS }

	function showWeatherToolTip ()
	{
		var global = commonJS.getTooltipPos (rootRect);
		var params = {
			x: global.x,
			y: global.y,
			existing: "toggle",
			weatherIcon: weatherButton.actionIconURL,
			weatherLocation: rootRect.weatherData ["name"] + ", " +
					rootRect.weatherData ["sys"]["country"],
			weatherInfo: rootRect.weatherData ["weather"][0]["description"] +
					", " + Utils.getTemperatureString (weatherData, TemperatureUnit),
			weatherScaleImage: useSystemIconSet
		};

		quarkProxy.openWindow(sourceURL, "MeteorToolTip.qml", params);

		toolTipHideTimer.interval = 3000
		toolTipHideTimer.running = true
		showToolTip = true;
	}

	function hideWeatherToolTip ()
	{
		if (!showToolTip)
			return;
		if (showForecastWindow)
			return;
		var params = { existing: "toggle" };
		quarkProxy.openWindow(sourceURL, "MeteorToolTip.qml", params);
		showToolTip = false;
	}

	ActionButton
	{
		id: weatherButton

		anchors.fill: parent
		actionIconURL: Utils.getImage (iconID, useSystemIconSet)
		actionIconScales: false

		onHovered:
		{
			if (toolTipShowTimer.running)
				return;
			if (showForecastWindow)
				return;
			toolTipShowTimer.start ();

		}
		onHoverLeft:
		{
			toolTipShowTimer.stop ();
			if (showForecastWindow)
				return;
			toolTipHideTimer.interval = 500;
			toolTipHideTimer.restart ();
		}

		onTriggered:
		{
			var global = commonJS.getTooltipPos (rootRect);
			var params = {
				x: global.x,
				y: global.y,
				existing: "toggle",
				weatherIcon: weatherButton.actionIconURL,
				weatherScaleImage: useSystemIconSet,
				weatherInfo: rootRect.weatherData,
				tempUnit: TemperatureUnit
			};
			showForecastWindow = !showForecastWindow;
			quarkProxy.openWindow(sourceURL, "MeteorForecastWindow.qml", params);
		}

		onActionIconURLChanged: actionIconScales = useSystemIconSet;
	}

	onUseSystemIconSetChanged: requestNewWeather ();

	onShowForecastWindowChanged:
	{
		if (showToolTip)
			hideWeatherToolTip ();
		toolTipShowTimer.stop ()
	}

}

//{
//"coord":{"lon":27.57,"lat":53.9},
//"sys":{"message":0.0102,"country":"BY","sunrise":1385877938,"sunset":1385905940},
//"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04d"}],
//"base":"gdps stations",
//"main":{"temp":273.15,"humidity":86,"pressure":1009,"temp_min":274.82,"temp_max":275.15},
//"wind":{"speed":6.68,"gust":10.28,"deg":230},
//"snow":{"3h":0.125},
//"clouds":{"all":68},
//"dt":1385890221,
//"id":625144,
//"name":"Minsk",
//"cod":200
//}
