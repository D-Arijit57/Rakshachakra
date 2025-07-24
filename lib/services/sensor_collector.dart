import 'dart:math';
import '../models/raw_behavior_data.dart';
import '../models/behavior_data.dart';

class SensorCollector {
  // GPS bounding box for normalization (example: India)
  static const double _minLat = 6.0;
  static const double _maxLat = 37.0;
  static const double _minLon = 68.0;
  static const double _maxLon = 97.0;

  static BehaviorData normalize(RawBehaviorData raw, {String? userId, int? sessionId}) {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday

    // Time encoding
    final timeOfDaySin = sin(2 * pi * hour / 24);
    final timeOfDayCos = cos(2 * pi * hour / 24);

    // Day of week one-hot encoding
    final dayOfWeekMon = weekday == 1 ? 1 : 0;
    final dayOfWeekTue = weekday == 2 ? 1 : 0;
    final dayOfWeekWed = weekday == 3 ? 1 : 0;
    final dayOfWeekThu = weekday == 4 ? 1 : 0;
    final dayOfWeekFri = weekday == 5 ? 1 : 0;
    final dayOfWeekSat = weekday == 6 ? 1 : 0;
    final dayOfWeekSun = weekday == 7 ? 1 : 0;

    // Touch metrics normalization - BETTER RANGES based on real data
    final tapDuration = _normalizeRange(raw.rawTapDuration, 10.0, 500.0);         // 10ms to 500ms (more realistic)
    final swipeVelocity = _normalizeRange(raw.rawSwipeVelocity, 50.0, 1000.0);    // 50 to 1000 px/s (more realistic)
    final touchPressure = _normalizeRange(raw.rawTouchPressure, 0.05, 0.8);       // 0.05 to 0.8 (avoid constant 1.0)
    final tapIntervalAvg = _normalizeRange(raw.rawTapIntervalAvg, 50.0, 1000.0);  // 50ms to 1s (more realistic)

    // Motion sensor variance calculation and normalization - BETTER RANGES
    double accelVariance = 0.0;
    int accelVarianceMissing = raw.accelMissing ? 1 : 0;
    if (!raw.accelMissing && raw.rawAccelReadings != null && raw.rawAccelReadings!.isNotEmpty) {
      accelVariance = _calculateVariance(raw.rawAccelReadings!);
      accelVariance = _normalizeRange(accelVariance, 0.001, 5.0); // Better variance range
    }

    double gyroVariance = 0.0;
    int gyroVarianceMissing = raw.gyroMissing ? 1 : 0;
    if (!raw.gyroMissing && raw.rawGyroReadings != null && raw.rawGyroReadings!.isNotEmpty) {
      gyroVariance = _calculateVariance(raw.rawGyroReadings!);
      gyroVariance = _normalizeRange(gyroVariance, 0.0001, 1.0); // Better variance range
    }

    // Device context normalization - FIX BRIGHTNESS ISSUE
    final batteryLevel = (raw.rawBatteryLevel ?? 0.0).clamp(0.0, 1.0); // Already 0-1 from collection
    final chargingState = raw.rawChargingState == true ? 1 : 0;
    
    // FIX BRIGHTNESS - your data shows 0.002-0.58, so it's already normalized but with wrong scale
    // Let's pass it through as-is since the system gives us proper values
    final brightnessLevel = raw.rawBrightnessLevel ?? 0.0;
    
    final screenOnTime = _normalizeRange(raw.rawScreenOnTime, 0.0, 300.0); // 0 to 5 minutes (more realistic)

    // Network/Location normalization - FIX WIFI HASH to get non-zero values
    double wifiIdHash = 0.0;
    int wifiInfoMissing = raw.wifiInfoMissing ? 1 : 0;
    if (!raw.wifiInfoMissing && raw.rawWifiSsidHash != null && raw.rawWifiSsidHash!.isNotEmpty) {
      // Better hash calculation to avoid mostly 0 values
      final hashString = raw.rawWifiSsidHash!;
      final hash = hashString.hashCode.abs(); // Use string hashCode instead of parsing
      wifiIdHash = _normalizeHash(hash);
    }

    double gpsLatitude = 0.0;
    double gpsLongitude = 0.0;
    int gpsLocationMissing = raw.gpsLocationMissing ? 1 : 0;
    if (!raw.gpsLocationMissing && raw.rawGpsLatitude != null && raw.rawGpsLongitude != null) {
      gpsLatitude = _normalizeLatitude(raw.rawGpsLatitude!);
      gpsLongitude = _normalizeLongitude(raw.rawGpsLongitude!);
    }

    return BehaviorData(
      tapDuration: tapDuration,
      swipeVelocity: swipeVelocity,
      touchPressure: touchPressure,
      tapIntervalAvg: tapIntervalAvg,
      accelVariance: accelVariance,
      accelVarianceMissing: accelVarianceMissing,
      gyroVariance: gyroVariance,
      gyroVarianceMissing: gyroVarianceMissing,
      batteryLevel: batteryLevel,
      chargingState: chargingState,
      brightnessLevel: brightnessLevel,
      screenOnTime: screenOnTime,
      wifiIdHash: wifiIdHash,
      wifiInfoMissing: wifiInfoMissing,
      gpsLatitude: gpsLatitude,
      gpsLongitude: gpsLongitude,
      gpsLocationMissing: gpsLocationMissing,
      timeOfDaySin: timeOfDaySin,
      timeOfDayCos: timeOfDayCos,
      dayOfWeekMon: dayOfWeekMon,
      dayOfWeekTue: dayOfWeekTue,
      dayOfWeekWed: dayOfWeekWed,
      dayOfWeekThu: dayOfWeekThu,
      dayOfWeekFri: dayOfWeekFri,
      dayOfWeekSat: dayOfWeekSat,
      dayOfWeekSun: dayOfWeekSun,
      deviceOrientation: _normalizeRange(raw.rawDeviceOrientation, -90.0, 90.0),      // More realistic range
      touchArea: _normalizeRange(raw.rawTouchArea, 1.0, 50.0),                     // Smaller, more realistic range
      touchEventCount: _normalizeRange(raw.rawTouchEventCount?.toDouble(), 0.0, 20.0), // Lower max for more variation
      appUsageTime: _normalizeRange(raw.rawAppUsageTime, 0.0, 10.0),               // 0 to 10 seconds (more realistic)
      timestamp: raw.collectionTimestamp,
      userId: userId,
      sessionId: sessionId,
    );
  }

  // IMPROVED NORMALIZATION FUNCTION
  static double _normalizeRange(double? value, double min, double max) {
    if (value == null) return 0.0;
    if (max <= min) return 0.5; // Avoid division by zero
    
    // Clamp and normalize
    final clampedValue = value.clamp(min, max);
    final normalized = (clampedValue - min) / (max - min);
    
    return normalized.clamp(0.0, 1.0);
  }

  // FIXED VARIANCE CALCULATION
  static double _calculateVariance(List<double> values) {
    if (values.isEmpty || values.length == 1) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((x) => pow(x - mean, 2));
    final variance = squaredDiffs.reduce((a, b) => a + b) / values.length;
    
    return variance;
  }

  static double _normalizeHash(int hash) {
    // Better hash normalization to avoid mostly 0 values
    // Use modulo with a smaller number and add offset to avoid 0
    final normalizedHash = ((hash % 999983) + 1) / 1000000.0;  // +1 to avoid 0, prime modulo
    return normalizedHash.clamp(0.001, 1.0); // Ensure minimum value > 0
  }

  static double _normalizeLatitude(double lat) {
    return _normalizeRange(lat, _minLat, _maxLat);
  }

  static double _normalizeLongitude(double lon) {
    return _normalizeRange(lon, _minLon, _maxLon);
  }
}