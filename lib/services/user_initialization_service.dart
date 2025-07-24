import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../utils/user_id_generator.dart';
import '../services/behavior_storage_service.dart';

class UserInitializationService {
  static final UserInitializationService _instance = UserInitializationService._internal();
  factory UserInitializationService() => _instance;
  UserInitializationService._internal();

  // EC2-hosted ML API endpoint
  static const String _baseApiUrl = "http://43.204.97.149";
  static const Duration _timeout = Duration(seconds: 30);
  
  final AuthService _authService = AuthService();
  String? _currentUserId;

  /// Get the current user ID (cached)
  String? get currentUserId => _currentUserId;

  /// Initialize user after successful login
  Future<bool> initializeUserAfterLogin() async {
    try {
      print('🚀 Starting user initialization after login...');
      
      // Step 1: Get current user and generate user ID
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user found');
        return false;
      }

      // Step 2: Hash username and take first 12 characters
      _currentUserId = UserIdGenerator.generateUserId(currentUser.username);
      print('👤 Username: "${currentUser.username}"');
      print('🆔 Generated User ID: $_currentUserId');
      print('🔍 Debug - Username length: ${currentUser.username.length}');
      print('🔍 Debug - Username bytes: ${currentUser.username.codeUnits}');

      // Step 3: Save user ID for future use
      await _saveUserId(_currentUserId!);

      // Step 4: Test if prediction API works with dummy data
      print('🧪 Testing prediction API with dummy data...');
      final predictionWorks = await _testPredictionApi(_currentUserId!);

      if (predictionWorks) {
        print('✅ Prediction API is working - user model exists');
        return true;
      } else {
        print('⚠️ Prediction API failed - need to initialize user model');
        
        // Step 5: If prediction fails, add new user with training data
        print('📊 Adding new user with initial training data...');
        final userAdded = await _addNewUserWithTrainingData(_currentUserId!);
        
        if (userAdded) {
          print('✅ User successfully initialized with training data');
          
          // Step 6: Test prediction API again
          final retestResult = await _testPredictionApi(_currentUserId!);
          if (retestResult) {
            print('✅ Prediction API now working after user initialization');
            return true;
          } else {
            print('⚠️ Prediction API still not working after initialization');
            return false;
          }
        } else {
          print('❌ Failed to add new user with training data');
          return false;
        }
      }
    } catch (e) {
      print('❌ Error during user initialization: $e');
      return false;
    }
  }

  /// Test prediction API with dummy data
  Future<bool> _testPredictionApi(String userId) async {
    try {
      final apiUrl = "$_baseApiUrl/predict/$userId";
      print('🌐 Testing URL: $apiUrl');

      // Dummy behavioral data for testing
      final dummyData = {
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
        "app_usage_time": 0.05
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(dummyData),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Prediction API response: $result');
        return true;
      } else {
        print('⚠️ Prediction API failed with status: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error testing prediction API: $e');
      return false;
    }
  }

  /// Add new user with initial training data
  Future<bool> _addNewUserWithTrainingData(String userId) async {
    try {
      final apiUrl = "$_baseApiUrl/add_user/$userId";
      print('🌐 Adding user at URL: $apiUrl');

      // Get all behavioral data from local storage
      final behaviorData = await BehaviorStorageService.getAllBehaviorData();
      
      if (behaviorData.isEmpty) {
        print('⚠️ No local behavioral data found - creating minimal training set');
        // Could create some default training data here if needed
        return false;
      }

      print('📊 Found ${behaviorData.length} behavioral data records for training');

      // Convert to CSV format
      final csvData = _convertToCSV(behaviorData);
      
      // Create multipart request for file upload
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      
      // Add CSV data as file
      request.files.add(
        http.MultipartFile.fromString(
          'file',
          csvData,
          filename: 'training_data.csv',
        ),
      );

      print('📤 Uploading ${csvData.length} characters of CSV training data...');

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ User added successfully');
        print('Response: ${response.body}');
        return true;
      } else {
        print('❌ Failed to add user. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error adding new user: $e');
      return false;
    }
  }

  /// Convert behavior data to CSV format
  String _convertToCSV(List<dynamic> behaviorData) {
    if (behaviorData.isEmpty) return '';

    final buffer = StringBuffer();
    
    // CSV header - all 30 features plus label
    buffer.writeln('tap_duration,swipe_velocity,touch_pressure,tap_interval_avg,accel_variance,gyro_variance,battery_level,brightness_level,screen_on_time,time_of_day_sin,time_of_day_cos,wifi_id_hash,gps_latitude,gps_longitude,accel_variance_missing,gyro_variance_missing,charging_state,wifi_info_missing,gps_location_missing,day_of_week_mon,day_of_week_tue,day_of_week_wed,day_of_week_thu,day_of_week_fri,day_of_week_sat,day_of_week_sun,device_orientation,touch_area,touch_event_count,app_usage_time,label');
    
    // Add each behavior data row
    for (final data in behaviorData) {
      final row = [
        data.tapDuration ?? 0.0,
        data.swipeVelocity ?? 0.0,
        data.touchPressure ?? 0.0,
        data.tapIntervalAvg ?? 0.0,
        data.accelVariance ?? 0.0,
        data.gyroVariance ?? 0.0,
        data.batteryLevel ?? 0.0,
        data.brightnessLevel ?? 0.0,
        data.screenOnTime ?? 0.0,
        data.timeOfDaySin ?? 0.0,
        data.timeOfDayCos ?? 0.0,
        data.wifiIdHash ?? 0.0,
        data.gpsLatitude ?? 0.0,
        data.gpsLongitude ?? 0.0,
        data.accelVarianceMissing ?? 0,
        data.gyroVarianceMissing ?? 0,
        data.chargingState ?? 0,
        data.wifiInfoMissing ?? 0,
        data.gpsLocationMissing ?? 0,
        data.dayOfWeekMon ?? 0,
        data.dayOfWeekTue ?? 0,
        data.dayOfWeekWed ?? 0,
        data.dayOfWeekThu ?? 0,
        data.dayOfWeekFri ?? 0,
        data.dayOfWeekSat ?? 0,
        data.dayOfWeekSun ?? 0,
        data.deviceOrientation ?? 0.0,
        data.touchArea ?? 0.0,
        data.touchEventCount ?? 0,
        data.appUsageTime ?? 0.0,
        'normal' // Default label for training
      ];
      buffer.writeln(row.join(','));
    }
    
    return buffer.toString();
  }

  /// Save user ID to local storage
  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', userId);
    print('💾 User ID saved to local storage: $userId');
  }

  /// Load user ID from local storage
  Future<String?> loadSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');
    if (userId != null) {
      _currentUserId = userId;
      print('📱 Loaded user ID from storage: $userId');
    }
    return userId;
  }

  /// Clear saved user ID (on logout)
  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    _currentUserId = null;
    print('🗑️ User ID cleared from storage');
  }

  /// Get service status for debugging
  Map<String, dynamic> getServiceStatus() {
    final currentUser = _authService.currentUser;
    return {
      'service_url': _baseApiUrl,
      'authenticated_user': currentUser?.username,
      'current_user_id': _currentUserId,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Debug method to test a specific user ID
  Future<bool> testSpecificUserId(String userId) async {
    print('🧪 Testing specific user ID: $userId');
    return await _testPredictionApi(userId);
  }
}
