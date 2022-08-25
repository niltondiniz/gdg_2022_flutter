import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:gdg_2022/bus_position_entity.dart';
import 'package:gdg_2022/checkin_entity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'check_in_page.dart';

class HomeController {
  List<BusPositionEntity> busPositions = [];
  List<BusPositionEntity> filteredList = [];
  CheckInEntity? checkInState;
  Set<Marker> busMarkerList = <Marker>{};
  BitmapDescriptor? markerIcon;
  LatLng? currentLocation;
  GoogleMapController? mapController;
  Dio dio =
      Dio(BaseOptions(baseUrl: 'https://api-niltondiniz.cloud.okteto.net'));
  State? state;
  BuildContext? context;
  Timer? mapUpdateTimer;
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  late StreamSubscription<Position> positionStream;
  String? searchText;
  Uint8List? customMarkerCantagalo;
  Uint8List? customMarkerJaqueira;
  Uint8List? customMarkerMirante;
  Uint8List? customMarkerMonteCastelo;
  Uint8List? customMarkerMorada;
  Uint8List? customMarkerPalmital;
  Uint8List? customMarkerPiloes;
  Uint8List? customMarkerPonte;
  Uint8List? customMarkerMoura;

  Future<bool> getBusPosition() async {
    var response = await dio.get('/position');
    filteredList.clear();
    busPositions.clear();
    if (response.statusCode == 200) {
      var data = jsonDecode(response.data);
      for (var element in data) {
        busPositions.add(BusPositionEntity.fromMap(element));
      }

      if (searchText == null) {
        filteredList = List<BusPositionEntity>.from(busPositions);
      } else {
        if (searchText!.isNotEmpty) {
          filteredList = List<BusPositionEntity>.from(busPositions.where(
              (element) => element.busId
                  .toUpperCase()
                  .contains(searchText!.toUpperCase())));
        } else {
          filteredList = List<BusPositionEntity>.from(busPositions);
        }
      }

      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  //Pega a posição de todos os onibus
  updateMap() async {
    mapUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      //Realiza get para obter a posição dos onibus (API)
      if (await getBusPosition()) {
        drawMarkers();
      }
    });
  }

  //Realiza checkin, preenchendo os dados da entidade
  //Inicia o envio de posição
  checkIn() async {
    //Push na tela de check-in aguardando a resposta
    var busIdSelected = await Navigator.push<String>(
        context!,
        MaterialPageRoute<String>(
          builder: (BuildContext context) => CheckInPage(),
        ));

    if (busIdSelected != null) {
      if (busIdSelected.isNotEmpty) {
        checkInState =
            CheckInEntity(busIdSelected, DateTime.now().millisecondsSinceEpoch);
        startCheckInPosition();
      }
    }
  }

  //Limpa o objeto de checkin
  //Para o envio de informações
  checkOut() {
    checkInState = null;
    stopCheckInPosition();
  }

  //Inicia servico que vai ouvir as mudancas de posição
  startCheckInPosition() {
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      sendPosition(position!);
    });
  }

  //Envia posição atualizada
  sendPosition(Position position) async {
    //Realiza post para a api que guarda os dados de posição dos onibus
    var result = await dio.post('/position', data: {
      "busId": checkInState!.busId,
      "busInfo":
          "Linha ${checkInState!.busId} x Centro 101, Saída do Bairro: 12:00",
      "lat": position.latitude,
      "lon": position.longitude,
      "positionTime": DateTime.now().millisecondsSinceEpoch,
    });
  }

  //Para de ouvir as mudanças de posição
  stopCheckInPosition() {
    positionStream.cancel();
  }

  //Filtra o onibus desejado
  findBus(String busId) {
    searchText = busId;
    var listToFind = List<BusPositionEntity>.from(busPositions);
    if (busId != '') {
      filteredList = listToFind
          .where((element) =>
              element.busId.toUpperCase().contains(busId.toUpperCase()))
          .toList();
    } else {
      filteredList = List<BusPositionEntity>.from(busPositions);
    }
    drawMarkers();
  }

  drawMarkers() {
    busMarkerList.clear();

    var now = DateTime.now();
    var convertedDate =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}';

    busMarkerList.add(
      Marker(
        markerId: MarkerId(
          currentLocation!.latitude.toString(),
        ),
        position: LatLng(currentLocation!.latitude, currentLocation!.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
            title: 'Sua localização',
            snippet: 'Última localização $convertedDate'),
      ),
    );

    for (var element in filteredList) {
      try {
        var dateFromMilliseconds =
            DateTime.fromMillisecondsSinceEpoch(element.positionTime);
        var formatedTime =
            '${dateFromMilliseconds.day}/${dateFromMilliseconds.month}/${dateFromMilliseconds.year} ${dateFromMilliseconds.hour}:${dateFromMilliseconds.minute}:${dateFromMilliseconds.second}';
        busMarkerList.add(
          Marker(
            markerId: MarkerId(
              element.lat.toString(),
            ),
            position: LatLng(element.lat, element.lon),
            icon: BitmapDescriptor.fromBytes(
                getCustomMarkerByName(element.busId)!),
            infoWindow: InfoWindow(
                title: element.busId,
                snippet:
                    '${element.busInfo} \nÚltima localização: $formatedTime'),
          ),
        );
      } catch (e) {
        print('Não use prints em try catchs!!');
      }
    }
    // ignore: invalid_use_of_protected_member
    state!.setState(() {});
  }

  Future<Uint8List> getBytesFromAsset(
      {required String path, required int width}) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  getCustomMarkerByName(String name) {
    switch (name) {
      case 'Cantagalo':
        return customMarkerCantagalo;
      case 'Jaqueira':
        return customMarkerJaqueira;
      case 'Mirante Sul':
        return customMarkerMirante;
      case 'Monte Castelo':
        return customMarkerMonteCastelo;
      case 'Morada do Sol':
        return customMarkerMorada;
      case 'Palmital':
        return customMarkerPalmital;
      case 'Pilões':
        return customMarkerPiloes;
      case 'Ponte das Garças':
        return customMarkerPonte;
      case 'Moura Brasil':
        return customMarkerMoura;
      default:
    }
  }

  initMarker() async {
    customMarkerCantagalo = await getBytesFromAsset(
      path: 'assets/markers/bus_cantagalo.png',
      width: 180,
    );

    customMarkerJaqueira = await getBytesFromAsset(
      path: 'assets/markers/bus_jaqueira.png',
      width: 180,
    );

    customMarkerMirante = await getBytesFromAsset(
      path: 'assets/markers/bus_mirante.png',
      width: 180,
    );

    customMarkerMonteCastelo = await getBytesFromAsset(
      path: 'assets/markers/bus_monte_castelo.png',
      width: 180,
    );

    customMarkerMorada = await getBytesFromAsset(
      path: 'assets/markers/bus_morada.png',
      width: 180,
    );

    customMarkerPalmital = await getBytesFromAsset(
      path: 'assets/markers/bus_palmital.png',
      width: 180,
    );

    customMarkerPiloes = await getBytesFromAsset(
      path: 'assets/markers/bus_piloes.png',
      width: 180,
    );

    customMarkerPonte = await getBytesFromAsset(
      path: 'assets/markers/bus_ponte.png',
      width: 180,
    );

    customMarkerMoura = await getBytesFromAsset(
      path: 'assets/markers/bus_moura.png',
      width: 180,
    );
  }

  initLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentLocation = LatLng(position.latitude, position.longitude);
    centerMap();
  }

  centerMap() {
    if (mapController != null && currentLocation != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation!, 13),
      );
    }
  }
}
