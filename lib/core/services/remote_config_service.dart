import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';


class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  RemoteConfigService(){
    init();
  }

  Future<void> init() async {
    await FirebaseRemoteConfig.instance.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );
    await _remoteConfig.fetchAndActivate();
  }

  Map<String, dynamic> getJson(String key) {
    final json = _remoteConfig.getString(key);
    return jsonDecode(json) as Map<String, dynamic>;
  }

  List<dynamic> getJsonList(String key) {
    final json = _remoteConfig.getString(key);
    return jsonDecode(json) as List<dynamic>;
  }

  T fromJson<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    return fromJson(getJson(key));
  }
}