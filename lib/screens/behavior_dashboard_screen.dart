import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../models/behavior_data.dart';
import '../services/behavior_storage_service.dart';
import '../services/cloud_ml_service.dart';
import '../services/real_time_cloud_risk_service.dart';
import '../services/behavior_monitor_service.dart';
import '../mixins/behavior_monitor_mixin.dart';
import 'risk_assessment_screen.dart';

class BehaviorDashboardScreen extends StatefulWidget {
  const BehaviorDashboardScreen({super.key});

  @override
  State<BehaviorDashboardScreen> createState() => _BehaviorDashboardScreenState();
}

class _BehaviorDashboardScreenState extends State<BehaviorDashboardScreen> with BehaviorMonitorMixin {
  List<BehaviorData> _behaviorDataList = [];
  Map<int, RiskAssessment> _riskAssessments = {};
  bool _isLoading = true;
  final CloudMLService _cloudMLService = CloudMLService();
  final RealTimeCloudRiskService _realTimeRiskService = RealTimeCloudRiskService();
  final BehaviorMonitorService _behaviorMonitor = BehaviorMonitorService();
  
  StreamSubscription<RiskAssessment>? _riskStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadData();
    _listenToRealTimeRisk();
  }

  Future<void> _initializeServices() async {
    await _realTimeRiskService.initialize();
    await _behaviorMonitor.initialize();
  }

  void _listenToRealTimeRisk() {
    _riskStreamSubscription = _behaviorMonitor.riskStream.listen((riskAssessment) {
      // Update UI when new risk assessment is available
      if (_behaviorDataList.isNotEmpty) {
        final latestSession = _behaviorDataList.first;
        setState(() {
          _riskAssessments[latestSession.sessionId ?? 0] = riskAssessment;
        });
        
        // Show notification for high risk
        if (riskAssessment.riskLevel == RiskLevel.high) {
          _showHighRiskAlert(riskAssessment);
        }
      }
    });
  }

  void _showHighRiskAlert(RiskAssessment riskAssessment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'HIGH RISK DETECTED: ${riskAssessment.riskPercentage}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View Details',
          textColor: Colors.white,
          onPressed: _navigateToRiskAssessment,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _riskStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await BehaviorStorageService.getAllBehaviorData();
      setState(() {
        _behaviorDataList = data.reversed.toList(); // Show newest first
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _exportJson() async {
    try {
      final data = await BehaviorStorageService.getAllBehaviorData();
      final jsonData = data.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonData);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/behavior_data.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Behavior Biometrics Data (JSON)',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting JSON: $e')),
      );
    }
  }

  Future<void> _exportCsv() async {
    try {
      final data = await BehaviorStorageService.getAllBehaviorData();
      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to export')),
        );
        return;
      }

      final csvBuffer = StringBuffer();
      
      // Add headers
      csvBuffer.writeln(BehaviorData.csvHeaders.join(','));

      // Add data rows
      for (final item in data) {
        csvBuffer.writeln(item.toCsvRow().join(','));
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/behavior_data.csv');
      await file.writeAsString(csvBuffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Behavior Biometrics Data (CSV)',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting CSV: $e')),
      );
    }
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to clear all behavior data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await BehaviorStorageService.clearAllData();
        setState(() {
          _behaviorDataList.clear();
          _riskAssessments.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing data: $e')),
        );
      }
    }
  }

  void _navigateToRiskAssessment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RiskAssessmentScreen(),
      ),
    );
  }

  Future<void> _analyzeLatestSession() async {
    if (_behaviorDataList.isEmpty) return;

    try {
      final latestSession = _behaviorDataList.first;
      final riskAssessment = await _cloudMLService.calculateRiskScore(latestSession);
      
      setState(() {
        _riskAssessments[latestSession.sessionId ?? 0] = riskAssessment;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                _getRiskIcon(riskAssessment.riskLevel),
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Latest session risk: ${riskAssessment.riskLevel.name.toUpperCase()} (${riskAssessment.riskPercentage})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: _getRiskColor(riskAssessment.riskLevel),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData _getRiskIcon(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.medium:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.error;
    }
  }

  Color _getRiskColor(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  /// Test methods for risk simulation
  Future<void> _testLowRisk() async {
    try {
      await _behaviorMonitor.testLowRiskScenario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Low risk scenario triggered!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing low risk: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testMediumRisk() async {
    try {
      await _behaviorMonitor.testMediumRiskScenario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medium risk scenario triggered!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing medium risk: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testHighRisk() async {
    try {
      await _behaviorMonitor.testHighRiskScenario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('High risk scenario triggered!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing high risk: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCloudStatusIndicator() {
    final isCloudAvailable = _behaviorMonitor.isCloudServiceAvailable;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCloudAvailable ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCloudAvailable ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCloudAvailable ? Icons.cloud_done : Icons.cloud_off,
            color: isCloudAvailable ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isCloudAvailable ? 'Cloud ML Online' : 'Cloud ML Offline',
            style: TextStyle(
              color: isCloudAvailable ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeRiskIndicator() {
    if (_behaviorDataList.isEmpty) return const SizedBox.shrink();
    
    final latestSession = _behaviorDataList.first;
    final riskAssessment = _riskAssessments[latestSession.sessionId ?? 0];
    
    if (riskAssessment == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getRiskColor(riskAssessment.riskLevel).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRiskColor(riskAssessment.riskLevel),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getRiskIcon(riskAssessment.riskLevel),
            color: _getRiskColor(riskAssessment.riskLevel),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest Session Risk: ${riskAssessment.riskLevel.name.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getRiskColor(riskAssessment.riskLevel),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: ${riskAssessment.riskPercentage}',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getRiskColor(riskAssessment.riskLevel),
                  ),
                ),
                if (riskAssessment.cloudResponse != null)
                  Text(
                    'Cloud: ${riskAssessment.cloudDetails}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavior Dashboard'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _exportJson,
                        icon: const Icon(Icons.file_download),
                        label: const Text('Export JSON'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _exportCsv,
                        icon: const Icon(Icons.table_chart),
                        label: const Text('Export CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _navigateToRiskAssessment,
                        icon: const Icon(Icons.security),
                        label: const Text('Risk Assessment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _clearData,
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Clear Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Test buttons for risk simulation
                const Text(
                  'Test Risk Scenarios',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _testLowRisk,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Low Risk'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _testMediumRisk,
                        icon: const Icon(Icons.warning),
                        label: const Text('Medium Risk'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _testHighRisk,
                        icon: const Icon(Icons.dangerous),
                        label: const Text('High Risk'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Data count and quick analysis
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Sessions: ${_behaviorDataList.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_behaviorDataList.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _analyzeLatestSession,
                    icon: const Icon(Icons.analytics, size: 16),
                    label: const Text('Quick Risk Check'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Cloud and real-time risk indicators
          _buildCloudStatusIndicator(),
          const SizedBox(height: 8),
          _buildRealTimeRiskIndicator(),
          const SizedBox(height: 8),
          
          // Data list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _behaviorDataList.isEmpty
                    ? const Center(
                        child: Text(
                          'No behavior data available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _behaviorDataList.length,
                        itemBuilder: (context, index) {
                          final data = _behaviorDataList[index];
                          return _buildDataCard(data, index);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(BehaviorData data, int index) {
    final riskAssessment = _riskAssessments[data.sessionId ?? index];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Session ${_behaviorDataList.length - index}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    if (riskAssessment != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRiskColor(riskAssessment.riskLevel),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${riskAssessment.riskLevel.name.toUpperCase()} RISK',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667EEA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Behavior Data',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Risk information if available
            if (riskAssessment != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getRiskColor(riskAssessment.riskLevel).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getRiskColor(riskAssessment.riskLevel).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Risk Score:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          riskAssessment.riskPercentage,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getRiskColor(riskAssessment.riskLevel),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      riskAssessment.riskDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getRiskColor(riskAssessment.riskLevel).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Touch metrics
            _buildMetricRow('Tap Duration', '${(data.tapDuration * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Swipe Velocity', '${(data.swipeVelocity * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Touch Pressure', '${(data.touchPressure * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Tap Interval Avg', '${(data.tapIntervalAvg * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Touch Area', '${(data.touchArea * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Touch Events', '${data.touchEventCount.toStringAsFixed(0)}'),
            
            const Divider(),
            
            // Motion & Orientation
            _buildMetricRow('Accel Variance', '${(data.accelVariance * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Gyro Variance', '${(data.gyroVariance * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Device Orientation', '${(data.deviceOrientation * 180).toStringAsFixed(1)}°'),
            
            const Divider(),
            
            // Device context
            _buildMetricRow('Battery Level', '${(data.batteryLevel * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Charging', data.chargingState == 1 ? 'Yes' : 'No'),
            _buildMetricRow('Brightness', '${(data.brightnessLevel * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Screen On Time', '${data.screenOnTime.toStringAsFixed(1)}s'),
            _buildMetricRow('App Usage Time', '${data.appUsageTime.toStringAsFixed(1)}s'),
            
            const Divider(),
            
            // Network & Location
            _buildMetricRow('Wi-Fi Available', data.wifiInfoMissing == 0 ? 'Yes' : 'No'),
            _buildMetricRow('GPS Available', data.gpsLocationMissing == 0 ? 'Yes' : 'No'),
            if (data.gpsLocationMissing == 0) ...[
              _buildMetricRow('Latitude', '${(data.gpsLatitude * 100).toStringAsFixed(1)}%'),
              _buildMetricRow('Longitude', '${(data.gpsLongitude * 100).toStringAsFixed(1)}%'),
            ],
            
            const Divider(),
            
            // Time context
            _buildMetricRow('Time of Day (Sin)', '${data.timeOfDaySin.toStringAsFixed(3)}'),
            _buildMetricRow('Time of Day (Cos)', '${data.timeOfDayCos.toStringAsFixed(3)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}