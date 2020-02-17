import 'package:meta/meta.dart';

class Device {
  final String name;
  final String address;

  Device({
    this.name,
    @required this.address,
  });

  Device copyWith({
    String name,
    String address,
  }) => Device(
    name: name ?? this.name,
    address: address ?? this.address,
    );
}