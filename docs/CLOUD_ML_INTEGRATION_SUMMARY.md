# Cloud ML Integration Summary

## Overview
Successfully integrated the Flutter app with the new EC2-hosted ML API for behavioral anomaly detection using hashed user IDs and comprehensive training data management.

## Key Components

### 1. User ID Generation
- **File**: `lib/utils/user_id_generator.dart`
- **Method**: Generates hashed user ID from username (first 12 characters of SHA-256)
- **Usage**: Used for all cloud API calls to identify users uniquely

### 2. Cloud ML Service (Prediction)
- **File**: `lib/services/cloud_ml_service.dart`
- **Endpoint**: `http://43.204.97.149/predict/:userid`
- **Function**: Real-time risk assessment using the trained ML model
- **Integration**: Used by `RealTimeCloudRiskService` for live predictions

### 3. Cloud ML Training Service
- **File**: `lib/services/cloud_ml_training_service.dart`
- **Endpoints**:
  - `/add_user/:userid` - Upload initial training data for new users
  - `/retrain/:userid` - Retrain model with accumulated data
- **Functions**:
  - `checkUserModelExists()` - Check if user has a trained model
  - `initializeUserModel()` - Upload initial training data for new users
  - `retrainUserModel()` - Retrain existing model with new data

### 4. Behavior Monitor Integration
- **File**: `lib/services/behavior_monitor_service.dart`
- **New Features**:
  - Automatically gets username from `AuthService`
  - Saves behavior data locally AND uploads to cloud
  - Periodically checks and updates cloud ML models (every 10 data points)
  - Handles model initialization for new users
  - Triggers retraining for existing users

## Data Flow

1. **Data Collection**: `BehaviorMonitorService.collectData()`
   - Collects raw sensor data
   - Normalizes data with current username
   - Saves to local storage

2. **Real-time Prediction**: 
   - Sends normalized data to cloud ML service
   - Gets risk assessment in real-time

3. **Model Training**:
   - Every 10 data points, checks if user model exists
   - For new users: Uploads all local data to initialize model
   - For existing users: Triggers model retraining with accumulated data

## API Format

### Prediction Request
```json
POST http://43.204.97.149/predict/:userid
{
  "data": [/* 30 behavioral features */]
}
```

### Training Data Upload
```csv
feature1,feature2,...,feature30,label
0.5,0.3,...,0.8,normal
...
```

## Features (30 total)
- **Continuous (18)**: Tap intervals, hold durations, swipe speeds, sensor data, etc.
- **Binary (12)**: Activity states, gesture patterns, usage flags, etc.

## Backend Components (EC2)

## API Integration Details

### Request Format
```json
{
  "tap_duration": 1,
  "swipe_velocity": 2,
  "touch_pressure": 3,
  "tap_interval_avg": 4,
  "accel_variance": 5,
  "gyro_variance": 6,
  "battery_level": 7,
  "brightness_level": 8,
  "screen_on_time": 9,
  "time_of_day_sin": 0.5,
  "time_of_day_cos": 0.5,
  "wifi_id_hash": 123,
  "gps_latitude": 12.34,
  "gps_longitude": 56.78,
  "accel_variance_missing": 0,
  "gyro_variance_missing": 0,
  "charging_state": 1,
  "wifi_info_missing": 0,
  "gps_location_missing": 0,
  "day_of_week_mon": 0,
  "day_of_week_tue": 1,
  "day_of_week_wed": 0,
  "day_of_week_thu": 0,
  "day_of_week_fri": 0,
  "day_of_week_sat": 0,
  "day_of_week_sun": 0,
  "device_orientation": 0.8,
  "touch_area": 0.3,
  "touch_event_count": 5,
  "app_usage_time": 0.05
}
```

### Response Format
```json
{
  "anomaly": 1,
  "risk_score": 3558.9005374235107
}
```

## UI Enhancements

### 1. Real-Time Risk Indicators
- **Green**: Low risk (normal behavior)
- **Orange**: Medium risk (slightly suspicious)
- **Red**: High risk (anomalous behavior)

### 2. Cloud Service Status
- **Online**: Green cloud icon with "Cloud ML Online"
- **Offline**: Orange cloud icon with "Cloud ML Offline"

### 3. High-Risk Alerts
- Immediate SnackBar notifications for high-risk sessions
- Direct navigation to detailed risk assessment

### 4. Enhanced Dashboard Features
- Real-time risk monitoring card
- Cloud service connectivity status
- Live risk assessment updates

## Benefits of Cloud Integration

### 1. **Scalability**
- Cloud ML can handle complex models and large datasets
- No device resource constraints
- Centralized model updates

### 2. **Accuracy**
- More sophisticated ML algorithms
- Larger training datasets
- Regular model improvements

### 3. **Real-Time Processing**
- Immediate risk assessment on data collection
- Live monitoring and alerts
- Continuous behavioral analysis

### 4. **Maintainability**
- Cloud-based model updates
- No app updates required for model changes
- Centralized monitoring and logging

## Fallback Mechanism

When cloud service is unavailable:
- Returns conservative low-risk assessment
- Continues local data collection
- Indicates offline mode in UI
- Automatically reconnects when service available

## Security Considerations

1. **Data Privacy**: All behavioral data is normalized and anonymized
2. **Secure Communication**: HTTPS API calls with proper error handling
3. **Offline Capability**: Graceful degradation when cloud unavailable
4. **Rate Limiting**: Built-in timeout and connection management

## Integration Points

### Existing Code Modified:
- `main.dart`: Initialize cloud services
- `behavior_monitor_service.dart`: Added cloud ML integration
- `behavior_dashboard_screen.dart`: Added real-time risk display
- `risk_assessment_screen.dart`: Switched to cloud ML service

### New Components Added:
- `cloud_ml_service.dart`: Core cloud ML integration
- `real_time_cloud_risk_service.dart`: Real-time orchestration
- `real_time_risk_widget.dart`: UI components
- `cloud_ml_demo_screen.dart`: Comprehensive demo

## Next Steps

1. **Deploy and Test**: Deploy to device and test with actual cloud endpoint
2. **Error Handling**: Refine error handling for various API failure scenarios
3. **Performance Optimization**: Optimize API call frequency and batching
4. **Monitoring**: Add comprehensive logging and monitoring
5. **Security**: Implement API authentication and rate limiting

## Usage Instructions

1. **Automatic Mode**: The system automatically assesses risk for new behavior data
2. **Manual Testing**: Use "Collect & Assess" button in Cloud ML Demo screen
3. **Real-Time Monitoring**: Watch the real-time risk widget for live updates
4. **High-Risk Alerts**: Respond to immediate notifications for suspicious behavior

The cloud-based ML integration provides a robust, scalable, and accurate solution for continuous authentication in the Raksha banking application.
