import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/models/ble_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device_screen.dart';
import '../utils/snackbar.dart';
import '../widgets/scan_result_tile.dart';
import '../utils/extra.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];

  Future onScanPressed() async {
    try {
      ref.watch(startScanProvider);
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e),
          success: false);
    }
  }

  Future onStopPressed() async {
    try {
      ref.watch(stopScanProvider);
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e),
          success: false);
    }
  }

  void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      Snackbar.show(ABC.c, prettyException("Connect Error:", e),
          success: false);
    });
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => DeviceScreen(device: device),
        settings: RouteSettings(name: '/DeviceScreen'));
    Navigator.of(context).push(route);
  }

  Future onRefresh() {
    if (_isScanning == false) {
      ref.watch(startScanProvider);
    }
    return Future.delayed(Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton(
        child: const Icon(Icons.stop),
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
      );
    } else {
      return FloatingActionButton(
          child: const Text("SCAN"), onPressed: onScanPressed);
    }
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () => onConnectPressed(r.device),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Immediately start scanning for the Tindeq
    // TODO add try/catch, guard etc
    ref.watch(startScanProvider);
    final _scanResultsAsyncValue = ref.watch(scanResultsProvider);
    BluetoothDevice tindeqDevice;
    switch (_scanResultsAsyncValue) {
      case AsyncData(:var value):
        if (value.isNotEmpty) {
          if (value[0].device.platformName.contains('Progressor')) {
            tindeqDevice = value[0].device;
            _scanResults = value;
            // Stop scanning if the Tindeq is found
            ref.watch(stopScanProvider);
            // Connect to the Tindeq
            ref.watch(connectProvider(tindeqDevice));
            debugPrint(
                'scanResult: ${_scanResults.length} ${_scanResults[0].device}');
          }
        }
      case AsyncError(:final error):
        Text('Error: $error');
      case _:
        const CircularProgressIndicator();
    }
    ;
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Find Devices'),
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: <Widget>[
              ..._buildScanResultTiles(context),
            ],
          ),
        ),
        floatingActionButton: buildScanButton(context),
      ),
    );
  }
}
