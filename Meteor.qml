import QtQuick 1.1
import org.LC.common 1.0

Item
{
	id: rootRect

	implicitWidth: parent.quarkBaseSize
	implicitHeight: parent.quarkBaseSize

	property string timePrefix;
	property string themePrefix: "colorful";

	property bool showToolTip: false;

	property string toolTipWeather;
	property string toolTipCity;

	Component.onCompleted:
	{
		var hours = new Date().getHours();
		timePrefix = (hours < 7 || hours >= 19) ? "night" : "day";
	}

	function updateWeatherQuark (info)
	{
		var temp = parseFloat (info ["main"] ["temp"]);
		if (TemperatureUnit == "Celsius")
		{
			temp = Math.round (temp - 273.15);
			temp = String (temp) + "\u00B0"+ "C";
		}
		else if (TemperatureUnit == "Fahrenheit")
		{
			temp -= 458.87;
			temp = String (temp) + "\u00B0"+ "F";
		}
		else if (TemperatureUnit == "Kelvin")
			temp = String (temp) + "K";

		toolTipCity = info ["name"] + ", " + info ["sys"]["country"];
		toolTipWeather = info ["weather"][0]["description"] + ", " + temp;
		var humidity = info ["main"] ["humidity"];
		var pressure = info ["main"] ["pressure"];

		weatherButton.actionIconURL = "http://openweathermap.org/img/w/" + info ["weather"][0]["icon"];
	}

	function requestNewWeather ()
	{
		var request = new XMLHttpRequest ();
		request.onreadystatechange = function ()
		{
			if (request.readyState == XMLHttpRequest.DONE)
				if (request.status == 200)
					updateWeatherQuark (JSON.parse (request.responseText));
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
			weatherLocation: toolTipCity,
			weatherInfo: toolTipWeather
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
		var params = { existing: "toggle" };
		quarkProxy.openWindow(sourceURL, "MeteorToolTip.qml", params);
		showToolTip = false;
	}

	ActionButton
	{
		id: weatherButton

		anchors.fill: parent

		sourceSize.width: Math.min(parent.implicitWidth, parent.implicitHeight)
		sourceSize.height: Math.min(parent.implicitWidth, parent.implicitHeight)
		actionIconScales: false
		actionIconURL: Qt.resolvedUrl ("images/weather-none-available.svg")

		onHovered:
		{
			if (toolTipShowTimer.running)
				return;
			toolTipShowTimer.start ();
		}
		onHoverLeft:
		{
			toolTipShowTimer.stop ();
			toolTipHideTimer.interval = 500;
			toolTipHideTimer.restart ();
		}
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
