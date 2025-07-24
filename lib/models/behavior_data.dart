class BehaviorData {
  // Touch metrics
  final double tapDuration;
  final double swipeVelocity;
  final double touchPressure;
  final double tapIntervalAvg;

  // Motion sensors
  final double accelVariance;
  final int accelVarianceMissing;
  final double gyroVariance;
  final int gyroVarianceMissing;

  // Device context
  final double batteryLevel;
  final int chargingState;
  final double brightnessLevel;
  final double screenOnTime;

  // Network/Location
  final double wifiIdHash;
  final int wifiInfoMissing;
  final double gpsLatitude;
  final double gpsLongitude;
  final int gpsLocationMissing;

  // Time encoding
  final double timeOfDaySin;
  final double timeOfDayCos;
  final int dayOfWeekMon;
  final int dayOfWeekTue;
  final int dayOfWeekWed;
  final int dayOfWeekThu;
  final int dayOfWeekFri;
  final int dayOfWeekSat;
  final int dayOfWeekSun;

  // Additional behavioral metrics
  final double deviceOrientation;
  final double touchArea;
  final double touchEventCount;
  final double appUsageTime;
  
  // Metadata for ML models
  final DateTime? timestamp;
  final String? userId;
  final int? sessionId;

  BehaviorData({
    required this.tapDuration,
    required this.swipeVelocity,
    required this.touchPressure,
    required this.tapIntervalAvg,
    required this.accelVariance,
    required this.accelVarianceMissing,
    required this.gyroVariance,
    required this.gyroVarianceMissing,
    required this.batteryLevel,
    required this.chargingState,
    required this.brightnessLevel,
    required this.screenOnTime,
    required this.wifiIdHash,
    required this.wifiInfoMissing,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.gpsLocationMissing,
    required this.timeOfDaySin,
    required this.timeOfDayCos,
    required this.dayOfWeekMon,
    required this.dayOfWeekTue,
    required this.dayOfWeekWed,
    required this.dayOfWeekThu,
    required this.dayOfWeekFri,
    required this.dayOfWeekSat,
    required this.dayOfWeekSun,
    required this.deviceOrientation,
    required this.touchArea,
    required this.touchEventCount,
    required this.appUsageTime,
    this.timestamp,
    this.userId,
    this.sessionId,
  });

  factory BehaviorData.fromJson(Map<String, dynamic> json) {
    return BehaviorData(
      tapDuration: json['tap_duration']?.toDouble() ?? 0.0,
      swipeVelocity: json['swipe_velocity']?.toDouble() ?? 0.0,
      touchPressure: json['touch_pressure']?.toDouble() ?? 0.0,
      tapIntervalAvg: json['tap_interval_avg']?.toDouble() ?? 0.0,
      accelVariance: json['accel_variance']?.toDouble() ?? 0.0,
      accelVarianceMissing: json['accel_variance_missing']?.toInt() ?? 0,
      gyroVariance: json['gyro_variance']?.toDouble() ?? 0.0,
      gyroVarianceMissing: json['gyro_variance_missing']?.toInt() ?? 0,
      batteryLevel: json['battery_level']?.toDouble() ?? 0.0,
      chargingState: json['charging_state']?.toInt() ?? 0,
      brightnessLevel: json['brightness_level']?.toDouble() ?? 0.0,
      screenOnTime: json['screen_on_time']?.toDouble() ?? 0.0,
      wifiIdHash: json['wifi_id_hash']?.toDouble() ?? 0.0,
      wifiInfoMissing: json['wifi_info_missing']?.toInt() ?? 0,
      gpsLatitude: json['gps_latitude']?.toDouble() ?? 0.0,
      gpsLongitude: json['gps_longitude']?.toDouble() ?? 0.0,
      gpsLocationMissing: json['gps_location_missing']?.toInt() ?? 0,
      timeOfDaySin: json['time_of_day_sin']?.toDouble() ?? 0.0,
      timeOfDayCos: json['time_of_day_cos']?.toDouble() ?? 0.0,
      dayOfWeekMon: json['day_of_week_mon']?.toInt() ?? 0,
      dayOfWeekTue: json['day_of_week_tue']?.toInt() ?? 0,
      dayOfWeekWed: json['day_of_week_wed']?.toInt() ?? 0,
      dayOfWeekThu: json['day_of_week_thu']?.toInt() ?? 0,
      dayOfWeekFri: json['day_of_week_fri']?.toInt() ?? 0,
      dayOfWeekSat: json['day_of_week_sat']?.toInt() ?? 0,
      dayOfWeekSun: json['day_of_week_sun']?.toInt() ?? 0,
      deviceOrientation: json['device_orientation']?.toDouble() ?? 0.0,
      touchArea: json['touch_area']?.toDouble() ?? 0.0,
      touchEventCount: json['touch_event_count']?.toDouble() ?? 0.0,
      appUsageTime: json['app_usage_time']?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp']) : null,
      userId: json['user_id'],
      sessionId: json['session_id']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'tap_duration': tapDuration,
    'swipe_velocity': swipeVelocity,
    'touch_pressure': touchPressure,
    'tap_interval_avg': tapIntervalAvg,
    'accel_variance': accelVariance,
    'accel_variance_missing': accelVarianceMissing,
    'gyro_variance': gyroVariance,
    'gyro_variance_missing': gyroVarianceMissing,
    'battery_level': batteryLevel,
    'charging_state': chargingState,
    'brightness_level': brightnessLevel,
    'screen_on_time': screenOnTime,
    'wifi_id_hash': wifiIdHash,
    'wifi_info_missing': wifiInfoMissing,
    'gps_latitude': gpsLatitude,
    'gps_longitude': gpsLongitude,
    'gps_location_missing': gpsLocationMissing,
    'time_of_day_sin': timeOfDaySin,
    'time_of_day_cos': timeOfDayCos,
    'day_of_week_mon': dayOfWeekMon,
    'day_of_week_tue': dayOfWeekTue,
    'day_of_week_wed': dayOfWeekWed,
    'day_of_week_thu': dayOfWeekThu,
    'day_of_week_fri': dayOfWeekFri,
    'day_of_week_sat': dayOfWeekSat,
    'day_of_week_sun': dayOfWeekSun,
    'device_orientation': deviceOrientation,
    'touch_area': touchArea,
    'touch_event_count': touchEventCount,
    'app_usage_time': appUsageTime,
    'timestamp': timestamp?.toIso8601String(),
    'user_id': userId,
    'session_id': sessionId,
  };

  static List<String> get csvHeaders => [
    'tap_duration',
    'swipe_velocity',
    'touch_pressure',
    'tap_interval_avg',
    'accel_variance',
    'accel_variance_missing',
    'gyro_variance',
    'gyro_variance_missing',
    'battery_level',
    'charging_state',
    'brightness_level',
    'screen_on_time',
    'wifi_id_hash',
    'wifi_info_missing',
    'gps_latitude',
    'gps_longitude',
    'gps_location_missing',
    'time_of_day_sin',
    'time_of_day_cos',
    'day_of_week_mon',
    'day_of_week_tue',
    'day_of_week_wed',
    'day_of_week_thu',
    'day_of_week_fri',
    'day_of_week_sat',
    'day_of_week_sun',
    'device_orientation',
    'touch_area',
    'touch_event_count',
    'app_usage_time',
    'timestamp',
    'user_id',
    'session_id',
  ];

  List<String> toCsvRow() => [
    tapDuration.toString(),
    swipeVelocity.toString(),
    touchPressure.toString(),
    tapIntervalAvg.toString(),
    accelVariance.toString(),
    accelVarianceMissing.toString(),
    gyroVariance.toString(),
    gyroVarianceMissing.toString(),
    batteryLevel.toString(),
    chargingState.toString(),
    brightnessLevel.toString(),
    screenOnTime.toString(),
    wifiIdHash.toString(),
    wifiInfoMissing.toString(),
    gpsLatitude.toString(),
    gpsLongitude.toString(),
    gpsLocationMissing.toString(),
    timeOfDaySin.toString(),
    timeOfDayCos.toString(),
    dayOfWeekMon.toString(),
    dayOfWeekTue.toString(),
    dayOfWeekWed.toString(),
    dayOfWeekThu.toString(),
    dayOfWeekFri.toString(),
    dayOfWeekSat.toString(),
    dayOfWeekSun.toString(),
    deviceOrientation.toString(),
    touchArea.toString(),
    touchEventCount.toString(),
    appUsageTime.toString(),
    timestamp?.toIso8601String() ?? '',
    userId ?? '',
    sessionId?.toString() ?? '',
  ];
}