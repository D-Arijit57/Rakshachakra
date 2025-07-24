import 'package:flutter/material.dart';
import 'dart:async';
import '../models/behavior_data.dart';
import '../services/behavior_storage_service.dart';
import '../services/cloud_ml_service.dart';
import '../services/real_time_cloud_risk_service.dart';
import '../services/behavior_monitor_service.dart';
import '../mixins/behavior_monitor_mixin.dart';

class RiskAssessmentScreen extends StatefulWidget {
  const RiskAssessmentScreen({super.key});

  @override
  State<RiskAssessmentScreen> createState() => _RiskAssessmentScreenState();
}

class _RiskAssessmentScreenState extends State<RiskAssessmentScreen> with BehaviorMonitorMixin {
  List<BehaviorData> _behaviorDataList = [];
  Map<int, RiskAssessment> _riskAssessments = {};
  bool _isLoading = true;
  bool _isAnalyzing = false;
  final CloudMLService _cloudMLService = CloudMLService();
  final RealTimeCloudRiskService _realTimeRiskService = RealTimeCloudRiskService();
  final BehaviorMonitorService _behaviorMonitor = BehaviorMonitorService();
  
  StreamSubscription<RiskAssessment>? _riskStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
    _listenToRealTimeRisk();
  }

  void _listenToRealTimeRisk() {
    _riskStreamSubscription = _behaviorMonitor.riskStream.listen((riskAssessment) {
      // Update UI when new risk assessment is available
      if (_behaviorDataList.isNotEmpty) {
        final latestSession = _behaviorDataList.first;
        setState(() {
          _riskAssessments[latestSession.sessionId ?? 0] = riskAssessment;
        });
      }
    });
  }

  @override
  void dispose() {
    _riskStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeAndLoadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize cloud services
      await _realTimeRiskService.initialize();
      await _behaviorMonitor.initialize();
      
      // Load behavior data
      final data = await BehaviorStorageService.getAllBehaviorData();
      setState(() {
        _behaviorDataList = data.reversed.toList();
        _isLoading = false;
      });

      // Analyze risk for all sessions
      await _analyzeAllSessions();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _analyzeAllSessions() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final Map<int, RiskAssessment> assessments = {};
      
      for (int i = 0; i < _behaviorDataList.length; i++) {
        final session = _behaviorDataList[i];
        final riskAssessment = await _cloudMLService.calculateRiskScore(session);
        assessments[session.sessionId ?? i] = riskAssessment;
        
        // Update UI progressively
        if (i % 5 == 0 || i == _behaviorDataList.length - 1) {
          setState(() {
            _riskAssessments = Map.from(assessments);
          });
        }
      }

      setState(() {
        _riskAssessments = assessments;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing sessions: $e')),
      );
    }
  }

  Future<void> _retainModel() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Test cloud connection and re-analyze all sessions
      final isConnected = await _cloudMLService.testConnection();
      
      if (isConnected) {
        // Re-analyze all sessions with fresh cloud assessments
        await _analyzeAllSessions();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cloud ML service refreshed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloud ML service is not available'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing cloud service: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Risk Assessment'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeAndLoadData,
          ),                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'refresh') {
                          _retainModel();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'refresh',
                          child: Row(
                            children: [
                              Icon(Icons.refresh),
                              SizedBox(width: 8),
                              Text('Refresh Cloud ML'),
                            ],
                          ),
                        ),
                      ],
                    ),
        ],
      ),
      body: Column(
        children: [
          // Status indicators
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _behaviorMonitor.isCloudServiceAvailable ? Icons.cloud_done : Icons.cloud_off,
                      color: _behaviorMonitor.isCloudServiceAvailable ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _behaviorMonitor.isCloudServiceAvailable ? 'Cloud ML: Online' : 'Cloud ML: Offline',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusCard('Total Sessions', '${_behaviorDataList.length}', Colors.blue),
                    _buildStatusCard('Analyzed', '${_riskAssessments.length}', Colors.green),
                    _buildStatusCard('High Risk', '${_getHighRiskCount()}', Colors.red),
                  ],
                ),
              ],
            ),
          ),

          // Analysis progress
          if (_isAnalyzing)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text('Analyzing ${_riskAssessments.length}/${_behaviorDataList.length} sessions...'),
                ],
              ),
            ),

          // Session list
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
                          final session = _behaviorDataList[index];
                          final riskAssessment = _riskAssessments[session.sessionId ?? index];
                          return _buildRiskCard(session, riskAssessment, index);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  int _getHighRiskCount() {
    return _riskAssessments.values
        .where((assessment) => assessment.riskLevel == RiskLevel.high)
        .length;
  }

  Widget _buildRiskCard(BehaviorData session, RiskAssessment? riskAssessment, int index) {
    final sessionNumber = _behaviorDataList.length - index;
    
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
                  'Session $sessionNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (riskAssessment != null)
                  _buildRiskBadge(riskAssessment.riskLevel)
                else
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Timestamp: ${session.timestamp.toString().substring(0, 19)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            
            if (riskAssessment != null) ...[
              const SizedBox(height: 12),
              
              // Overall risk score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Risk Score:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    riskAssessment.riskPercentage,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getRiskColor(riskAssessment.riskLevel),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Text(
                riskAssessment.riskDescription,
                style: TextStyle(
                  color: _getRiskColor(riskAssessment.riskLevel),
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Detailed breakdown
              ExpansionTile(
                title: const Text('Risk Breakdown'),
                children: [
                  _buildRiskMetric('Touch Patterns', riskAssessment.touchAnomalyScore),
                  _buildRiskMetric('Motion Patterns', riskAssessment.motionAnomalyScore),
                  _buildRiskMetric('Device Context', riskAssessment.contextAnomalyScore),
                  _buildRiskMetric('Location', riskAssessment.locationAnomalyScore),
                  _buildRiskMetric('Time Patterns', riskAssessment.timeAnomalyScore),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskBadge(RiskLevel riskLevel) {
    final color = _getRiskColor(riskLevel);
    final text = riskLevel.name.toUpperCase();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRiskMetric(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Container(
                width: 100,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: score,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getScoreColor(score),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${(score * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ],
      ),
    );
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

  Color _getScoreColor(double score) {
    if (score >= 0.7) return Colors.red;
    if (score >= 0.4) return Colors.orange;
    return Colors.green;
  }
}
