# Raksha Behavioral Anomaly Detection Model - Local Training

This guide will help you train the behavioral anomaly detection model locally and save the trained model files (.h5 and .pkl).

## Prerequisites

- Python 3.8 or higher
- Your training data file: `behavioral_training_data_6000_correlated.csv`

## Installation

### Method 1: Using the install script (Recommended)

1. **Run the installation script:**
   ```bash
   python install_requirements.py
   ```

### Method 2: Using batch file (Windows)

1. **Double-click on `install_requirements.bat`** or run it from command prompt

### Method 3: Manual installation

1. **Install required packages:**
   ```bash
   pip install tensorflow>=2.12.0
   pip install scikit-learn>=1.3.0
   pip install pandas>=2.0.0
   pip install numpy>=1.24.0
   pip install joblib>=1.3.0
   ```

## Training the Model

1. **Ensure your training data is in the correct location:**
   - Place `behavioral_training_data_6000_correlated.csv` in `C:\Users\Dell\Downloads\`
   - Or update the path in the script if it's elsewhere

2. **Run the training script:**
   ```bash
   python behavioral_anomaly_autoencoder.py
   ```

## Output Files

After successful training, you will get:

1. **`autoencoder_model.h5`** - The trained TensorFlow model
2. **`scaler.pkl`** - The feature scaler for data preprocessing

Both files will be saved in `C:\Users\Dell\Downloads\`

## Training Data Format

The script expects a CSV file with the following 30 columns:

### Continuous Features (18):
- `tap_duration`, `swipe_velocity`, `touch_pressure`, `tap_interval_avg`
- `accel_variance`, `gyro_variance`, `battery_level`, `brightness_level`
- `screen_on_time`, `time_of_day_sin`, `time_of_day_cos`
- `wifi_id_hash`, `gps_latitude`, `gps_longitude`
- `device_orientation`, `touch_area`, `touch_event_count`, `app_usage_time`

### Binary Features (12):
- `accel_variance_missing`, `gyro_variance_missing`, `charging_state`
- `wifi_info_missing`, `gps_location_missing`
- `day_of_week_mon`, `day_of_week_tue`, `day_of_week_wed`
- `day_of_week_thu`, `day_of_week_fri`, `day_of_week_sat`, `day_of_week_sun`

## Model Architecture

- **Input Layer**: 30 features (18 continuous + 12 binary)
- **Hidden Layers**: 32 → 16 → 32 neurons (ReLU activation)
- **Output Layer**: 30 features (Linear activation)
- **Loss Function**: Mean Squared Error (MSE)
- **Optimizer**: Adam

## Anomaly Detection

The model uses reconstruction error to detect anomalies:
- **Threshold**: 95th percentile of reconstruction errors
- **Risk Score**: Normalized reconstruction error (0-1)
- **Anomaly Flag**: 1 if error > threshold, 0 otherwise

## Usage Example

After training, you can use the model like this:

```python
import joblib
from tensorflow.keras.models import load_model
import numpy as np

# Load saved model and scaler
model = load_model('autoencoder_model.h5')
scaler = joblib.load('scaler.pkl')

# Example session data
session = {
    'tap_duration': 0.15,
    'swipe_velocity': 0.75,
    # ... (all 30 features)
}

# Score the session
def score_session(session_dict, model, scaler, threshold):
    # Extract features in correct order
    continuous_features = [...]  # Your feature list
    binary_features = [...]      # Your feature list
    
    cont_vals = [session_dict[feat] for feat in continuous_features]
    bin_vals = [session_dict[feat] for feat in binary_features]
    
    # Scale and predict
    scaled_cont = scaler.transform([cont_vals])
    full_input = np.hstack([scaled_cont, [bin_vals]])
    reconstructed = model.predict(full_input)
    
    # Calculate reconstruction error
    error = np.mean(np.square(full_input - reconstructed), axis=1)[0]
    is_anomaly = 1 if error > threshold else 0
    
    return error, is_anomaly
```

## Troubleshooting

### Common Issues:

1. **TensorFlow Installation Issues:**
   - Make sure you have Python 3.8-3.11 (TensorFlow may not support newer versions)
   - Try: `pip install tensorflow-cpu` if you don't have GPU support

2. **Memory Issues:**
   - Reduce batch size in the training script
   - Close other applications to free up RAM

3. **File Path Issues:**
   - Use absolute paths
   - Ensure the training data file exists in the specified location

4. **Missing Dependencies:**
   - Run the installation script again
   - Check your Python version: `python --version`

## Model Performance

The script will output:
- Training progress and validation loss
- Reconstruction error statistics
- Sample risk scores
- Anomaly threshold value

Monitor these metrics to ensure the model is training properly.

## Integration with Raksha App

The trained model files can be integrated with your Flutter app's cloud ML service for real-time behavioral anomaly detection.
