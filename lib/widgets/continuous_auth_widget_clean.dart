import 'package:flutter/material.dart';
import 'dart:async';
import 'package:raksha/services/continuous_auth_service.dart';

class ContinuousAuthWidget extends StatefulWidget {
  const ContinuousAuthWidget({super.key});

  @override
  State<ContinuousAuthWidget> createState() => _ContinuousAuthWidgetState();
}

class _ContinuousAuthWidgetState extends State<ContinuousAuthWidget> {
  final ContinuousAuthService _authService = ContinuousAuthService();
  late StreamSubscription<double> _riskScoreSubscription;
  late StreamSubscription<AuthRiskLevel> _riskLevelSubscription;
  
  double _currentRiskScore = 0.0;
  AuthRiskLevel _currentRiskLevel = AuthRiskLevel.low;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeStreams();
  }

  void _initializeStreams() {
    _riskScoreSubscription = _authService.riskScoreStream.listen((score) {
      if (mounted) {
        setState(() {
          _currentRiskScore = score;
        });
      }
    });
    
    _riskLevelSubscription = _authService.riskLevelStream.listen((level) {
      if (mounted) {
        setState(() {
          _currentRiskLevel = level;
        });
      }
    });
  }

  @override
  void dispose() {
    _riskScoreSubscription.cancel();
    _riskLevelSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shield,
                  color: _getRiskColor(_currentRiskLevel),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Security Status',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRiskColor(_currentRiskLevel),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentRiskLevel.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _currentRiskScore,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getRiskColor(_currentRiskLevel),
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(_currentRiskScore * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 12),
              _buildExpandedContent(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _authService.getAuthStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final stats = snapshot.data ?? {};
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Last Check', stats['lastCheck'] ?? 'Never'),
                _buildStatItem('Risk Score', '${((stats['riskScore'] as double? ?? 0.0) * 100).toInt()}%'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _authService.performManualCheck();
                      final updatedStats = await _authService.getAuthStats();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Manual check: ${((updatedStats['riskScore'] as double) * 100).toInt()}% risk'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Manual Check'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _authService.reset();
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRiskLevelInfo(),
          ],
        );
      },
    );
  }

  Widget _buildRiskLevelInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk Level Information',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getRiskLevelDescription(_currentRiskLevel),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getRiskLevelDescription(AuthRiskLevel level) {
    switch (level) {
      case AuthRiskLevel.low:
        return 'Normal behavior patterns detected. No additional verification required.';
      case AuthRiskLevel.medium:
        return 'Slightly unusual behavior patterns. Consider additional verification.';
      case AuthRiskLevel.high:
        return 'Concerning behavior patterns detected. Additional verification recommended.';
      case AuthRiskLevel.critical:
        return 'High-risk behavior patterns detected. Immediate verification required.';
    }
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(AuthRiskLevel level) {
    switch (level) {
      case AuthRiskLevel.low:
        return Colors.green;
      case AuthRiskLevel.medium:
        return Colors.yellow[700]!;
      case AuthRiskLevel.high:
        return Colors.orange;
      case AuthRiskLevel.critical:
        return Colors.red;
    }
  }
}
