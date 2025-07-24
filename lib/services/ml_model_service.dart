import 'dart:math';
import '../models/behavior_data.dart';

class MLModelService {
  static final MLModelService _instance = MLModelService._internal();
  factory MLModelService() => _instance;
  MLModelService._internal();

  // User baseline profile (learned from normal behavior)
  Map<String, UserProfile> _userProfiles = {};
  bool _isModelTrained = false;

  // Anomaly detection thresholds
  static const double HIGH_RISK_THRESHOLD = 0.7;
  static const double MEDIUM_RISK_THRESHOLD = 0.4;

  /// Initialize and train the model with synthetic data
  Future<void> initializeModel() async {
    if (_isModelTrained) return;
    
    print('🤖 Initializing ML Model...');
    
    // Generate synthetic training data for baseline users
    await _generateSyntheticTrainingData();
    
    _isModelTrained = true;
    print('✅ ML Model trained and ready!');
  }

  /// Generate synthetic behavioral data for training
  Future<void> _generateSyntheticTrainingData() async {
    final random = Random();
    
    // Create baseline profile for "normal" user behavior
    final normalProfile = UserProfile();
    
    // Generate 100 synthetic normal sessions
    for (int i = 0; i < 100; i++) {
      final syntheticData = _generateNormalBehaviorSession(random);
      normalProfile.addTrainingSession(syntheticData);
    }
    
    // Store the baseline profile
    _userProfiles['baseline'] = normalProfile;
    
    print('📊 Generated 100 synthetic training sessions');
  }

  /// Generate a synthetic "normal" behavior session
  BehaviorData _generateNormalBehaviorSession(Random random) {
    // Normal user behavioral patterns with realistic variance
    return BehaviorData(
      // Touch patterns (consistent but with natural variation)
      tapDuration: _generateNormalValue(0.15, 0.05, random),          // 15% ± 5%
      swipeVelocity: _generateNormalValue(0.35, 0.1, random),         // 35% ± 10%
      touchPressure: _generateNormalValue(0.6, 0.15, random),         // 60% ± 15%
      tapIntervalAvg: _generateNormalValue(0.25, 0.08, random),       // 25% ± 8%
      
      // Motion patterns (stable device handling)
      accelVariance: _generateNormalValue(0.2, 0.1, random),          // 20% ± 10%
      accelVarianceMissing: 0,
      gyroVariance: _generateNormalValue(0.15, 0.08, random),         // 15% ± 8%
      gyroVarianceMissing: 0,
      
      // Device context (normal usage)
      batteryLevel: _generateNormalValue(0.6, 0.3, random),           // 60% ± 30%
      chargingState: random.nextBool() ? 1 : 0,
      brightnessLevel: _generateNormalValue(0.4, 0.2, random),        // 40% ± 20%
      screenOnTime: _generateNormalValue(0.1, 0.05, random),          // 10% ± 5%
      
      // Network/Location (consistent location)
      wifiIdHash: _generateNormalValue(0.5, 0.1, random),             // Consistent WiFi
      wifiInfoMissing: 0,
      gpsLatitude: _generateNormalValue(0.55, 0.02, random),          // Consistent location
      gpsLongitude: _generateNormalValue(0.31, 0.02, random),
      gpsLocationMissing: 0,
      
      // Time patterns (normal usage hours)
      timeOfDaySin: sin(2 * pi * (8 + random.nextDouble() * 12) / 24), // 8AM-8PM
      timeOfDayCos: cos(2 * pi * (8 + random.nextDouble() * 12) / 24),
      
      // Weekday patterns (weekday usage)
      dayOfWeekMon: random.nextDouble() < 0.2 ? 1 : 0,
      dayOfWeekTue: random.nextDouble() < 0.2 ? 1 : 0,
      dayOfWeekWed: random.nextDouble() < 0.2 ? 1 : 0,
      dayOfWeekThu: random.nextDouble() < 0.2 ? 1 : 0,
      dayOfWeekFri: random.nextDouble() < 0.2 ? 1 : 0,
      dayOfWeekSat: random.nextDouble() < 0.1 ? 1 : 0,
      dayOfWeekSun: random.nextDouble() < 0.1 ? 1 : 0,
      
      // Device usage patterns
      deviceOrientation: _generateNormalValue(0.8, 0.1, random),      // Consistent holding
      touchArea: _generateNormalValue(0.3, 0.1, random),              // Consistent finger size
      touchEventCount: _generateNormalValue(0.4, 0.2, random),        // Normal activity
      appUsageTime: _generateNormalValue(0.05, 0.02, random),         // Short sessions
      
      // Metadata
      timestamp: DateTime.now(),
      userId: 'synthetic_user',
      sessionId: Random().nextInt(1000000),
    );
  }

  /// Generate value with normal distribution
  double _generateNormalValue(double mean, double stdDev, Random random) {
    // Box-Muller transform for normal distribution
    final u1 = random.nextDouble();
    final u2 = random.nextDouble();
    final z0 = sqrt(-2 * log(u1)) * cos(2 * pi * u2);
    return (mean + stdDev * z0).clamp(0.0, 1.0);
  }

  /// Calculate risk score for a given session
  Future<RiskAssessment> calculateRiskScore(BehaviorData session) async {
    if (!_isModelTrained) {
      await initializeModel();
    }

    final baseline = _userProfiles['baseline']!;
    
    // Calculate anomaly score using multiple metrics
    final touchAnomalyScore = _calculateTouchAnomalyScore(session, baseline);
    final motionAnomalyScore = _calculateMotionAnomalyScore(session, baseline);
    final contextAnomalyScore = _calculateContextAnomalyScore(session, baseline);
    final locationAnomalyScore = _calculateLocationAnomalyScore(session, baseline);
    final timeAnomalyScore = _calculateTimeAnomalyScore(session, baseline);
    
    // Weighted combination of anomaly scores
    final overallAnomalyScore = (
      touchAnomalyScore * 0.3 +        // 30% weight for touch patterns
      motionAnomalyScore * 0.25 +      // 25% weight for motion patterns  
      contextAnomalyScore * 0.2 +      // 20% weight for device context
      locationAnomalyScore * 0.15 +    // 15% weight for location
      timeAnomalyScore * 0.1           // 10% weight for time patterns
    );

    // Convert anomaly score to risk level
    final riskLevel = _determineRiskLevel(overallAnomalyScore);
    
    return RiskAssessment(
      riskScore: overallAnomalyScore,
      riskLevel: riskLevel,
      touchAnomalyScore: touchAnomalyScore,
      motionAnomalyScore: motionAnomalyScore,
      contextAnomalyScore: contextAnomalyScore,
      locationAnomalyScore: locationAnomalyScore,
      timeAnomalyScore: timeAnomalyScore,
      timestamp: DateTime.now(),
    );
  }

  /// Calculate touch pattern anomaly score
  double _calculateTouchAnomalyScore(BehaviorData session, UserProfile baseline) {
    final touchFeatures = [
      session.tapDuration,
      session.swipeVelocity, 
      session.touchPressure,
      session.tapIntervalAvg,
      session.touchArea,
      session.touchEventCount
    ];
    
    final baselineTouch = [
      baseline.avgTapDuration,
      baseline.avgSwipeVelocity,
      baseline.avgTouchPressure,
      baseline.avgTapInterval,
      baseline.avgTouchArea,
      baseline.avgTouchEventCount
    ];
    
    return _calculateEuclideanDistance(touchFeatures, baselineTouch);
  }

  /// Calculate motion pattern anomaly score
  double _calculateMotionAnomalyScore(BehaviorData session, UserProfile baseline) {
    final motionFeatures = [
      session.accelVariance,
      session.gyroVariance,
      session.deviceOrientation
    ];
    
    final baselineMotion = [
      baseline.avgAccelVariance,
      baseline.avgGyroVariance,
      baseline.avgDeviceOrientation
    ];
    
    return _calculateEuclideanDistance(motionFeatures, baselineMotion);
  }

  /// Calculate device context anomaly score
  double _calculateContextAnomalyScore(BehaviorData session, UserProfile baseline) {
    final contextFeatures = [
      session.batteryLevel,
      session.brightnessLevel,
      session.screenOnTime,
      session.appUsageTime
    ];
    
    final baselineContext = [
      baseline.avgBatteryLevel,
      baseline.avgBrightnessLevel,
      baseline.avgScreenOnTime,
      baseline.avgAppUsageTime
    ];
    
    return _calculateEuclideanDistance(contextFeatures, baselineContext);
  }

  /// Calculate location anomaly score
  double _calculateLocationAnomalyScore(BehaviorData session, UserProfile baseline) {
    if (session.gpsLocationMissing == 1 || baseline.avgGpsLatitude == 0) {
      return 0.0; // No location data available
    }
    
    final locationFeatures = [
      session.gpsLatitude,
      session.gpsLongitude,
      session.wifiIdHash
    ];
    
    final baselineLocation = [
      baseline.avgGpsLatitude,
      baseline.avgGpsLongitude,
      baseline.avgWifiIdHash
    ];
    
    return _calculateEuclideanDistance(locationFeatures, baselineLocation);
  }

  /// Calculate time pattern anomaly score
  double _calculateTimeAnomalyScore(BehaviorData session, UserProfile baseline) {
    final timeFeatures = [
      session.timeOfDaySin,
      session.timeOfDayCos,
      session.dayOfWeekMon.toDouble(),
      session.dayOfWeekTue.toDouble(),
      session.dayOfWeekWed.toDouble(),
      session.dayOfWeekThu.toDouble(),
      session.dayOfWeekFri.toDouble()
    ];
    
    final baselineTime = [
      baseline.avgTimeOfDaySin,
      baseline.avgTimeOfDayCos,
      baseline.avgWeekdayUsage,
      baseline.avgWeekdayUsage,
      baseline.avgWeekdayUsage,
      baseline.avgWeekdayUsage,
      baseline.avgWeekdayUsage
    ];
    
    return _calculateEuclideanDistance(timeFeatures, baselineTime);
  }

  /// Calculate Euclidean distance between two feature vectors
  double _calculateEuclideanDistance(List<double> features1, List<double> features2) {
    if (features1.length != features2.length) return 1.0;
    
    double sumSquares = 0.0;
    for (int i = 0; i < features1.length; i++) {
      final diff = features1[i] - features2[i];
      sumSquares += diff * diff;
    }
    
    final distance = sqrt(sumSquares) / sqrt(features1.length);
    return distance.clamp(0.0, 1.0);
  }

  /// Determine risk level based on anomaly score
  RiskLevel _determineRiskLevel(double anomalyScore) {
    if (anomalyScore >= HIGH_RISK_THRESHOLD) {
      return RiskLevel.high;
    } else if (anomalyScore >= MEDIUM_RISK_THRESHOLD) {
      return RiskLevel.medium;
    } else {
      return RiskLevel.low;
    }
  }

  /// Get current model status
  bool get isModelTrained => _isModelTrained;
}

/// User behavioral profile for baseline comparison
class UserProfile {
  double avgTapDuration = 0.0;
  double avgSwipeVelocity = 0.0;
  double avgTouchPressure = 0.0;
  double avgTapInterval = 0.0;
  double avgAccelVariance = 0.0;
  double avgGyroVariance = 0.0;
  double avgBatteryLevel = 0.0;
  double avgBrightnessLevel = 0.0;
  double avgScreenOnTime = 0.0;
  double avgWifiIdHash = 0.0;
  double avgGpsLatitude = 0.0;
  double avgGpsLongitude = 0.0;
  double avgTimeOfDaySin = 0.0;
  double avgTimeOfDayCos = 0.0;
  double avgWeekdayUsage = 0.0;
  double avgDeviceOrientation = 0.0;
  double avgTouchArea = 0.0;
  double avgTouchEventCount = 0.0;
  double avgAppUsageTime = 0.0;
  
  int sessionCount = 0;

  void addTrainingSession(BehaviorData session) {
    sessionCount++;
    
    // Update running averages
    avgTapDuration = _updateAverage(avgTapDuration, session.tapDuration, sessionCount);
    avgSwipeVelocity = _updateAverage(avgSwipeVelocity, session.swipeVelocity, sessionCount);
    avgTouchPressure = _updateAverage(avgTouchPressure, session.touchPressure, sessionCount);
    avgTapInterval = _updateAverage(avgTapInterval, session.tapIntervalAvg, sessionCount);
    avgAccelVariance = _updateAverage(avgAccelVariance, session.accelVariance, sessionCount);
    avgGyroVariance = _updateAverage(avgGyroVariance, session.gyroVariance, sessionCount);
    avgBatteryLevel = _updateAverage(avgBatteryLevel, session.batteryLevel, sessionCount);
    avgBrightnessLevel = _updateAverage(avgBrightnessLevel, session.brightnessLevel, sessionCount);
    avgScreenOnTime = _updateAverage(avgScreenOnTime, session.screenOnTime, sessionCount);
    avgWifiIdHash = _updateAverage(avgWifiIdHash, session.wifiIdHash, sessionCount);
    avgGpsLatitude = _updateAverage(avgGpsLatitude, session.gpsLatitude, sessionCount);
    avgGpsLongitude = _updateAverage(avgGpsLongitude, session.gpsLongitude, sessionCount);
    avgTimeOfDaySin = _updateAverage(avgTimeOfDaySin, session.timeOfDaySin, sessionCount);
    avgTimeOfDayCos = _updateAverage(avgTimeOfDayCos, session.timeOfDayCos, sessionCount);
    avgDeviceOrientation = _updateAverage(avgDeviceOrientation, session.deviceOrientation, sessionCount);
    avgTouchArea = _updateAverage(avgTouchArea, session.touchArea, sessionCount);
    avgTouchEventCount = _updateAverage(avgTouchEventCount, session.touchEventCount, sessionCount);
    avgAppUsageTime = _updateAverage(avgAppUsageTime, session.appUsageTime, sessionCount);
    
    // Calculate weekday usage
    final weekdayUsage = (session.dayOfWeekMon + session.dayOfWeekTue + 
                         session.dayOfWeekWed + session.dayOfWeekThu + session.dayOfWeekFri).toDouble();
    avgWeekdayUsage = _updateAverage(avgWeekdayUsage, weekdayUsage, sessionCount);
  }

  double _updateAverage(double currentAvg, double newValue, int count) {
    return (currentAvg * (count - 1) + newValue) / count;
  }
}

/// Risk assessment result
class RiskAssessment {
  final double riskScore;
  final RiskLevel riskLevel;
  final double touchAnomalyScore;
  final double motionAnomalyScore;
  final double contextAnomalyScore;
  final double locationAnomalyScore;
  final double timeAnomalyScore;
  final DateTime timestamp;

  RiskAssessment({
    required this.riskScore,
    required this.riskLevel,
    required this.touchAnomalyScore,
    required this.motionAnomalyScore,
    required this.contextAnomalyScore,
    required this.locationAnomalyScore,
    required this.timeAnomalyScore,
    required this.timestamp,
  });

  String get riskPercentage => '${(riskScore * 100).toStringAsFixed(1)}%';
  
  String get riskDescription {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Normal behavior pattern detected';
      case RiskLevel.medium:
        return 'Slightly suspicious activity detected';
      case RiskLevel.high:
        return 'Highly suspicious activity detected';
    }
  }
}

/// Risk level enumeration
enum RiskLevel {
  low,
  medium,
  high
}
