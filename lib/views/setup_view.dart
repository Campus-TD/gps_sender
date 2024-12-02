import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../controllers/setup_controller.dart';

class SetupView extends StatefulWidget {
  const SetupView({super.key});

  @override
  State<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<SetupView> {
  final TextEditingController controller = TextEditingController();
  final SetupController setupController = SetupController();

  final List<String> buses = <String>[
    'CA 1',
    'CA 2',
    'CA 3',
    'CA 4',
    'CA 5',
    'CA 6',
    'CA 7',
    'CA 8',
    'SN',
  ];
  String selectedBus = '';

  @override
  void initState() {
    var config = Hive.box('config');
    if (config.containsKey('bus')) {
      selectedBus = config.get('bus');
    }
    super.initState();
  }

  @override
  void dispose() {
    setupController.stopGpsTransmission();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GPS Positioning',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                  ),
                  child: Text(
                    'Número Del Camión',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GridView(
                shrinkWrap: true,
                // gridDelegate:
                // alignment: WrapAlignment.spaceBetween,
                // crossAxisAlignment: WrapCrossAlignment.center,
                // runSpacing: 5,
                // spacing: 25,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                children: List<Widget>.generate(
                  buses.length,
                  (int index) {
                    return ChoiceChip(
                      padding: const EdgeInsets.all(20),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      selectedColor: Colors.teal.shade200,
                      label: Text(buses[index]),
                      selected: selectedBus == buses[index],
                      onSelected: (bool value) async {
                        selectedBus = value ? buses[index] : '';
                        var config = Hive.box('config');
                        config.put('bus', selectedBus);
                        await config.flush();
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              setupController.isGpsEnabled
                  ? Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade800,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        onPressed: () {
                          setupController.stopGpsTransmission();
                          setState(() {});
                        },
                        label: const Text(
                          'Desactivar GPS',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        icon: const Icon(
                          Icons.stop,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        onPressed: () {
                          setupController.startGpsTransmission();
                          setState(() {});
                        },
                        label: const Text(
                          'Activar GPS',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        icon: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
