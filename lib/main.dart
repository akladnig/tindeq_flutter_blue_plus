// Copyright 2017-2023, Charles Weinberger & Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/models/ble_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'screens/bluetooth_off_screen.dart';
import 'screens/scan_screen.dart';

void main() {
  runApp(
    ProviderScope(
      child: FlutterBlueApp(),
    ),
  );
}

//TODO - done!
// @Riverpod(keepAlive: true)
// Stream<BluetoothAdapterState> bleState(BleStateRef ref) {
//   return FlutterBluePlus.adapterState;
// }

//TODO - done!
// @riverpod
// Stream<List<ScanResult>> bleScanner(BleScannerRef ref) {
//   return FlutterBluePlus.scanResults;
// }

// @riverpod
// class IsScanning extends _$IsScanning {
//   @override
//   Future<bool> build() {
//     return Future.value(false);
//   }

//   Future<void> startScan(
//       {Duration timeout = const Duration(seconds: 2)}) async {
//     state = const AsyncLoading();
//     AsyncValue.guard(() async {
//       return await FlutterBluePlus.startScan(removeIfGone: 5.seconds);
//     });
//     state = const AsyncData(true);
//   }

//   Future<void> stopScan() async {
//     state = const AsyncLoading();
//     AsyncValue.guard(() async {
//       return await FlutterBluePlus.stopScan();
//     });
//     state = const AsyncData(false);
//   }
// }

// @Riverpod(keepAlive: true)
// class StreamDevice extends _$StreamDevice {
//   @override
//   FutureOr<BluetoothDevice?> build() async {
//     ref.onDispose(() async {
//       await disconnect();
//       return Future.value(null);
//     });
//     return null;
//   }

//   Future<void> connect(BluetoothDevice device) async {
//     var prevDeviceConnectionState =
//         await state.asData?.value?.connectionState.last;
//     if (prevDeviceConnectionState == BluetoothConnectionState.connected) {
//       await disconnect();
//     }
//     state = const AsyncLoading();
//     state = await AsyncValue.guard(() async {
//       appLog('Connecting to device: ${device.localName}');
//       if (kDebugMode) {
//         print('Connecting to device: ${device.localName}');
//       }
//       await device.connect(autoConnect: true);
//       appLog('Connected to device: ${device.localName}');
//       return device;
//     });
//   }

//   Future<void> disconnect() async {
//     var device = state.asData?.value;
//     state = const AsyncLoading();
//     state = await AsyncValue.guard(() async {
//       await device?.disconnect();
//       appLog('Disconnecting from device: ${device?.localName}');
//       return null;
//     });
//   }

//   // reset
//   Future<void> reset() async {
//     state = const AsyncData(null);
//   }
// }

// @riverpod
// Stream<BluetoothAdapterState> adapterState(AdapterStateRef ref) {
//   return FlutterBluePlus.adapterState;
// }

class FlutterBlueApp extends ConsumerStatefulWidget {
  const FlutterBlueApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FlutterBlueAppStateState();
}

class _FlutterBlueAppStateState extends ConsumerState<FlutterBlueApp> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<BluetoothAdapterState> adapterState =
        ref.watch(adapterStateProvider);

    Widget screen =
        BluetoothOffScreen(adapterState: BluetoothAdapterState.unknown);
    // TODO update to AsyncValueWidget
    switch (adapterState) {
      case AsyncData(:var value):
        screen = value == BluetoothAdapterState.on
            ? const ScanScreen()
            : BluetoothOffScreen(adapterState: value);
      case AsyncError(:final error):
        Text('Error: $error');
      case _:
        const CircularProgressIndicator();
    }
    ;

    return MaterialApp(
      color: Colors.lightGreen,
      home: screen,
      navigatorObservers: [BluetoothAdapterStateObserver()],
    );
  }
}

class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Start listening to Bluetooth state changes when a new route is pushed
      _adapterStateSubscription ??=
          FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          // Pop the current route if Bluetooth is off
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Cancel the subscription when the route is popped
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}
