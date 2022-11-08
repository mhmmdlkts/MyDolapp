import 'package:my_doll_app/services/secret_api_service.dart';
import 'package:weather/weather.dart';
import 'package:my_doll_app/models/weather.dart' as custom;

class WeatherService {
  // TODO hide API KEY
  static final WeatherFactory wf = WeatherFactory(SecretApiService.weatherApiKey, language: Language.ENGLISH);

  static Future<custom.Weather> getWeather () async {
    double lat = 47.809490;
    double lon = 13.055010;
    String cityName = 'Salzburg';
    Weather w = await wf.currentWeatherByLocation(lat, lon);
    custom.Weather cw = custom.Weather.fromWeather(w, cityName);
    // Weather w2 = await wf.currentWeatherByCityName(cityName);
    return cw;
  }


}