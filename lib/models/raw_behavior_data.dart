import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:location/location.dart' as loc;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/touch_event_service.dart';

class RawBehaviorData {
  // Touch
  final double? rawTapDuration;
  final double? rawSwipeVelocity;
  final double? rawTouchPressure;
  final double? rawTapIntervalAvg;

  // Motion sensors
  final List<double>? rawAccelReadings; // e.g., [x, y, z] samples
  final bool accelMissing;
  final List<double>? rawGyroReadings; // e.g., [x, y, z] samples
  final bool gyroMissing;

  // Device context
  final double? rawBatteryLevel;
  final bool? rawChargingState;
  final double? rawBrightnessLevel;
  final double? rawScreenOnTime;

  // Network/Location
  final String? rawWifiSsidHash;
  final bool wifiInfoMissing;
  final double? rawGpsLatitude;
  final double? rawGpsLongitude;
  final bool gpsLocationMissing;

  // Additional behavioral metrics
  final double? rawDeviceOrientation;
  final double? rawTouchArea;
  final int? rawTouchEventCount;
  final double? rawAppUsageTime;
  final DateTime collectionTimestamp;

  RawBehaviorData({
    this.rawTapDuration,
    this.rawSwipeVelocity,
    this.rawTouchPressure,
    this.rawTapIntervalAvg,
    this.rawAccelReadings,
    this.accelMissing = false,
    this.rawGyroReadings,
    this.gyroMissing = false,
    this.rawBatteryLevel,
    this.rawChargingState,
    this.rawBrightnessLevel,
    this.rawScreenOnTime,
    this.rawWifiSsidHash,
    this.wifiInfoMissing = false,
    this.rawGpsLatitude,
    this.rawGpsLongitude,
    this.gpsLocationMissing = false,
    this.rawDeviceOrientation,
    this.rawTouchArea,
    this.rawTouchEventCount,
    this.rawAppUsageTime,
    DateTime? collectionTimestamp,
  }) : collectionTimestamp = collectionTimestamp ?? DateTime.now();

  static Future<RawBehaviorData> collect() async {
    final collectionStart = DateTime.now();
    
    try {
      // Collect all data concurrently for better performance
      final results = await Future.wait([
        _collectTouchMetrics(),
        _collectMotionSensors(),
        _collectDeviceContext(),
        _collectLocationData(),
        _collectNetworkInfo(),
      ]);

      final touchStats = results[0];
      final motionData = results[1];
      final deviceContext = results[2];
      final locationData = results[3];
      final networkInfo = results[4];

      // Calculate additional metrics
      final deviceOrientation = motionData['deviceOrientation'] as double?;
      final appUsageTime = (DateTime.now().millisecondsSinceEpoch - collectionStart.millisecondsSinceEpoch) / 1000.0;

      return RawBehaviorData(
        rawTapDuration: touchStats['tapDuration'],
        rawSwipeVelocity: touchStats['swipeVelocity'],
        rawTouchPressure: touchStats['touchPressure'],
        rawTapIntervalAvg: touchStats['tapIntervalAvg'],
        rawAccelReadings: motionData['accel'],
        accelMissing: motionData['accelMissing'] ?? false,
        rawGyroReadings: motionData['gyro'],
        gyroMissing: motionData['gyroMissing'] ?? false,
        rawBatteryLevel: deviceContext['batteryLevel'],
        rawChargingState: deviceContext['chargingState'],
        rawBrightnessLevel: deviceContext['brightnessLevel'],
        rawScreenOnTime: touchStats['screenOnTime'],
        rawWifiSsidHash: networkInfo['wifiSsidHash'],
        wifiInfoMissing: networkInfo['wifiMissing'] ?? false,
        rawGpsLatitude: locationData['gpsLat'],
        rawGpsLongitude: locationData['gpsLong'],
        gpsLocationMissing: locationData['gpsMissing'] ?? false,
        rawDeviceOrientation: deviceOrientation,
        rawTouchArea: touchStats['touchArea'],
        rawTouchEventCount: touchStats['touchEventCount'],
        rawAppUsageTime: appUsageTime,
        collectionTimestamp: collectionStart,
      );
    } catch (e) {
      // Return minimal data if collection fails
      return RawBehaviorData(
        accelMissing: true,
        gyroMissing: true,
        wifiInfoMissing: true,
        gpsLocationMissing: true,
        collectionTimestamp: collectionStart,
      );
    }
  }

  static Future<Map<String, dynamic>> _collectTouchMetrics() async {
    try {
      final touchStats = TouchEventService.instance.getAndResetStats();
      return touchStats;
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  static Future<Map<String, dynamic>> _collectMotionSensors() async {
    List<double>? accel;
    bool accelMissing = false;
    List<double>? gyro;
    bool gyroMissing = false;
    double? deviceOrientation;

    try {
      // Collect accelerometer data
      final accelEvent = await accelerometerEvents.first.timeout(
        const Duration(milliseconds: 800),
      );
      accel = [accelEvent.x, accelEvent.y, accelEvent.z];
      
      // Calculate device orientation from accelerometer
      deviceOrientation = atan2(accelEvent.y, accelEvent.x) * 180 / pi;
    } catch (_) {
      accelMissing = true;
    }

    try {
      // Collect gyroscope data
      final gyroEvent = await gyroscopeEvents.first.timeout(
        const Duration(milliseconds: 800),
      );
      gyro = [gyroEvent.x, gyroEvent.y, gyroEvent.z];
    } catch (_) {
      gyroMissing = true;
    }

    return {
      'accel': accel,
      'accelMissing': accelMissing,
      'gyro': gyro,
      'gyroMissing': gyroMissing,
      'deviceOrientation': deviceOrientation,
    };
  }

  static Future<Map<String, dynamic>> _collectDeviceContext() async {
    double? batteryLevel;
    bool? chargingState;
    double? brightnessLevel;

    try {
      // Collect battery information
      final battery = Battery();
      final batteryLevelInt = await battery.batteryLevel.timeout(
        const Duration(seconds: 2),
      );
      batteryLevel = batteryLevelInt / 100.0;
      
      final state = await battery.batteryState.timeout(
        const Duration(seconds: 2),
      );
      chargingState = state == BatteryState.charging || state == BatteryState.full;
    } catch (_) {
      // Battery info failed
    }

    try {
      // Collect brightness information
      brightnessLevel = await ScreenBrightness().current.timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      // Brightness info failed
    }

    return {
      'batteryLevel': batteryLevel,
      'chargingState': chargingState,
      'brightnessLevel': brightnessLevel,
    };
  }

  static Future<Map<String, dynamic>> _collectLocationData() async {
    double? gpsLat;
    double? gpsLong;
    bool gpsMissing = false;

    try {
      final location = loc.Location();
      
      // Check if location service is enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          gpsMissing = true;
          return {
            'gpsLat': null,
            'gpsLong': null,
            'gpsMissing': gpsMissing,
          };
        }
      }

      // Check permissions
      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          gpsMissing = true;
          return {
            'gpsLat': null,
            'gpsLong': null,
            'gpsMissing': gpsMissing,
          };
        }
      }

      // Get location with timeout
      final locationData = await location.getLocation().timeout(
        const Duration(seconds: 5),
      );
      
      gpsLat = locationData.latitude;
      gpsLong = locationData.longitude;
    } catch (_) {
      gpsMissing = true;
    }

    return {
      'gpsLat': gpsLat,
      'gpsLong': gpsLong,
      'gpsMissing': gpsMissing,
    };
  }

  static Future<Map<String, dynamic>> _collectNetworkInfo() async {
    String? wifiSsidHash;
    bool wifiMissing = false;

    try {
      final connectivity = Connectivity();
      final connectivityResults = await connectivity.checkConnectivity().timeout(
        const Duration(seconds: 3),
      );
      
      // Fix: Check if WiFi is connected - handle single result
      bool isWifiConnected = connectivityResults == ConnectivityResult.wifi;

      if (isWifiConnected) {
        try {
          // Create a meaningful hash for WiFi identification
          final now = DateTime.now();
          final dayIdentifier = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
          final hourIdentifier = now.hour;
          
          // Create a hash that's stable for the current day and hour
          wifiSsidHash = 'wifi_${dayIdentifier}_$hourIdentifier'.hashCode.abs().toString();
          wifiMissing = false;
        } catch (_) {
          wifiMissing = true;
        }
      } else {
        wifiMissing = true;
      }
    } catch (_) {
      wifiMissing = true;
    }

    print('WiFi Collection: hash=$wifiSsidHash, missing=$wifiMissing'); // Debug log

    return {
      'wifiSsidHash': wifiSsidHash,
      'wifiMissing': wifiMissing,
    };
  }
} 