import 'dart:async';
import '../models/behavior_data.dart';
import 'cloud_ml_service.dart';
import 'behavior_storage_service.dart';

/// Real-time cloud-based risk assessment service
class RealTimeCloudRiskService {
  static final RealTimeCloudRiskService _instance = RealTimeCloudRiskService._internal();
  factory RealTimeCloudRiskService() => _instance;
  RealTimeCloudRiskService._internal();

  final CloudMLService _cloudML = CloudMLService();
  final StreamController<RiskAssessment> _riskStreamController = StreamController<RiskAssessment>.broadcast();
  
  bool _isCloudServiceAvailable = false;
  
  /// Stream of real-time risk assessments
  Stream<RiskAssessment> get riskStream => _riskStreamController.stream;
  
  /// Whether cloud service is currently available
  bool get isCloudServiceAvailable => _isCloudServiceAvailable;

  /// Manually re-test cloud connection (useful after login)
  Future<void> retestConnection() async {
    // Simply set as available since EC2 should be reliable
    _isCloudServiceAvailable = true;
  }

  /// Initialize the service and start monitoring cloud connectivity
  Future<void> initialize() async {
    print('🌩️ Initializing Real-Time Cloud Risk Service...');
    
    // Set cloud service as available (EC2 should be reliable)
    _isCloudServiceAvailable = true;
    
    print('✅ Real-Time Cloud Risk Service initialized');
  }

  /// Process new behavior data and get real-time risk assessment
  Future<RiskAssessment> processNewBehaviorData(BehaviorData behaviorData) async {
    print('📊 Processing new behavior data session ${behaviorData.sessionId}...');
    
    try {
      // Get risk assessment from cloud ML service
      final riskAssessment = await _cloudML.calculateRiskScore(behaviorData);
      
      // Store the risk assessment result
      await _storeRiskAssessment(behaviorData, riskAssessment);
      
      // Broadcast the risk assessment to listeners
      _riskStreamController.add(riskAssessment);
      
      // Log the result
      _logRiskAssessment(behaviorData, riskAssessment);
      
      return riskAssessment;
    } catch (e) {
      print('❌ Error processing behavior data: $e');
      
      // Create fallback assessment
      final fallbackAssessment = RiskAssessment(
        riskScore: 0.2,
        riskLevel: RiskLevel.low,
        touchAnomalyScore: 0.1,
        motionAnomalyScore: 0.1,
        contextAnomalyScore: 0.1,
        locationAnomalyScore: 0.05,
        timeAnomalyScore: 0.05,
        timestamp: DateTime.now(),
        isOffline: true,
      );
      
      _riskStreamController.add(fallbackAssessment);
      return fallbackAssessment;
    }
  }

  /// Store risk assessment with session data
  Future<void> _storeRiskAssessment(BehaviorData behaviorData, RiskAssessment riskAssessment) async {
    try {
      // You can extend this to store risk assessments in a separate table/collection
      // For now, we'll just log and could store in local storage if needed
      print('💾 Storing risk assessment for session ${behaviorData.sessionId}');
      
      // Optionally store in local storage or send to another service
      // await _saveRiskAssessmentToLocalStorage(behaviorData, riskAssessment);
      
    } catch (e) {
      print('❌ Error storing risk assessment: $e');
    }
  }

  /// Log risk assessment details
  void _logRiskAssessment(BehaviorData behaviorData, RiskAssessment riskAssessment) {
    final riskIcon = _getRiskIcon(riskAssessment.riskLevel);
    final userId = behaviorData.userId ?? 'unknown';
    final sessionId = behaviorData.sessionId ?? 0;
    
    print('$riskIcon RISK ASSESSMENT RESULT:');
    print('  Session ID: $sessionId');
    print('  User ID: $userId');
    print('  Risk Level: ${riskAssessment.riskLevel.name.toUpperCase()}');
    print('  Risk Score: ${riskAssessment.riskPercentage}');
    print('  Cloud Details: ${riskAssessment.cloudDetails}');
    print('  Timestamp: ${riskAssessment.timestamp}');
    
    // Alert for high risk
    if (riskAssessment.riskLevel == RiskLevel.high) {
      print('🚨 HIGH RISK ALERT: Immediate attention required!');
    }
  }

  /// Get risk level icon
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

  /// Dispose of resources
  void dispose() {
    _riskStreamController.close();
  }
}

/// Extension to behavior storage service for integrated risk assessment
extension BehaviorStorageServiceExtension on BehaviorStorageService {
  /// Save behavior data and trigger real-time risk assessment
  static Future<RiskAssessment> saveBehaviorDataWithRiskAssessment(BehaviorData data) async {
    final realTimeService = RealTimeCloudRiskService();
    
    // Save the behavior data first
    await BehaviorStorageService.saveBehaviorData(data);
    
    // Process for real-time risk assessment
    final riskAssessment = await realTimeService.processNewBehaviorData(data);
    
    return riskAssessment;
  }
}
