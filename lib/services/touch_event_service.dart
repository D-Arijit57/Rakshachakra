import 'package:flutter/gestures.dart';

class TouchEventService {
  static final TouchEventService instance = TouchEventService._internal();
  TouchEventService._internal();

  // Store events for the last minute
  final List<_TouchEvent> _events = [];
  double? _lastTapUpTime;
  double _screenOnTime = 0.0;
  DateTime? _lastActiveTime;
  
  void recordTap({required double duration, required double pressure, double? touchArea}) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    double? interval;
    if (_lastTapUpTime != null) {
      interval = now - _lastTapUpTime!;
    }
    _lastTapUpTime = now;
    
    _events.add(_TouchEvent(
      type: _TouchType.tap,
      timestamp: now,
      duration: duration,
      pressure: pressure,
      interval: interval,
      touchArea: touchArea,
    ));
    
    _updateScreenOnTime();
    _pruneOldEvents();
  }

  void recordSwipe({required double velocity, required double pressure, double? touchArea}) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _events.add(_TouchEvent(
      type: _TouchType.swipe,
      timestamp: now,
      velocity: velocity,
      pressure: pressure,
      touchArea: touchArea,
    ));
    
    _updateScreenOnTime();
    _pruneOldEvents();
  }

  void _updateScreenOnTime() {
    final now = DateTime.now();
    if (_lastActiveTime != null) {
      _screenOnTime += now.difference(_lastActiveTime!).inMilliseconds / 1000.0;
    }
    _lastActiveTime = now;
  }

  void _pruneOldEvents() {
    final cutoff = DateTime.now().millisecondsSinceEpoch / 1000.0 - 60.0;
    _events.removeWhere((e) => e.timestamp < cutoff);
  }

  Map<String, dynamic> getAndResetStats() {
    _pruneOldEvents();
    
    final taps = _events.where((e) => e.type == _TouchType.tap).toList();
    final swipes = _events.where((e) => e.type == _TouchType.swipe).toList();
    
    // Calculate averages with null safety
    double? tapDuration;
    if (taps.isNotEmpty) {
      final validDurations = taps.where((e) => e.duration != null).map((e) => e.duration!);
      if (validDurations.isNotEmpty) {
        tapDuration = validDurations.reduce((a, b) => a + b) / validDurations.length;
      }
    }

    double? tapIntervalAvg;
    if (taps.isNotEmpty) {
      final validIntervals = taps.where((e) => e.interval != null).map((e) => e.interval!);
      if (validIntervals.isNotEmpty) {
        tapIntervalAvg = validIntervals.reduce((a, b) => a + b) / validIntervals.length;
      }
    }

    double? tapPressure;
    if (taps.isNotEmpty) {
      final validPressures = taps.where((e) => e.pressure != null).map((e) => e.pressure!);
      if (validPressures.isNotEmpty) {
        tapPressure = validPressures.reduce((a, b) => a + b) / validPressures.length;
      }
    }

    double? swipeVelocity;
    if (swipes.isNotEmpty) {
      final validVelocities = swipes.where((e) => e.velocity != null).map((e) => e.velocity!);
      if (validVelocities.isNotEmpty) {
        swipeVelocity = validVelocities.reduce((a, b) => a + b) / validVelocities.length;
      }
    }

    double? touchArea;
    final allEvents = [...taps, ...swipes];
    if (allEvents.isNotEmpty) {
      final validAreas = allEvents.where((e) => e.touchArea != null).map((e) => e.touchArea!);
      if (validAreas.isNotEmpty) {
        touchArea = validAreas.reduce((a, b) => a + b) / validAreas.length;
      }
    }

    // Store current screen on time and reset
    final currentScreenOnTime = _screenOnTime;
    _screenOnTime = 0.0;
    _lastActiveTime = null;

    // Clear events after getting stats
    _events.clear();
    
    return {
      'tapDuration': tapDuration,
      'tapIntervalAvg': tapIntervalAvg,
      'touchPressure': tapPressure,
      'swipeVelocity': swipeVelocity,
      'touchArea': touchArea,
      'screenOnTime': currentScreenOnTime,
      'touchEventCount': allEvents.length,
    };
  }

  // Additional method to get current stats without resetting
  Map<String, dynamic> getCurrentStats() {
    _pruneOldEvents();
    
    final taps = _events.where((e) => e.type == _TouchType.tap).toList();
    final swipes = _events.where((e) => e.type == _TouchType.swipe).toList();
    final allEvents = [...taps, ...swipes];
    
    return {
      'totalEvents': allEvents.length,
      'tapCount': taps.length,
      'swipeCount': swipes.length,
      'avgTapDuration': taps.isNotEmpty ? 
        taps.where((e) => e.duration != null).map((e) => e.duration!).fold(0.0, (a, b) => a + b) / taps.length : 0.0,
      'avgSwipeVelocity': swipes.isNotEmpty ? 
        swipes.where((e) => e.velocity != null).map((e) => e.velocity!).fold(0.0, (a, b) => a + b) / swipes.length : 0.0,
      'currentScreenOnTime': _screenOnTime,
    };
  }
}

enum _TouchType { tap, swipe }

class _TouchEvent {
  final _TouchType type;
  final double timestamp;
  final double? duration;
  final double? pressure;
  final double? interval;
  final double? velocity;
  final double? touchArea;

  _TouchEvent({
    required this.type,
    required this.timestamp,
    this.duration,
    this.pressure,
    this.interval,
    this.velocity,
    this.touchArea,
  });
}

class TouchEventTracker {
  static final TouchEventTracker instance = TouchEventTracker._internal();
  TouchEventTracker._internal();

  Offset? _lastPointerDownPos;
  int? _lastPointerDownTime;
  double? _lastPointerPressure;
  double? _lastPointerSize;

  void onPointerDown(PointerDownEvent event) {
    _lastPointerDownPos = event.position;
    _lastPointerDownTime = event.timeStamp.inMilliseconds;
    _lastPointerPressure = event.pressure;
    _lastPointerSize = event.size;
  }

  void onPointerUp(PointerUpEvent event) {
    if (_lastPointerDownTime != null) {
      final duration = (event.timeStamp.inMilliseconds - _lastPointerDownTime!) / 1000.0;
      final pressure = _lastPointerPressure ?? 1.0;
      final touchArea = _lastPointerSize ?? 1.0;
      
      TouchEventService.instance.recordTap(
        duration: duration, 
        pressure: pressure,
        touchArea: touchArea,
      );
    }
    _resetPointerData();
  }

  void onPointerMove(PointerMoveEvent event) {
    if (_lastPointerDownPos != null && _lastPointerDownTime != null) {
      final distance = (event.position - _lastPointerDownPos!).distance;
      final duration = (event.timeStamp.inMilliseconds - _lastPointerDownTime!) / 1000.0;
      
      if (duration > 0.05 && distance > 10) {
        final velocity = distance / duration;
        final pressure = event.pressure;
        final touchArea = event.size;
        
        TouchEventService.instance.recordSwipe(
          velocity: velocity, 
          pressure: pressure,
          touchArea: touchArea,
        );
        
        _lastPointerDownPos = event.position;
        _lastPointerDownTime = event.timeStamp.inMilliseconds;
        _lastPointerPressure = event.pressure;
        _lastPointerSize = event.size;
      }
    }
  }

  void _resetPointerData() {
    _lastPointerDownPos = null;
    _lastPointerDownTime = null;
    _lastPointerPressure = null;
    _lastPointerSize = null;
  }
} 