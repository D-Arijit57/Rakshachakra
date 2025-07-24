import 'package:flutter/material.dart';
import '../services/behavior_monitor_service.dart';

/// Mixin to automatically set context for behavior monitor service on all screens
mixin BehaviorMonitorMixin<T extends StatefulWidget> on State<T> {
  final BehaviorMonitorService _behaviorMonitor = BehaviorMonitorService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set context for behavior monitor service to show dialogs on any screen
    _behaviorMonitor.setContext(context);
  }
}
