import 'package:flutter/material.dart';
import 'package:gdg_2022/home_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.name}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

  final String name;
}

class _HomePageState extends State<HomePage> {
  TextEditingController findField = TextEditingController();
  HomeController controller = HomeController();
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-22.1219555, -43.2104422),
    zoom: 14.4746,
  );

  InputBorder enabledBorder = const OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(15),
    ),
    borderSide: BorderSide(
      color: Colors.transparent,
      width: 0,
    ),
  );

  @override
  void initState() {
    controller.updateMap();
    controller.initLocation();
    controller.initMarker();
    controller.getBusPosition();
    controller.state = this;
    super.initState();
  }

  @override
  void dispose() {
    controller.mapUpdateTimer!.cancel();
    controller.mapUpdateTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('KD o Busão?'),
      // ),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              GoogleMap(
                zoomControlsEnabled: false,
                markers: controller.busMarkerList,
                mapType: MapType.normal,
                myLocationButtonEnabled: false,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController mapController) {
                  _controller.complete(mapController);
                  controller.mapController = mapController;
                  controller.centerMap();
                },
              ),
              Positioned(
                top: 32,
                left: 16,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  //height: 70,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 2,
                            offset: Offset(3, 3),
                            blurRadius: 3)
                      ]),
                  child: Center(
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      //style: TextStyle(fontSize: 25),
                      onChanged: controller.findBus,
                      controller: findField,
                      decoration: InputDecoration(
                          hintText: 'Pesquise o ônibus desejado',
                          prefixIcon: const Icon(Icons.search),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (controller.checkInState == null) {
            controller.checkIn();
          } else {
            controller.checkOut();
          }
        },
        label: controller.checkInState == null
            ? const Text('Check-In')
            : Row(children: [
                const Text('Fazer check-out de '),
                Text(
                  controller.checkInState!.busId,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.amber),
                )
              ]),
        icon: SizedBox(
          width: 25,
          child: Image.asset('assets/markers/bus_marker.png'),
        ),
        backgroundColor: controller.checkInState == null
            ? ThemeData.light().primaryColor
            : ThemeData.light().errorColor,
      ),
    );
  }
}
