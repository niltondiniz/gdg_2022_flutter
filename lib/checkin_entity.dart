import 'dart:convert';

class CheckInEntity {
  final String busId;
  final int checkInTime;

  CheckInEntity(
    this.busId,
    this.checkInTime,
  );

  CheckInEntity copyWith({
    String? busId,
    int? checkInTime,
  }) {
    return CheckInEntity(
      busId ?? this.busId,
      checkInTime ?? this.checkInTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'checkInTime': checkInTime,
    };
  }

  factory CheckInEntity.fromMap(Map<String, dynamic> map) {
    return CheckInEntity(
      map['busId'] ?? '',
      map['checkInTime']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory CheckInEntity.fromJson(String source) =>
      CheckInEntity.fromMap(json.decode(source));

  @override
  String toString() => 'CheckIn(busId: $busId, checkInTime: $checkInTime)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CheckInEntity &&
        other.busId == busId &&
        other.checkInTime == checkInTime;
  }

  @override
  int get hashCode => busId.hashCode ^ checkInTime.hashCode;
}
