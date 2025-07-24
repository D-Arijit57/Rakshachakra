import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../utils/user_id_generator.dart';
import '../services/behavior_storage_service.dart';

class CloudMLTrainingService {
  static final CloudMLTrainingService _instance = CloudMLTrainingService._internal();
  factory CloudMLTrainingService() => _instance;
  CloudMLTrainingService._internal();

  // EC2-hosted ML API endpoint
  static const String _baseApiUrl = "http://43.204.97.149";
  static const Duration _timeout = Duration(seconds: 30);
  
  final AuthService _authService = AuthService();

  /// Upload initial training data for a new user
  Future<bool> uploadInitialTrainingData() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user found');
        return false;
      }

      final userId = UserIdGenerator.generateUserId(currentUser.username);
      final apiUrl = "$_baseApiUrl/add_user/$userId";

      print('📤 Uploading initial training data for user: ${currentUser.username}');
      print('🆔 User ID: $userId');
      print('🌐 API URL: $apiUrl');

      // Get all behavioral data from local storage
      final behaviorData = await BehaviorStorageService.getAllBehaviorData();
      
      if (behaviorData.isEmpty) {
        print('⚠️ No behavioral data found for training');
        return false;
      }

      // Convert to CSV format
      final csvData = _convertToCSV(behaviorData);
      
      // Create multipart request for file upload
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      
      // Add CSV data as file
      request.files.add(
        http.MultipartFile.fromString(
          'file',
          csvData,
          filename: 'behavioral_training_data.csv',
        ),
      );

      // Send request
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Training data uploaded successfully: ${result['message']}');
        return true;
      } else {
        print('❌ Upload failed with status: ${response.statusCode}');
        print('📄 Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error uploading training data: $e');
      return false;
    }
  }

  /// Trigger model retraining for current user
  Future<bool> retrainUserModel() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user found');
        return false;
      }

      final userId = UserIdGenerator.generateUserId(currentUser.username);
      final apiUrl = "$_baseApiUrl/retrain/$userId";

      print('🔄 Triggering model retraining for user: ${currentUser.username}');
      print('🆔 User ID: $userId');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Model retraining completed: ${result['message']}');
        return true;
      } else {
        print('❌ Retraining failed with status: ${response.statusCode}');
        print('📄 Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error triggering model retraining: $e');
      return false;
    }
  }

  /// Check if user model exists on the cloud
  Future<bool> checkUserModelExists() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final userId = UserIdGenerator.generateUserId(currentUser.username);
      final apiUrl = "$_baseApiUrl/predict/$userId";

      // Try a test prediction to see if model exists
      final testData = {
        "tap_duration": 0.15,
        "swipe_velocity": 0.35,
        "touch_pressure": 0.6,
        "tap_interval_avg": 0.25,
        "accel_variance": 0.2,
        "gyro_variance": 0.15,
        "battery_level": 0.75,
        "brightness_level": 0.5,
        "screen_on_time": 0.1,
        "time_of_day_sin": 0.5,
        "time_of_day_cos": 0.5,
        "wifi_id_hash": 0.5,
        "gps_latitude": 0.55,
        "gps_longitude": 0.31,
        "accel_variance_missing": 0,
        "gyro_variance_missing": 0,
        "charging_state": 1,
        "wifi_info_missing": 0,
        "gps_location_missing": 0,
        "day_of_week_mon": 0,
        "day_of_week_tue": 1,
        "day_of_week_wed": 0,
        "day_of_week_thu": 0,
        "day_of_week_fri": 0,
        "day_of_week_sat": 0,
        "day_of_week_sun": 0,
        "device_orientation": 0.8,
        "touch_area": 0.3,
        "touch_event_count": 5,
        "app_usage_time": 0.05,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(testData),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Model existence check failed: $e');
      return false;
    }
  }

  /// Convert behavioral data to CSV format for upload
  String _convertToCSV(List<dynamic> behaviorData) {
    if (behaviorData.isEmpty) return '';

    final buffer = StringBuffer();
    
    // Add CSV headers (30 features as expected by the model)
    final headers = [
      'tap_duration', 'swipe_velocity', 'touch_pressure', 'tap_interval_avg',
      'accel_variance', 'accel_variance_missing', 'gyro_variance', 'gyro_variance_missing',
      'battery_level', 'charging_state', 'brightness_level', 'screen_on_time',
      'wifi_id_hash', 'wifi_info_missing', 'gps_latitude', 'gps_longitude', 'gps_location_missing',
      'time_of_day_sin', 'time_of_day_cos', 'day_of_week_mon', 'day_of_week_tue',
      'day_of_week_wed', 'day_of_week_thu', 'day_of_week_fri', 'day_of_week_sat', 'day_of_week_sun',
      'device_orientation', 'touch_area', 'touch_event_count', 'app_usage_time'
    ];
    
    buffer.writeln(headers.join(','));

    // Add data rows
    for (final data in behaviorData) {
      final row = [
        data.tapDuration,
        data.swipeVelocity,
        data.touchPressure,
        data.tapIntervalAvg,
        data.accelVariance,
        data.accelVarianceMissing,
        data.gyroVariance,
        data.gyroVarianceMissing,
        data.batteryLevel,
        data.chargingState,
        data.brightnessLevel,
        data.screenOnTime,
        data.wifiIdHash,
        data.wifiInfoMissing,
        data.gpsLatitude,
        data.gpsLongitude,
        data.gpsLocationMissing,
        data.timeOfDaySin,
        data.timeOfDayCos,
        data.dayOfWeekMon,
        data.dayOfWeekTue,
        data.dayOfWeekWed,
        data.dayOfWeekThu,
        data.dayOfWeekFri,
        data.dayOfWeekSat,
        data.dayOfWeekSun,
        data.deviceOrientation,
        data.touchArea,
        data.touchEventCount,
        data.appUsageTime,
      ];
      
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  /// Initialize user model if it doesn't exist
  Future<bool> initializeUserModel() async {
    print('🔍 Checking if user model exists...');
    
    final modelExists = await checkUserModelExists();
    
    if (!modelExists) {
      print('📊 User model not found, uploading initial training data...');
      return await uploadInitialTrainingData();
    } else {
      print('✅ User model already exists');
      return true;
    }
  }

  /// Get service status for debugging
  Map<String, dynamic> getServiceStatus() {
    final currentUser = _authService.currentUser;
    return {
      'service_url': _baseApiUrl,
      'authenticated_user': currentUser?.username,
      'user_id': currentUser != null ? UserIdGenerator.generateUserId(currentUser.username) : null,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
