import '../models/weather.dart';
import '../repositories/weather_repository.dart';
import 'api_client.dart';

class RemoteWeatherRepository implements WeatherRepository {
  RemoteWeatherRepository(this._client);

  final ApiClient _client;

  @override
  Future<WeatherReport> report({String? district}) async {
    final response = await _client.get(
      '/weather',
      query: district == null || district.isEmpty ? null : {'district': district},
    );
    final data = response['weather'] as Map<String, dynamic>? ?? const {};
    return WeatherReport.fromJson(data);
  }

  @override
  Future<List<WeatherAlert>> activeAlerts({String? district}) async {
    final response = await _client.get(
      '/weather/alerts',
      query: district == null || district.isEmpty ? null : {'district': district},
    );
    final list = (response['alerts'] as List<dynamic>?) ?? const [];
    return list
        .map((e) => WeatherAlert.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
