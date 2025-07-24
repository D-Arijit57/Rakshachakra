import 'package:flutter/material.dart';
import 'dart:async';
import '../services/touch_event_service.dart';
import '../models/raw_behavior_data.dart';
import '../services/continuous_auth_service.dart';

class BehaviorTestScreen extends StatefulWidget {
  const BehaviorTestScreen({super.key});

  @override
  State<BehaviorTestScreen> createState() => _BehaviorTestScreenState();
}

class _BehaviorTestScreenState extends State<BehaviorTestScreen> {
  final ContinuousAuthService _authService = ContinuousAuthService();
  Timer? _updateTimer;
  
  Map<String, dynamic> _currentTouchStats = {};
  Map<String, dynamic> _lastCollectedData = {};
  double _currentRiskScore = 0.0;
  bool _isCollecting = false;

  @override
  void initState() {
    super.initState();
    _startRealTimeUpdates();
  }

  void _startRealTimeUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateStats();
    });
  }

  void _updateStats() {
    if (mounted) {
      setState(() {
        _currentTouchStats = TouchEventService.instance.getCurrentStats();
        _currentRiskScore = _authService.currentRiskScore;
      });
    }
  }

  Future<void> _collectFullBehaviorData() async {
    setState(() {
      _isCollecting = true;
    });

    try {
      final rawData = await RawBehaviorData.collect();
      setState(() {
        _lastCollectedData = {
          'timestamp': rawData.collectionTimestamp.toString(),
          'tapDuration': rawData.rawTapDuration?.toStringAsFixed(3) ?? 'null',
          'swipeVelocity': rawData.rawSwipeVelocity?.toStringAsFixed(3) ?? 'null',
          'touchPressure': rawData.rawTouchPressure?.toStringAsFixed(3) ?? 'null',
          'accelReadings': rawData.rawAccelReadings?.map((e) => e.toStringAsFixed(3)).join(', ') ?? 'null',
          'gyroReadings': rawData.rawGyroReadings?.map((e) => e.toStringAsFixed(3)).join(', ') ?? 'null',
          'batteryLevel': rawData.rawBatteryLevel?.toStringAsFixed(3) ?? 'null',
          'brightnessLevel': rawData.rawBrightnessLevel?.toStringAsFixed(3) ?? 'null',
          'deviceOrientation': rawData.rawDeviceOrientation?.toStringAsFixed(3) ?? 'null',
          'touchArea': rawData.rawTouchArea?.toStringAsFixed(3) ?? 'null',
          'appUsageTime': rawData.rawAppUsageTime?.toStringAsFixed(3) ?? 'null',
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error collecting data: $e')),
      );
    } finally {
      setState(() {
        _isCollecting = false;
      });
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavior Test'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionCard(),
            const SizedBox(height: 16),
            _buildRealTimeStatsCard(),
            const SizedBox(height: 16),
            _buildCollectDataCard(),
            const SizedBox(height: 16),
            _buildLastCollectedDataCard(),
            const SizedBox(height: 16),
            _buildTestActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How to Test Behavioral Biometrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Tap around on this screen to generate touch events\n'
              '2. Swipe in different directions\n'
              '3. Hold taps for different durations\n'
              '4. Move your device to generate motion sensor data\n'
              '5. Watch the real-time stats update\n'
              '6. Use "Collect Full Data" to see all metrics\n'
              '7. Check the risk score changes based on your behavior',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Real-Time Touch Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRiskColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Risk: ${(_currentRiskScore * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatRow('Total Events', '${_currentTouchStats['totalEvents'] ?? 0}'),
            _buildStatRow('Tap Count', '${_currentTouchStats['tapCount'] ?? 0}'),
            _buildStatRow('Swipe Count', '${_currentTouchStats['swipeCount'] ?? 0}'),
            _buildStatRow('Avg Tap Duration', '${_currentTouchStats['avgTapDuration']?.toStringAsFixed(3) ?? 'N/A'}s'),
            _buildStatRow('Avg Swipe Velocity', '${_currentTouchStats['avgSwipeVelocity']?.toStringAsFixed(3) ?? 'N/A'}px/s'),
            _buildStatRow('Screen On Time', '${_currentTouchStats['currentScreenOnTime']?.toStringAsFixed(1) ?? 'N/A'}s'),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectDataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Full Data Collection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCollecting ? null : _collectFullBehaviorData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                ),
                child: _isCollecting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Collecting...'),
                        ],
                      )
                    : const Text('Collect Full Behavior Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastCollectedDataCard() {
    if (_lastCollectedData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Collected Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._lastCollectedData.entries.map((entry) =>
              _buildStatRow(entry.key, entry.value.toString())
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Areas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap, swipe, and interact with these areas to generate behavioral data:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Center(
                      child: Text(
                        'Tap Area 1',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Center(
                      child: Text(
                        'Tap Area 2',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Center(
                child: Text(
                  'Swipe Area - Try different swipe directions and speeds',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor() {
    if (_currentRiskScore >= 0.9) return Colors.red;
    if (_currentRiskScore >= 0.7) return Colors.orange;
    if (_currentRiskScore >= 0.4) return Colors.yellow[700]!;
    return Colors.green;
  }
}
