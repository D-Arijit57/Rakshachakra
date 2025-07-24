import 'dart:async';
import 'package:flutter/material.dart';
import '../models/raw_behavior_data.dart';
import '../models/behavior_data.dart';
import 'sensor_collector.dart';
import 'behavior_storage_service.dart';
import 'real_time_cloud_risk_service.dart';
import 'cloud_ml_service.dart';
import 'auth_service.dart';

class BehaviorMonitorService {
  static final BehaviorMonitorService _instance = BehaviorMonitorService._internal();
  factory BehaviorMonitorService() => _instance;
  BehaviorMonitorService._internal();

  final List<RawBehaviorData> _rawDataQueue = [];
  final List<BehaviorData> _normalizedDataQueue = [];
  final RealTimeCloudRiskService _cloudRiskService = RealTimeCloudRiskService();
  
  Timer? _timer;
  bool _isRunning = false;
  int _sessionId = 0;

  // Add context for showing dialogs
  BuildContext? _context;

  /// Set the context for showing dialogs
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Stream of real-time risk assessments
  Stream<RiskAssessment> get riskStream => _cloudRiskService.riskStream;

  /// Initialize the service
  Future<void> initialize() async {
    await _cloudRiskService.initialize();
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => collectData());
    collectData(); // Collect immediately on start
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
  }

  Future<void> collectData() async {
    print('🔄 Collecting new behavior data...');
    
    // Collect raw data
    RawBehaviorData rawData = await RawBehaviorData.collect();
    _rawDataQueue.add(rawData);

    // Get current username for user ID generation
    String username = 'current_user'; // Default fallback
    try {
      final authService = AuthService();
      if (authService.isLoggedIn) {
        username = authService.currentUser?.username ?? 'current_user';
      }
    } catch (e) {
      print('⚠️ Could not get username from AuthService: $e');
    }

    // Normalize and store with session tracking
    _sessionId++;
    BehaviorData normalizedData = SensorCollector.normalize(
      rawData, 
      userId: username,
      sessionId: _sessionId,
    );
    _normalizedDataQueue.add(normalizedData);

    // Save to local storage
    await BehaviorStorageService.saveBehaviorData(normalizedData);
    
    // Process with cloud ML service for real-time risk assessment
    final riskAssessment = await _cloudRiskService.processNewBehaviorData(normalizedData);
    
    print('✅ Behavior data collected and risk assessed: ${riskAssessment.riskLevel.name}');
    
    // Handle risk-based actions
    await _handleRiskActions(riskAssessment);
  }

  /// Handle risk-based security actions
  Future<void> _handleRiskActions(RiskAssessment riskAssessment) async {
    if (_context == null || !_context!.mounted) return;

    switch (riskAssessment.riskLevel) {
      case RiskLevel.medium:
        await _showMfaPopup();
        break;
      case RiskLevel.high:
        await _showLogoutWarning();
        break;
      case RiskLevel.low:
        await _showLowRiskNotification();
        break;
    }
  }

  /// Show MFA popup for medium risk
  Future<void> _showMfaPopup() async {
    if (_context == null || !_context!.mounted) return;

    final TextEditingController mfaController = TextEditingController();
    
    await showDialog<void>(
      context: _context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.orange.shade50,
          contentPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade700, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Security Verification Required',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    'Your behavior pattern indicates medium risk. Please verify your identity to continue.',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: mfaController,
                  decoration: InputDecoration(
                    labelText: 'Enter MFA Code',
                    labelStyle: TextStyle(color: Colors.orange.shade700),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
                    ),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  if (mfaController.text.trim() == 'admin') {
                    Navigator.of(context).pop();
                    if (_context != null && _context!.mounted) {
                      ScaffoldMessenger.of(_context!).showSnackBar(
                        SnackBar(
                          content: const Text('MFA verification successful'),
                          backgroundColor: Colors.green.shade600,
                        ),
                      );
                    }
                  } else {
                    if (_context != null && _context!.mounted) {
                      ScaffoldMessenger.of(_context!).showSnackBar(
                        SnackBar(
                          content: const Text('Invalid MFA code. Please try again.'),
                          backgroundColor: Colors.red.shade600,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Verify Identity'),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show success notification for low risk
  Future<void> _showLowRiskNotification() async {
    if (_context == null || !_context!.mounted) return;

    // Show green success snackbar
    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Security Status: All Good!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show logout warning for high risk
  Future<void> _showLogoutWarning() async {
    if (_context == null || !_context!.mounted) return;

    // Show warning dialog
    await showDialog<void>(
      context: _context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red.shade50,
          contentPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Icon(Icons.security, color: Colors.red.shade700, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CRITICAL SECURITY ALERT',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, color: Colors.red.shade700, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'SUSPICIOUS ACTIVITY DETECTED',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your behavioral patterns indicate a high security risk. For your account protection, you will be automatically logged out in 3 seconds.',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('I Understand'),
              ),
            ),
          ],
        );
      },
    );

    // Wait 3 seconds then logout
    await Future.delayed(const Duration(seconds: 3));
    await _performLogout();
  }

  /// Perform logout
  Future<void> _performLogout() async {
    try {
      final authService = AuthService();
      await authService.logout();
      
      if (_context != null && _context!.mounted) {
        Navigator.of(_context!).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  /// Manually trigger risk assessment for existing session
  Future<RiskAssessment> assessRisk(BehaviorData behaviorData) async {
    return await _cloudRiskService.processNewBehaviorData(behaviorData);
  }

  /// Check if cloud service is available
  bool get isCloudServiceAvailable => _cloudRiskService.isCloudServiceAvailable;

  /// Test method to simulate medium risk scenario
  Future<void> testMediumRiskScenario() async {
    print('🧪 Testing medium risk scenario with hardcoded data...');
    
    // Create hardcoded medium risk behavior data
    final mediumRiskData = BehaviorData(
      userId: 'current_user',
      sessionId: 999,
      timestamp: DateTime.now(),
      tapDuration: 0.0,
      swipeVelocity: 0.0,
      touchPressure: 0.0,
      tapIntervalAvg: 0.0,
      accelVariance: 0.0,
      gyroVariance: 0.0,
      batteryLevel: 0.5,
      brightnessLevel: 0.5,
      touchArea: 0.0,
      touchEventCount: 0.3,
      appUsageTime: 0.1,
      accelVarianceMissing: 0,
      gyroVarianceMissing: 0,
      chargingState: 1,
      screenOnTime: 0.0,
      wifiIdHash: 0.0,
      wifiInfoMissing: 0,
      gpsLatitude: 0.52,
      gpsLongitude: 0.68,
      gpsLocationMissing: 0,
      timeOfDaySin: 0.25,
      timeOfDayCos: 0.96,
      dayOfWeekMon: 0,
      dayOfWeekTue: 0,
      dayOfWeekWed: 0,
      dayOfWeekThu: 0,
      dayOfWeekFri: 0,
      dayOfWeekSat: 1,
      dayOfWeekSun: 0,
      deviceOrientation: 0.5,
    );

    // Process with cloud ML service
    final riskAssessment = await _cloudRiskService.processNewBehaviorData(mediumRiskData);
    print('📊 Medium risk test result: ${riskAssessment.riskLevel.name}');
    
    // Handle risk-based actions
    await _handleRiskActions(riskAssessment);
  }

  /// Test method to simulate high risk scenario
  Future<void> testHighRiskScenario() async {
    print('🧪 Testing high risk scenario with hardcoded data...');
    
    // Create hardcoded high risk behavior data (was previously low risk data)
    final highRiskData = BehaviorData(
      userId: 'current_user',
      sessionId: 1000,
      timestamp: DateTime.now(),
      tapDuration: 0.15,
      swipeVelocity: 0.35,
      touchPressure: 0.6,
      tapIntervalAvg: 0.25,
      accelVariance: 0.2,
      gyroVariance: 0.15,
      batteryLevel: 0.75,
      brightnessLevel: 0.5,
      touchArea: 0.3,
      touchEventCount: 5.0,
      appUsageTime: 0.05,
      accelVarianceMissing: 0,
      gyroVarianceMissing: 0,
      chargingState: 0,
      screenOnTime: 0.5,
      wifiIdHash: 0.5,
      wifiInfoMissing: 0,
      gpsLatitude: 0.5,
      gpsLongitude: 0.5,
      gpsLocationMissing: 0,
      timeOfDaySin: 0.0,
      timeOfDayCos: 1.0,
      dayOfWeekMon: 1,
      dayOfWeekTue: 0,
      dayOfWeekWed: 0,
      dayOfWeekThu: 0,
      dayOfWeekFri: 0,
      dayOfWeekSat: 0,
      dayOfWeekSun: 0,
      deviceOrientation: 1.0,
    );

    // Process with cloud ML service
    final riskAssessment = await _cloudRiskService.processNewBehaviorData(highRiskData);
    print('📊 High risk test result: ${riskAssessment.riskLevel.name}');
    
    // Handle risk-based actions
    await _handleRiskActions(riskAssessment);
  }

  /// Test method to simulate low risk scenario
  Future<void> testLowRiskScenario() async {
    print('🧪 Testing low risk scenario...');
    
    // Create low risk behavior data (was previously high risk data)
    final lowRiskData = BehaviorData(
      userId: 'current_user',
      sessionId: 998,
      timestamp: DateTime.now(),
      tapDuration: 0.0,
      swipeVelocity: 1.0,
      touchPressure: 1.0,
      tapIntervalAvg: 0.0,
      accelVariance: 1.0,
      gyroVariance: 5.91179E-05,
      batteryLevel: 0.55,
      brightnessLevel: 0.549019635,
      touchArea: 0.2,
      touchEventCount: 0.0942,
      appUsageTime: 0.0942,
      accelVarianceMissing: 0,
      gyroVarianceMissing: 0,
      chargingState: 1,
      screenOnTime: 0.028366667,
      wifiIdHash: 0.309907,
      wifiInfoMissing: 0,
      gpsLatitude: 0.550720994,
      gpsLongitude: 0.305499231,
      gpsLocationMissing: 0,
      timeOfDaySin: -0.866025404,
      timeOfDayCos: 0.5,
      dayOfWeekMon: 0,
      dayOfWeekTue: 0,
      dayOfWeekWed: 0,
      dayOfWeekThu: 0,
      dayOfWeekFri: 1,
      dayOfWeekSat: 0,
      dayOfWeekSun: 0,
      deviceOrientation: 1.0,
    );

    // Process with cloud ML service
    final riskAssessment = await _cloudRiskService.processNewBehaviorData(lowRiskData);
    print('📊 Low risk test result: ${riskAssessment.riskLevel.name}');
    
    // Handle risk-based actions
    await _handleRiskActions(riskAssessment);
  }

  List<RawBehaviorData> get rawDataQueue => List.unmodifiable(_rawDataQueue);
  List<BehaviorData> get normalizedDataQueue => List.unmodifiable(_normalizedDataQueue);

  void clear() {
    _rawDataQueue.clear();
    _normalizedDataQueue.clear();
  }
}