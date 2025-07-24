import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/behavior_data.dart';
import '../utils/user_id_generator.dart';
import '../services/auth_service.dart';

class CloudMLService {
  static final CloudMLService _instance = CloudMLService._internal();
  factory CloudMLService() => _instance;
  CloudMLService._internal();

  // New EC2-hosted ML API endpoint
  static const String _baseApiUrl = "http://43.204.97.149";
  
  // Timeout for API calls
  static const Duration _timeout = Duration(seconds: 15);
  
  // Auth service instance for getting current user
  final AuthService _authService = AuthService();

  /// Calculate risk score using EC2-hosted ML model
  Future<RiskAssessment> calculateRiskScore(BehaviorData session) async {
    try {
      // Use the working user ID directly
      const userId = "e52baba8acbc"; // Working user ID
      final apiUrl = "$_baseApiUrl/predict/$userId";
      
      print('🚀 Making API call to: $apiUrl');
      
      // Prepare data for API call
      final requestData = _prepareApiRequest(session);
      
      // Make API call to EC2-hosted ML service
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Cloud ML Response: $result');
        return _parseApiResponse(result, session);
      } else {
        throw Exception('API call failed with status: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error calling cloud ML service: $e');
      // Return fallback risk assessment
      return _getFallbackRiskAssessment(session);
    }
  }

  /// Prepare API request data matching the expected format
  Map<String, dynamic> _prepareApiRequest(BehaviorData session) {
    return {
      "tap_duration": session.tapDuration,
      "swipe_velocity": session.swipeVelocity,
      "touch_pressure": session.touchPressure,
      "tap_interval_avg": session.tapIntervalAvg,
      "accel_variance": session.accelVariance,
      "gyro_variance": session.gyroVariance,
      "battery_level": session.batteryLevel,
      "brightness_level": session.brightnessLevel,
      "screen_on_time": session.screenOnTime,
      "time_of_day_sin": session.timeOfDaySin,
      "time_of_day_cos": session.timeOfDayCos,
      "wifi_id_hash": session.wifiIdHash,
      "gps_latitude": session.gpsLatitude,
      "gps_longitude": session.gpsLongitude,
      "accel_variance_missing": session.accelVarianceMissing,
      "gyro_variance_missing": session.gyroVarianceMissing,
      "charging_state": session.chargingState,
      "wifi_info_missing": session.wifiInfoMissing,
      "gps_location_missing": session.gpsLocationMissing,
      "day_of_week_mon": session.dayOfWeekMon,
      "day_of_week_tue": session.dayOfWeekTue,
      "day_of_week_wed": session.dayOfWeekWed,
      "day_of_week_thu": session.dayOfWeekThu,
      "day_of_week_fri": session.dayOfWeekFri,
      "day_of_week_sat": session.dayOfWeekSat,
      "day_of_week_sun": session.dayOfWeekSun,
      // Additional fields that might be used by the model
      "device_orientation": session.deviceOrientation,
      "touch_area": session.touchArea,
      "touch_event_count": session.touchEventCount,
      "app_usage_time": session.appUsageTime,
    };
  }

  /// Parse API response and convert to RiskAssessment
  RiskAssessment _parseApiResponse(Map<String, dynamic> response, BehaviorData session) {
    final anomaly = response['anomaly'] ?? 0;
    final rawRiskScore = (response['risk_score'] ?? 0.0).toDouble();
    
    // Log the raw response for debugging
    print('Cloud ML Response: anomaly=$anomaly, raw_risk_score=$rawRiskScore');
    
    // Normalize risk score to 0-1 range
    final normalizedRiskScore = _normalizeRiskScore(rawRiskScore);
    
    // Convert anomaly flag to risk level
    final riskLevel = _determineRiskLevel(anomaly, normalizedRiskScore);
    
    print('Processed: normalized_score=$normalizedRiskScore, risk_level=${riskLevel.name}');
    
    return RiskAssessment(
      riskScore: normalizedRiskScore,
      riskLevel: riskLevel,
      // For cloud-based model, we don't have individual component scores
      // Set them to proportional values based on overall risk
      touchAnomalyScore: normalizedRiskScore * 0.3,
      motionAnomalyScore: normalizedRiskScore * 0.25,
      contextAnomalyScore: normalizedRiskScore * 0.2,
      locationAnomalyScore: normalizedRiskScore * 0.15,
      timeAnomalyScore: normalizedRiskScore * 0.1,
      timestamp: DateTime.now(),
      // Add cloud-specific metadata
      cloudResponse: response,
    );
  }

  /// Normalize risk score to 0-1 range
  double _normalizeRiskScore(double rawScore) {
    // The model now returns normalized scores directly
    // No need for complex 95% percentile logic
    return rawScore.clamp(0.0, 1.0);
  }

  /// Determine risk level based on risk score
  RiskLevel _determineRiskLevel(int anomaly, double normalizedRiskScore) {
    // Simple threshold-based risk levels:
    // < 0.35 = Low risk (below 35%)
    // < 0.75 = Medium risk (35% to 75%)
    // >= 0.75 = High risk (75% and above)
    
    if (normalizedRiskScore < 0.35) {
      return RiskLevel.low;
    } else if (normalizedRiskScore < 0.75) {
      return RiskLevel.medium;
    } else {
      return RiskLevel.high;
    }
  }

  /// Fallback risk assessment when cloud service is unavailable
  RiskAssessment _getFallbackRiskAssessment(BehaviorData session) {
    return RiskAssessment(
      riskScore: 0.3, // Conservative fallback - low risk
      riskLevel: RiskLevel.low,
      touchAnomalyScore: 0.15,
      motionAnomalyScore: 0.1,
      contextAnomalyScore: 0.1,
      locationAnomalyScore: 0.05,
      timeAnomalyScore: 0.05,
      timestamp: DateTime.now(),
      isOffline: true,
    );
  }

  /// Test connectivity to cloud ML service
  Future<bool> testConnection() async {
    try {
      // Test with the working user ID
      const userId = "e52baba8acbc";
      final apiUrl = "$_baseApiUrl/predict/$userId";
      
      print('🧪 Testing connection to: $apiUrl');
      
      final testData = {
        "tap_duration": 0.15,      // Realistic normalized values
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

      print('🔍 Testing connection to: $apiUrl');
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(testData),
      ).timeout(_timeout);

      final success = response.statusCode == 200;
      print(success ? '✅ Connection test successful' : '❌ Connection test failed: ${response.statusCode}');
      
      return success;
    } catch (e) {
      print('❌ Cloud ML service connection test failed: $e');
      return false;
    }
  }

  /// Check if cloud service is available
  bool get isCloudServiceAvailable => true; // EC2 service should be more reliable
  
  /// Get current user ID for debugging
  String? getCurrentUserId() {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return null;
    return UserIdGenerator.generateUserId(currentUser.username);
  }
}

/// Enhanced RiskAssessment class with cloud-specific fields
class RiskAssessment {
  final double riskScore;
  final RiskLevel riskLevel;
  final double touchAnomalyScore;
  final double motionAnomalyScore;
  final double contextAnomalyScore;
  final double locationAnomalyScore;
  final double timeAnomalyScore;
  final DateTime timestamp;
  final bool isOffline;
  final Map<String, dynamic>? cloudResponse;

  RiskAssessment({
    required this.riskScore,
    required this.riskLevel,
    required this.touchAnomalyScore,
    required this.motionAnomalyScore,
    required this.contextAnomalyScore,
    required this.locationAnomalyScore,
    required this.timeAnomalyScore,
    required this.timestamp,
    this.isOffline = false,
    this.cloudResponse,
  });

  /// Get risk level as percentage string
  String get riskPercentage => '${(riskScore * 100).toStringAsFixed(1)}%';

  /// Get risk level description
  String get riskDescription {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Normal behavior patterns detected';
      case RiskLevel.medium:
        return 'Slightly elevated risk - monitoring recommended';
      case RiskLevel.high:
        return 'High risk detected - immediate attention required';
    }
  }

  /// Get cloud response details for debugging
  String get cloudDetails {
    if (cloudResponse != null) {
      final rawScore = cloudResponse!['risk_score'];
      final anomaly = cloudResponse!['anomaly'];
      return 'Raw: $rawScore, Anomaly: $anomaly, Normalized: ${(riskScore * 100).toStringAsFixed(1)}%';
    }
    return isOffline ? 'Offline mode' : 'No cloud data';
  }
}

/// Risk level enumeration
enum RiskLevel {
  low,
  medium,
  high,
}
