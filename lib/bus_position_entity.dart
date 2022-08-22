import 'dart:convert';

class BusPositionEntity {
  final String busId;
  final String busInfo;
  final double lat;
  final double lon;
  final int positionTime;
  BusPositionEntity({
    required this.busId,
    required this.busInfo,
    required this.lat,
    required this.lon,
    required this.positionTime,
  });

  BusPositionEntity copyWith({
    String? busId,
    String? busInfo,
    double? lat,
    double? lon,
    int? positionTime,
  }) {
    return BusPositionEntity(
      busId: busId ?? this.busId,
      busInfo: busInfo ?? this.busInfo,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      positionTime: positionTime ?? this.positionTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'busInfo': busInfo,
      'lat': lat,
      'lon': lon,
      'positionTime': positionTime,
    };
  }

  factory BusPositionEntity.fromMap(Map<String, dynamic> map) {
    return BusPositionEntity(
      busId: map['busId'] ?? '',
      busInfo: map['busInfo'] ?? '',
      lat: map['lat']?.toDouble() ?? 0.0,
      lon: map['lon']?.toDouble() ?? 0.0,
      positionTime: map['positionTime']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory BusPositionEntity.fromJson(String source) =>
      BusPositionEntity.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BusPositionEntity(busId: $busId, busInfo: $busInfo, lat: $lat, lon: $lon, positionTime: $positionTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusPositionEntity &&
        other.busId == busId &&
        other.busInfo == busInfo &&
        other.lat == lat &&
        other.lon == lon &&
        other.positionTime == positionTime;
  }

  @override
  int get hashCode {
    return busId.hashCode ^
        busInfo.hashCode ^
        lat.hashCode ^
        lon.hashCode ^
        positionTime.hashCode;
  }
}
