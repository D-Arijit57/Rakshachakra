// RAKSHA CONTINUOUS AUTHENTICATION SYSTEM - DEMONSTRATION SCRIPT
// This file shows how to use the complete ML-powered behavioral authentication system

import '../models/behavior_data.dart';
import '../services/behavior_storage_service.dart';
import '../services/ml_model_service.dart';

/// Complete demonstration of the Raksha Continuous Authentication System
/// 
/// Features demonstrated:
/// 1. Behavioral data collection (30 features)
/// 2. Data normalization and storage
/// 3. ML model training with synthetic data
/// 4. Risk assessment and scoring
/// 5. CSV export for analysis
class RakshaDemoService {
  static final RakshaDemoService _instance = RakshaDemoService._internal();
  factory RakshaDemoService() => _instance;
  RakshaDemoService._internal();

  final MLModelService _mlService = MLModelService();

  /// Complete demo workflow
  Future<void> runCompleteDemo() async {
    print('🚀 RAKSHA CONTINUOUS AUTHENTICATION DEMO');
    print('=' * 50);
    
    // Step 1: Initialize ML Model
    print('\n📊 Step 1: Initializing ML Model...');
    await _mlService.initializeModel();
    print('✅ ML Model trained with 100 synthetic sessions');
    
    // Step 2: Demonstrate data collection
    print('\n📱 Step 2: Collecting Behavioral Data...');
    final sessions = await _collectDemoSessions();
    print('✅ Collected ${sessions.length} behavioral sessions');
    
    // Step 3: Analyze sessions with ML
    print('\n🧠 Step 3: ML Risk Analysis...');
    final riskResults = await _analyzeSessionRisks(sessions);
    print('✅ Analyzed ${riskResults.length} sessions for fraud risk');
    
    // Step 4: Show results
    print('\n📈 Step 4: Results Summary');
    _displayResults(sessions, riskResults);
    
    // Step 5: Export data
    print('\n💾 Step 5: Data Export');
    await _exportDemo(sessions);
    
    print('\n🎉 DEMO COMPLETE - Raksha System Ready!');
    print('=' * 50);
  }

  /// Collect sample behavioral data sessions
  Future<List<BehaviorData>> _collectDemoSessions() async {
    final sessions = <BehaviorData>[];
    
    // Simulate 5 normal sessions
    for (int i = 0; i < 5; i++) {
      final session = await _generateNormalSession(i);
      sessions.add(session);
      await BehaviorStorageService.saveBehaviorData(session);
      print('  📊 Normal session ${i + 1} collected');
    }
    
    // Simulate 2 suspicious sessions
    for (int i = 0; i < 2; i++) {
      final session = await _generateSuspiciousSession(i + 5);
      sessions.add(session);
      await BehaviorStorageService.saveBehaviorData(session);
      print('  ⚠️  Suspicious session ${i + 6} collected');
    }
    
    return sessions;
  }

  /// Generate a normal user session
  Future<BehaviorData> _generateNormalSession(int sessionId) async {
    // Simulate realistic normal behavior
    return BehaviorData(
      // Touch patterns - consistent and natural
      tapDuration: 0.12 + (sessionId * 0.01), // 12-16% normalized
      swipeVelocity: 0.30 + (sessionId * 0.02), // 30-38% normalized
      touchPressure: 0.55 + (sessionId * 0.05), // 55-75% normalized
      tapIntervalAvg: 0.20 + (sessionId * 0.01), // 20-24% normalized
      
      // Motion - stable device handling
      accelVariance: 0.15 + (sessionId * 0.02), // Low variance
      accelVarianceMissing: 0,
      gyroVariance: 0.10 + (sessionId * 0.01), // Low variance
      gyroVarianceMissing: 0,
      
      // Device context - normal usage
      batteryLevel: 0.70 - (sessionId * 0.05), // Decreasing battery
      chargingState: sessionId % 2, // Sometimes charging
      brightnessLevel: 0.40 + (sessionId * 0.02), // Consistent brightness
      screenOnTime: 0.08 + (sessionId * 0.01), // Short screen time
      
      // Network - consistent location
      wifiIdHash: 0.52 + (sessionId * 0.001), // Same WiFi network
      wifiInfoMissing: 0,
      gpsLatitude: 0.55 + (sessionId * 0.0001), // Consistent location
      gpsLongitude: 0.31 + (sessionId * 0.0001),
      gpsLocationMissing: 0,
      
      // Time patterns - normal business hours
      timeOfDaySin: 0.5, // Midday usage
      timeOfDayCos: 0.5,
      dayOfWeekMon: 1, // Monday usage
      dayOfWeekTue: 0,
      dayOfWeekWed: 0,
      dayOfWeekThu: 0,
      dayOfWeekFri: 0,
      dayOfWeekSat: 0,
      dayOfWeekSun: 0,
      
      // Device usage - consistent
      deviceOrientation: 0.80 + (sessionId * 0.01), // Portrait mode
      touchArea: 0.25 + (sessionId * 0.01), // Consistent finger size
      touchEventCount: 0.35 + (sessionId * 0.02), // Normal activity
      appUsageTime: 0.03 + (sessionId * 0.005), // Short sessions
      
      // Metadata
      timestamp: DateTime.now().subtract(Duration(hours: sessionId)),
      userId: 'demo_user_normal',
      sessionId: sessionId,
    );
  }

  /// Generate a suspicious user session
  Future<BehaviorData> _generateSuspiciousSession(int sessionId) async {
    // Simulate suspicious/anomalous behavior
    return BehaviorData(
      // Touch patterns - very different from normal
      tapDuration: 0.85, // Very slow taps (suspicious)
      swipeVelocity: 0.05, // Very slow swipes (suspicious)
      touchPressure: 0.95, // Very high pressure (suspicious)
      tapIntervalAvg: 0.90, // Very long intervals (suspicious)
      
      // Motion - high variance (shaky hands/unfamiliar device)
      accelVariance: 0.85, // High motion variance
      accelVarianceMissing: 0,
      gyroVariance: 0.90, // High rotation variance
      gyroVarianceMissing: 0,
      
      // Device context - unusual
      batteryLevel: 0.95, // Full battery (unusual timing)
      chargingState: 1, // Charging (unusual for this pattern)
      brightnessLevel: 0.90, // Very bright (unusual)
      screenOnTime: 0.85, // Very long screen time (suspicious)
      
      // Network - different location
      wifiIdHash: 0.90, // Different WiFi network (red flag)
      wifiInfoMissing: 0,
      gpsLatitude: 0.90, // Very different location (red flag)
      gpsLongitude: 0.85,
      gpsLocationMissing: 0,
      
      // Time patterns - unusual time
      timeOfDaySin: -0.8, // Late night usage (suspicious)
      timeOfDayCos: -0.6,
      dayOfWeekMon: 0,
      dayOfWeekTue: 0,
      dayOfWeekWed: 0,
      dayOfWeekThu: 0,
      dayOfWeekFri: 0,
      dayOfWeekSat: 1, // Weekend usage (unusual)
      dayOfWeekSun: 0,
      
      // Device usage - very different
      deviceOrientation: 0.10, // Landscape mode (unusual)
      touchArea: 0.90, // Very large touch area (different finger)
      touchEventCount: 0.95, // Very high activity (suspicious)
      appUsageTime: 0.90, // Very long usage (suspicious)
      
      // Metadata
      timestamp: DateTime.now().subtract(Duration(hours: sessionId)),
      userId: 'demo_user_suspicious',
      sessionId: sessionId,
    );
  }

  /// Analyze session risks using ML
  Future<List<RiskAssessment>> _analyzeSessionRisks(List<BehaviorData> sessions) async {
    final riskResults = <RiskAssessment>[];
    
    for (final session in sessions) {
      final riskAssessment = await _mlService.calculateRiskScore(session);
      riskResults.add(riskAssessment);
      
      final riskIcon = _getRiskIcon(riskAssessment.riskLevel);
      print('  $riskIcon Session ${session.sessionId}: ${riskAssessment.riskLevel.name.toUpperCase()} risk (${riskAssessment.riskPercentage})');
    }
    
    return riskResults;
  }

  /// Display comprehensive results
  void _displayResults(List<BehaviorData> sessions, List<RiskAssessment> risks) {
    print('\n📊 BEHAVIORAL ANALYSIS RESULTS:');
    print('-' * 30);
    
    final lowRisk = risks.where((r) => r.riskLevel == RiskLevel.low).length;
    final mediumRisk = risks.where((r) => r.riskLevel == RiskLevel.medium).length;
    final highRisk = risks.where((r) => r.riskLevel == RiskLevel.high).length;
    
    print('🟢 Low Risk Sessions: $lowRisk');
    print('🟡 Medium Risk Sessions: $mediumRisk');
    print('🔴 High Risk Sessions: $highRisk');
    print('📈 Total Sessions Analyzed: ${sessions.length}');
    
    print('\n🔍 DETAILED RISK BREAKDOWN:');
    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final risk = risks[i];
      
      print('\nSession ${session.sessionId} (${session.userId}):');
      print('  Risk Level: ${risk.riskLevel.name.toUpperCase()}');
      print('  Risk Score: ${risk.riskPercentage}');
      print('  Touch Anomaly: ${(risk.touchAnomalyScore * 100).toStringAsFixed(1)}%');
      print('  Motion Anomaly: ${(risk.motionAnomalyScore * 100).toStringAsFixed(1)}%');
      print('  Context Anomaly: ${(risk.contextAnomalyScore * 100).toStringAsFixed(1)}%');
      print('  Location Anomaly: ${(risk.locationAnomalyScore * 100).toStringAsFixed(1)}%');
      print('  Time Anomaly: ${(risk.timeAnomalyScore * 100).toStringAsFixed(1)}%');
    }
  }

  /// Demonstrate CSV export functionality
  Future<void> _exportDemo(List<BehaviorData> sessions) async {
    print('📄 CSV Export Format:');
    print('Headers: ${BehaviorData.csvHeaders.join(', ')}');
    print('Features: 30 normalized behavioral metrics');
    print('Format: Ready for ML analysis and fraud detection');
    
    print('\n📊 Sample CSV Data:');
    for (int i = 0; i < 2 && i < sessions.length; i++) {
      final csvRow = sessions[i].toCsvRow();
      print('Session ${i + 1}: ${csvRow.take(5).join(', ')}... (30 features total)');
    }
  }

  String _getRiskIcon(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return '🟢';
      case RiskLevel.medium:
        return '🟡';
      case RiskLevel.high:
        return '🔴';
    }
  }
}

/// Key Features Demonstrated:
/// 
/// 1. **Comprehensive Data Collection**
///    - 30 behavioral features across 5 categories
///    - Touch patterns, motion, device context, location, time
///    - Real-time normalization and privacy protection
/// 
/// 2. **Advanced ML Pipeline**
///    - Synthetic training data generation
///    - Multi-feature anomaly detection
///    - Weighted risk scoring algorithm
///    - Real-time risk assessment
/// 
/// 3. **Fraud Detection Capabilities**
///    - Identifies suspicious behavioral patterns
///    - Distinguishes normal vs. anomalous sessions
///    - Provides detailed risk breakdowns
///    - Enables proactive security measures
/// 
/// 4. **Production-Ready Architecture**
///    - Modular service architecture
///    - Efficient data processing
///    - Local storage with Hive database
///    - CSV export for compliance/analysis
/// 
/// 5. **Hackathon Innovation**
///    - Most comprehensive behavioral biometrics (30 features)
///    - Custom ML algorithm optimized for mobile banking
///    - Privacy-first design with data hashing
///    - Seamless integration with existing banking app
/// 
/// Usage in Banking App:
/// ```dart
/// // Initialize and run the complete demo
/// final demo = RakshaDemoService();
/// await demo.runCompleteDemo();
/// 
/// // In production, the system runs automatically:
/// // 1. Collects behavioral data during normal app usage
/// // 2. Continuously assesses fraud risk
/// // 3. Alerts security team of suspicious sessions
/// // 4. Provides audit trail for compliance
/// ```
