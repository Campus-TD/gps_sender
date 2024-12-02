//import geolocator
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class GpsServices {
  static late StreamController<Position> controller;

  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    var position = await Geolocator.getCurrentPosition();
    //saca la orientacion del dispositivo
    var bearing = Geolocator.bearingBetween(
      position.latitude,
      position.longitude,
      position.latitude + 0.1,
      position.longitude + 0.1,
    );

    return position;
  }

  static Timer startPositionBroadcast(Function getSelectedBus) {
    // controller = StreamController<Position>();

    // Crea un temporizador que se active cada 5 segundos y emita la posición
    return Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        Position position = await determinePosition();
        // controller.add(position);

        //  imprime latitud y long
        print('Latitud: ${position.latitude}');
        print('Longitud: ${position.longitude}');
        FirebaseDatabase database = FirebaseDatabase.instance;

        String selectedBus = getSelectedBus();

        if (selectedBus.isEmpty) {
          return;
        }

        print('Bus: $selectedBus');

        DatabaseReference ref = database.ref('camiones/${getSelectedBus()}');
        print(ref);

        ref.child('location').set({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': ServerValue.timestamp,
        });
        print('Location sent');
      } catch (e) {
        controller.addError(e);
      }
    });
  }
}
