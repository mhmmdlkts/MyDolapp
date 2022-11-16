import 'package:my_doll_app/secrets/secret_api_service.dart';
import 'package:weather/weather.dart';
import 'package:my_doll_app/models/weather.dart' as custom;

class WeatherService {
  // TODO hide API KEY
  static final WeatherFactory wf = WeatherFactory(SecretApiService.weatherApiKey, language: Language.ENGLISH);
  static custom.Weather5Day? _weather5day;
  static bool _isIniting = false;
  static DateTime? _lastDateTime;
  static custom.Weather? lastReturnedWeather;



  static custom.Weather? getWeather (DateTime dateTime) {
    if (_lastDateTime == dateTime) {
      return lastReturnedWeather;
    }
    _lastDateTime = dateTime;
    if (_weather5day == null) {
      return null;
    }
    lastReturnedWeather = _weather5day!.getWeather(dateTime);
    return lastReturnedWeather;
  }

  static Future initWeather () async {
    if (_weather5day != null || _isIniting) {
      return;
    }
    _isIniting = true;
    // TODO use maybe this
    // api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API key}
    double lat = 47.809490;
    double lon = 13.055010;
    String cityName = 'Salzburg';
    List<Weather> w = await wf.fiveDayForecastByLocation(lat, lon);
    custom.Weather5Day cw5 = custom.Weather5Day(w, cityName);
    _weather5day = cw5;
    // custom.Weather cw = custom.Weather.fromWeather(w.first, cityName);
    // Weather w2 = await wf.currentWeatherByCityName(cityName);
    _isIniting = false;
    return cw5;
  }


}