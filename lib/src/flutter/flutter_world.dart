import 'package:flutter_driver/flutter_driver.dart';
import 'package:gherkin/gherkin.dart';
import 'dart:io';
import 'flutter_run_process_handler.dart';

class FlutterWorld extends World {
  FlutterDriver _driver;
  FlutterRunProcessHandler _flutterRunProcessHandler;

  FlutterDriver get driver => _driver;

  void setFlutterDriver(FlutterDriver flutterDriver) {
    _driver = flutterDriver;
  }

  void setFlutterProccessHandler(
      FlutterRunProcessHandler flutterRunProcessHandler) {
    _flutterRunProcessHandler = flutterRunProcessHandler;
  }

  Future<bool> restartApp(
      {Duration timeout = const Duration(seconds: 60)}) async {
    await _driver.waitUntilNoTransientCallbacks();
    await _driver.close();
    final result = await _flutterRunProcessHandler?.restart(
      timeout: timeout,
    );

    stdout.writeln('Reconnecting Flutter driver...');
    _driver = await FlutterDriver.connect(
        dartVmServiceUrl: _flutterRunProcessHandler.currentObservatoryUri,
        logCommunicationToFile: true,
        printCommunication: false);

    return result;
  }

  @override
  void dispose() async {
    try {
      _flutterRunProcessHandler = null;
      await _driver?.waitUntilNoTransientCallbacks();
      await _driver?.close();
    } catch (_) {}
  }
}
