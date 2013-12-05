function getTemperatureString (info, temperatureUnit)
{
	var temp = parseFloat (info ["main"] ["temp"]);
	if (temperatureUnit === "Celsius")
	{
		temp = Math.round (temp - 273.15);
		temp = String (temp) + "\u00B0"+ "C";
	}
	else if (temperatureUnit === "Fahrenheit")
	{
		temp -= 458.87;
		temp = String (temp) + "\u00B0"+ "F";
	}
	else if (temperatureUnit === "Kelvin")
		temp = String (temp) + "K";

	return temp;
}

function getImage (iconId, useSystemIconSet)
{
	var image;
	switch (iconId)
	{
	case "01d":
		image = "weather-clear";
		break;
	case "01n":
		image = "weather-clear-night";
		break;
	case "02d":
		image = "weather-few-clouds";
		break;
	case "02n":
		image = "weather-few-clouds-night";
		break;
	case "03d":
		image = "weather-clouds";
		break;
	case "03n":
		image = "weather-clouds-night";
		break;
	case "04d":
		image = "weather-many-clouds";
		break;
	case "04n":
		image = useSystemIconSet ? "weather-many-clouds" : "weather-many-clouds-night";
		break;
	case "09d":
	case "09n":
		image = "weather-showers";
		break;
	case "10d":
		image = "weather-showers-scattered-day";
		break;
	case "10n":
		image = "weather-showers-scattered-night";
		break;
	case "11d":
	case "11n":
		image = "weather-storm";
		break;
	case "13d":
		image = "weather-snow-scattered-day";
		break;
	case "13n":
		image = "weather-snow-scattered-night";
		break;
	case "50d":
	case "50n":
		image = "weather-mist";
		break;
	default:
		image = "weather-none-available";
	}

	if (useSystemIconSet)
		image = "image://ThemeIcons/" + image;
	else
		image = Qt.resolvedUrl ("images/" + image + ".png");

	return image;
}
