import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../services/gps_services.dart';

class SetupController {
  bool isGpsEnabled = false;
  late Timer gpsService;

  String getSelectedBus() {
    var config = Hive.box('config');
    if (config.containsKey('bus')) {
      return config.get('bus');
    }
    return '';
  }

  void startGpsTransmission() {
    gpsService = GpsServices.startPositionBroadcast(getSelectedBus);
    isGpsEnabled = true;
  }

  void stopGpsTransmission() {
    isGpsEnabled = false;
    gpsService.cancel();
  }
}
