import 'package:hive_flutter/hive_flutter.dart';
import '../models/behavior_data.dart';

class BehaviorStorageService {
  static const String _boxName = 'behaviorData';
  static const String _dataKey = 'behavior_data';

  static Future<void> saveBehaviorData(BehaviorData data) async {
    try {
      final box = Hive.box(_boxName);
      final existingData = box.get(_dataKey, defaultValue: <Map<String, dynamic>>[]) as List<dynamic>;
      
      // Convert to proper list of maps
      final dataList = existingData.map((item) {
        try {
          return Map<String, dynamic>.from(item as Map);
        } catch (e) {
          print('Error converting existing data item: $e');
          return <String, dynamic>{};
        }
      }).toList();
      
      // Add timestamp to the data
      final dataWithTimestamp = <String, dynamic>{
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': data.toJson(),
      };
      
      dataList.add(dataWithTimestamp);
      
      // Keep only last 1000 entries to prevent memory issues
      if (dataList.length > 1000) {
        dataList.removeRange(0, dataList.length - 1000);
      }
      
      await box.put(_dataKey, dataList);
    } catch (e) {
      print('Error saving behavior data: $e');
    }
  }

  static Future<List<BehaviorData>> getAllBehaviorData() async {
    try {
      final box = Hive.box(_boxName);
      final rawData = box.get(_dataKey, defaultValue: <Map<String, dynamic>>[]) as List<dynamic>;
      
      return rawData.map((item) {
        try {
          final itemMap = Map<String, dynamic>.from(item as Map);
          final dataMap = Map<String, dynamic>.from(itemMap['data'] as Map);
          return BehaviorData.fromJson(dataMap);
        } catch (e) {
          print('Error parsing behavior data item: $e');
          // Return a default BehaviorData with zeros if parsing fails
          return BehaviorData(
            tapDuration: 0.0,
            swipeVelocity: 0.0,
            touchPressure: 0.0,
            tapIntervalAvg: 0.0,
            accelVariance: 0.0,
            accelVarianceMissing: 0,
            gyroVariance: 0.0,
            gyroVarianceMissing: 0,
            batteryLevel: 0.0,
            chargingState: 0,
            brightnessLevel: 0.0,
            screenOnTime: 0.0,
            wifiIdHash: 0.0,
            wifiInfoMissing: 0,
            gpsLatitude: 0.0,
            gpsLongitude: 0.0,
            gpsLocationMissing: 0,
            timeOfDaySin: 0.0,
            timeOfDayCos: 0.0,
            dayOfWeekMon: 0,
            dayOfWeekTue: 0,
            dayOfWeekWed: 0,
            dayOfWeekThu: 0,
            dayOfWeekFri: 0,
            dayOfWeekSat: 0,
            dayOfWeekSun: 0,
            deviceOrientation: 0.0,
            touchArea: 0.0,
            touchEventCount: 0.0,
            appUsageTime: 0.0,
          );
        }
      }).toList();
    } catch (e) {
      print('Error getting all behavior data: $e');
      return <BehaviorData>[];
    }
  }

  static Future<void> clearAllData() async {
    try {
      final box = Hive.box(_boxName);
      await box.clear();
      print('All behavior data cleared successfully');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  static Future<int> getDataCount() async {
    final box = Hive.box(_boxName);
    final rawData = box.get(_dataKey, defaultValue: <Map<String, dynamic>>[]) as List<dynamic>;
    return rawData.length;
  }

  static Future<void> resetDataStructure() async {
    try {
      final box = Hive.box(_boxName);
      await box.put(_dataKey, <Map<String, dynamic>>[]);
      print('Data structure reset successfully');
    } catch (e) {
      print('Error resetting data structure: $e');
    }
  }
}