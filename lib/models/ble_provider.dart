import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ble_provider.g.dart';

@riverpod
Stream<BluetoothAdapterState> adapterState(AdapterStateRef ref) {
  return FlutterBluePlus.adapterState;
}

@riverpod
Future<List<BluetoothDevice>> systemDevices(SystemDevicesRef ref) {
  return FlutterBluePlus.systemDevices;
}

@riverpod
Stream<List<ScanResult>> scanResults(ScanResultsRef ref) {
  return FlutterBluePlus.scanResults;
}

@riverpod
Stream<bool> isScanning(IsScanningRef) {
  return FlutterBluePlus.isScanning;
}

@riverpod
Future<void> startScan(StartScanRef ref) {
  return FlutterBluePlus.startScan(
      oneByOne: true, timeout: const Duration(seconds: 15));
}

@riverpod
Future<void> stopScan(StopScanRef ref) {
  return FlutterBluePlus.stopScan();
}

@riverpod
Future<void> connect(ConnectRef ref, BluetoothDevice device) {
  return device.connect();
}

@riverpod
Stream<BluetoothConnectionState> connectionState(
    ConnectionStateRef ref, BluetoothDevice device) {
  return device.connectionState;
}

@riverpod
Future<List<BluetoothService>> discoverServices(
    DiscoverServicesRef ref, BluetoothDevice device) {
  var connectionState = ref.watch(connectionStateProvider(device));

  return device.discoverServices();
}
