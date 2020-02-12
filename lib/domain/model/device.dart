import 'package:meta/meta.dart';

class Device {
  final String name;
  final String address;
  final String type;

  Device({
    this.name,
    @required this.address,
    this.type
  });

  Device copyWith({
    String name,
    String address,
    String type,
  }) => Device(
    name: name ?? this.name,
    address: address ?? this.address,
    type: type ?? this.type
    );
}