import 'package:weather/weather.dart';

class WeatherService {
  // TODO hide API KEY
  static final WeatherFactory wf = WeatherFactory("6c3279f900170aaff1336a8e98cca40b", language: Language.ENGLISH);

  static Future<Weather> getWeather () async {
    double lat = 47.809490;
    double lon = 13.055010;
    String cityName = 'Salzburg';
    Weather w = await wf.currentWeatherByLocation(lat, lon);
    // Weather w2 = await wf.currentWeatherByCityName(cityName);
    print(w.toJson());
    return w;
  }


}