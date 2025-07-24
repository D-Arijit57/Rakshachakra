import 'package:flutter/material.dart';
import 'dart:async';
import '../services/cloud_ml_service.dart';
import '../services/real_time_cloud_risk_service.dart';
import '../services/behavior_monitor_service.dart';
import '../models/raw_behavior_data.dart';
import '../services/sensor_collector.dart';
import '../services/behavior_storage_service.dart';

/// Comprehensive demo screen for cloud-based ML risk assessment
class CloudMLDemoScreen extends StatefulWidget {
  const CloudMLDemoScreen({super.key});

  @override
  State<CloudMLDemoScreen> createState() => _CloudMLDemoScreenState();
}

class _CloudMLDemoScreenState extends State<CloudMLDemoScreen> {
  final CloudMLService _cloudML = CloudMLService();
  final RealTimeCloudRiskService _realTimeService = RealTimeCloudRiskService();
  final BehaviorMonitorService _behaviorMonitor = BehaviorMonitorService();
  
  StreamSubscription<RiskAssessment>? _riskSubscription;
  
  bool _isConnected = false;
  bool _isCollecting = false;
  bool _isMonitoring = false;
  
  List<RiskAssessment> _recentRiskAssessments = [];
  Map<String, String> _connectionStatus = {};
  
  @override
  void initState() {
    super.initState();
    _initializeDemo();
  }

  Future<void> _initializeDemo() async {
    setState(() {
      _connectionStatus['status'] = 'Initializing...';
    });
    
    // Initialize services
    await _realTimeService.initialize();
    await _behaviorMonitor.initialize();
    
    // Test connection
    await _testConnection();
    
    // Start monitoring
    _startRiskMonitoring();
  }

  Future<void> _testConnection() async {
    setState(() {
      _connectionStatus['status'] = 'Testing connection...';
    });
    
    try {
      _isConnected = await _cloudML.testConnection();
      
      setState(() {
        _connectionStatus = {
          'status': _isConnected ? 'Connected' : 'Disconnected',
          'endpoint': 'Cloud ML API',
          'last_tested': DateTime.now().toString(),
        };
      });
    } catch (e) {
      setState(() {
        _connectionStatus = {
          'status': 'Error',
          'error': e.toString(),
        };
      });
    }
  }

  void _startRiskMonitoring() {
    _isMonitoring = true;
    _riskSubscription = _behaviorMonitor.riskStream.listen(
      (riskAssessment) {
        setState(() {
          _recentRiskAssessments.insert(0, riskAssessment);
          if (_recentRiskAssessments.length > 10) {
            _recentRiskAssessments.removeLast();
          }
        });
      },
    );
  }

  Future<void> _collectAndAssessRisk() async {
    if (_isCollecting) return;
    
    setState(() {
      _isCollecting = true;
    });
    
    try {
      // Collect raw behavior data
      final rawData = await RawBehaviorData.collect();
      
      // Normalize the data
      final normalizedData = SensorCollector.normalize(
        rawData,
        userId: 'demo_user',
        sessionId: DateTime.now().millisecondsSinceEpoch,
      );
      
      // Save to storage
      await BehaviorStorageService.saveBehaviorData(normalizedData);
      
      // Get risk assessment from cloud
      final riskAssessment = await _cloudML.calculateRiskScore(normalizedData);
      
      setState(() {
        _recentRiskAssessments.insert(0, riskAssessment);
        if (_recentRiskAssessments.length > 10) {
          _recentRiskAssessments.removeLast();
        }
      });
      
      _showRiskResult(riskAssessment);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error collecting and assessing risk: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCollecting = false;
      });
    }
  }

  void _showRiskResult(RiskAssessment risk) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getRiskIcon(risk.riskLevel),
              color: _getRiskColor(risk.riskLevel),
            ),
            const SizedBox(width: 8),
            Text('Risk Assessment Result'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risk Level: ${risk.riskLevel.name.toUpperCase()}'),
            Text('Risk Score: ${risk.riskPercentage}'),
            const SizedBox(height: 8),
            Text('Description: ${risk.riskDescription}'),
            const SizedBox(height: 8),
            if (risk.cloudResponse != null) ...[
              Text('Cloud Response:'),
              Text('  Anomaly: ${risk.cloudResponse!['anomaly']}'),
              Text('  Raw Score: ${risk.cloudResponse!['risk_score']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _riskSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud ML Demo'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _testConnection,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildConnectionStatusCard(),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 16),
          _buildRealTimeMonitoring(),
          const SizedBox(height: 16),
          _buildRecentAssessments(),
        ],
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    final isConnected = _connectionStatus['status'] == 'Connected';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cloud ML Service Status',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._connectionStatus.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: entry.key == 'status' 
                              ? (isConnected ? Colors.green : Colors.red)
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cloud ML Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isCollecting ? null : _collectAndAssessRisk,
                    icon: _isCollecting 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.analytics),
                    label: Text(_isCollecting ? 'Collecting...' : 'Collect & Assess'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testConnection,
                    icon: const Icon(Icons.wifi_find),
                    label: const Text('Test Connection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Note: The "Collect & Assess" button will gather your current behavioral data and send it to the cloud ML service for real-time risk assessment.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeMonitoring() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isMonitoring ? Icons.monitor_heart : Icons.monitor_heart_outlined,
                  color: _isMonitoring ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Real-Time Monitoring',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _isMonitoring 
                  ? 'Continuously monitoring behavior and assessing risk via cloud ML'
                  : 'Real-time monitoring is stopped',
              style: TextStyle(
                color: _isMonitoring ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recent assessments: ${_recentRiskAssessments.length}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAssessments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Risk Assessments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_recentRiskAssessments.isEmpty)
              const Center(
                child: Text(
                  'No assessments yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ..._recentRiskAssessments.map(_buildRiskAssessmentTile),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAssessmentTile(RiskAssessment risk) {
    final color = _getRiskColor(risk.riskLevel);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getRiskIcon(risk.riskLevel),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${risk.riskLevel.name.toUpperCase()} - ${risk.riskPercentage}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  risk.cloudDetails,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(risk.timestamp),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRiskIcon(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Icons.security;
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

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
