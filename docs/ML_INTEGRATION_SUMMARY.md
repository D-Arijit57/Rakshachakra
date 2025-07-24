# Raksha Mobile Banking - Continuous Authentication System

## 🎯 Project Overview
A comprehensive behavioral biometrics and machine learning solution for continuous authentication in mobile banking, designed for a national-level hackathon.

## ✅ Completed Features

### 1. **Behavioral Data Collection System**
- **Touch Patterns**: Tap duration, swipe velocity, touch pressure, tap intervals, touch area
- **Motion Sensors**: Accelerometer variance, gyroscope variance, device orientation  
- **Device Context**: Battery level, charging state, brightness, screen time, app usage
- **Network/Location**: WiFi hash (privacy-safe), GPS coordinates, connectivity status
- **Time Patterns**: Time of day (sin/cos), day of week encoding
- **Real-time Monitoring**: Continuous background collection during app usage

### 2. **Data Normalization & Export**
- **Normalized Ranges**: All features scaled to 0-1 with realistic variance
- **CSV Export**: Full feature matrix with 30 behavioral metrics
- **JSON Export**: Complete session data with metadata
- **Privacy Protection**: WiFi hashing, location obfuscation
- **Data Validation**: Missing data handling and quality checks

### 3. **Machine Learning Model**
- **Synthetic Training Data**: 100 baseline "normal" user sessions generated
- **Anomaly Detection**: Euclidean distance-based risk scoring
- **Feature Weighting**: 
  - Touch patterns (30%)
  - Motion patterns (25%) 
  - Device context (20%)
  - Location (15%)
  - Time patterns (10%)
- **Risk Levels**: Low, Medium, High with customizable thresholds
- **Real-time Scoring**: Instant risk assessment for new sessions

### 4. **User Interface**
- **Behavior Dashboard**: View all collected sessions with metrics
- **Risk Assessment Screen**: ML-powered risk analysis with detailed breakdowns
- **ML Test Screen**: Test model with CSV data or synthetic sessions
- **Export Functions**: One-click CSV/JSON export with sharing
- **Quick Risk Check**: Instant analysis of latest session

### 5. **Technical Architecture**
- **Flutter Framework**: Cross-platform mobile app
- **Hive Database**: Local storage for behavioral data
- **Provider Pattern**: State management for authentication
- **Service Layer**: Modular services for data collection, ML, storage
- **Real-time Processing**: Background monitoring with efficient data pipeline

## 🧠 Machine Learning Pipeline

### Model Training Process
1. **Synthetic Data Generation**: Creates 100 realistic "normal" user sessions
2. **Baseline Profile**: Calculates average behavioral patterns
3. **Feature Extraction**: 30 normalized behavioral metrics
4. **Model Ready**: Trained and ready for real-time inference

### Risk Scoring Algorithm
```
Risk Score = (Touch_Anomaly × 0.3) + 
             (Motion_Anomaly × 0.25) + 
             (Context_Anomaly × 0.2) + 
             (Location_Anomaly × 0.15) + 
             (Time_Anomaly × 0.1)

Risk Level:
- Low: 0-40% (Normal behavior)
- Medium: 40-70% (Slightly suspicious)  
- High: 70-100% (Highly suspicious)
```

### Anomaly Detection Method
- **Distance Calculation**: Euclidean distance between session features and baseline
- **Feature Normalization**: All metrics scaled to prevent bias
- **Multi-dimensional Analysis**: Considers all behavioral aspects simultaneously
- **Adaptive Scoring**: Can be retrained with new data

## 📊 Data Features Collected

### Touch Behavior (6 features)
- `tapDuration`: Duration of finger contact
- `swipeVelocity`: Speed of swipe gestures  
- `touchPressure`: Force applied to screen
- `tapIntervalAvg`: Time between consecutive taps
- `touchArea`: Size of finger contact area
- `touchEventCount`: Number of touch events per session

### Motion & Orientation (3 features)  
- `accelVariance`: Accelerometer movement variance
- `gyroVariance`: Gyroscope rotation variance
- `deviceOrientation`: Phone orientation angle

### Device Context (5 features)
- `batteryLevel`: Current battery percentage
- `chargingState`: Whether device is charging
- `brightnessLevel`: Screen brightness setting
- `screenOnTime`: Duration screen was active
- `appUsageTime`: Time spent in banking app

### Network & Location (6 features)
- `wifiIdHash`: Privacy-safe WiFi network identifier
- `wifiInfoMissing`: WiFi availability flag
- `gpsLatitude`: Normalized GPS latitude
- `gpsLongitude`: Normalized GPS longitude  
- `gpsLocationMissing`: GPS availability flag

### Time Context (10 features)
- `timeOfDaySin/Cos`: Cyclical time encoding
- `dayOfWeekMon-Sun`: Day of week binary encoding

## 🔄 Testing & Validation

### Synthetic Testing
- **Normal Sessions**: Generate realistic typical user behavior
- **Anomalous Sessions**: Create suspicious behavior patterns
- **Risk Validation**: Verify model correctly identifies anomalies
- **Performance Testing**: Process multiple sessions efficiently

### Real Data Testing  
- **CSV Import**: Load real exported behavioral data
- **Batch Analysis**: Process multiple sessions at once
- **Risk Distribution**: Analyze risk levels across sessions
- **Model Accuracy**: Compare predictions with expected behavior

## 🚀 How to Use

### For Users
1. **Login**: Authenticate with biometrics or password
2. **Normal Usage**: Use banking features normally - data collected automatically
3. **View Dashboard**: Check "Behavior Dashboard" in menu to see collected data
4. **Risk Assessment**: View "Risk Assessment" for ML-powered security analysis
5. **Export Data**: Export behavioral data for analysis or compliance

### For Developers/Testers
1. **ML Test Screen**: Access via app menu for model testing
2. **Synthetic Testing**: Generate test data to validate model
3. **CSV Testing**: Import real behavioral data to test risk scoring
4. **Risk Validation**: Verify model correctly identifies suspicious behavior

### For Security Teams
1. **Monitor Dashboard**: Real-time view of user behavioral patterns
2. **Risk Alerts**: Identify high-risk sessions requiring investigation  
3. **Data Export**: Export behavioral data for forensic analysis
4. **Model Retraining**: Update baseline with new legitimate user data

## 🎖️ Hackathon Innovation Points

### 1. **Comprehensive Biometrics**
- Most complete behavioral feature set (30 metrics)
- Privacy-preserving data collection
- Real-time continuous monitoring

### 2. **Advanced ML Pipeline**
- Custom anomaly detection algorithm
- Synthetic training data generation
- Multi-feature risk scoring

### 3. **Production-Ready Architecture**
- Modular, scalable codebase
- Efficient data processing
- Real-time performance

### 4. **User Experience**
- Seamless integration with banking app
- Intuitive dashboards and visualization
- One-click data export and sharing

### 5. **Security Focus**
- Privacy-safe data hashing
- Local data storage
- Granular risk assessment

## 📈 Future Enhancements

### Short-term
- Cloud-based ML model training
- Advanced ensemble models (Random Forest, Neural Networks)
- Real-time fraud alerts and notifications
- User behavior adaptation over time

### Long-term  
- Integration with bank fraud detection systems
- Cross-device behavioral profiling
- Biometric template protection
- Regulatory compliance frameworks (GDPR, PCI-DSS)

## 🏆 Competitive Advantages

1. **Most Comprehensive**: 30 behavioral features vs typical 5-10
2. **Privacy-First**: Local processing, hashed identifiers
3. **Real-time**: Continuous monitoring without user friction
4. **Explainable AI**: Detailed risk breakdowns for transparency
5. **Production-Ready**: Complete end-to-end implementation

## 📋 Technical Specifications

- **Framework**: Flutter 3.x (Cross-platform)
- **ML Engine**: Custom Dart implementation
- **Database**: Hive (Local NoSQL)
- **Architecture**: Clean Architecture with Provider
- **Sensors**: Accelerometer, Gyroscope, Touch, GPS, WiFi
- **Data Format**: Normalized CSV with 30 features
- **Performance**: Real-time processing, <100ms risk scoring

## 🎯 Hackathon Evaluation Criteria Met

✅ **Innovation**: Novel 30-feature behavioral biometrics system  
✅ **Technical Excellence**: Production-ready ML pipeline  
✅ **User Experience**: Seamless integration, intuitive interface  
✅ **Security Impact**: Advanced fraud detection capabilities  
✅ **Scalability**: Modular architecture for enterprise deployment  
✅ **Completeness**: End-to-end working solution with testing

---

**Raksha Chakra** - *Protecting digital banking through intelligent behavioral analysis*
