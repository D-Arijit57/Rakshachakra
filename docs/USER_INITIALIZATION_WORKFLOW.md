# User Initialization Workflow After Login

## Overview
Proper workflow implementation for initializing users after login with cloud ML API integration.

## Step-by-Step Process

### 1. Login Completion
- User successfully logs in with credentials stored in Firebase
- AuthService sets the current user

### 2. Username Hashing & User ID Generation
- Hash the username using SHA-256
- Take first 12 characters as the user ID
- Save this user ID for future use in multiple places

### 3. Test Prediction API
- Test if `/predict/userid` API is working
- Send dummy behavioral data to check if user model exists
- If successful → User model exists, proceed with normal operation

### 4. Add New User (if prediction fails)
- If prediction API fails → User model doesn't exist
- Call `/add_user/userid` API to initialize the user
- Upload CSV file with initial training data from local storage

### 5. Verification
- After adding user, test prediction API again
- Confirm the user model is now working

## Implementation Details

### Files Created/Modified:

#### New File: `UserInitializationService`
```dart
lib/services/user_initialization_service.dart
```
- Manages complete user initialization workflow
- Handles user ID generation and storage
- Tests prediction API with dummy data
- Adds new users with training data if needed

#### Modified: `AuthService`
```dart
lib/services/auth_service.dart
```
- Calls `UserInitializationService.initializeUserAfterLogin()` after successful login
- Clears user ID on logout

#### Modified: `CloudMLService`
```dart
lib/services/cloud_ml_service.dart
```
- Uses cached user ID from `UserInitializationService`
- Fallback to generating user ID if cache miss

## API Workflow

### Test Prediction API
```http
POST http://43.204.97.149/predict/{userid}
Content-Type: application/json

{
  "tap_duration": 0.15,
  "swipe_velocity": 0.35,
  // ... all 30 behavioral features
}
```

**Success Response:**
```json
{
  "anomaly": 0,
  "risk_score": 1234.567
}
```

### Add New User API
```http
POST http://43.204.97.149/add_user/{userid}
Content-Type: multipart/form-data

file: training_data.csv
```

**CSV Format:**
```csv
tap_duration,swipe_velocity,touch_pressure,...,label
0.15,0.35,0.6,...,normal
0.12,0.40,0.55,...,normal
...
```

## Expected Log Output

```
🚀 Starting user initialization after login...
👤 Username: deepam
🆔 Generated User ID: 17ff4c590c24
💾 User ID saved to local storage: 17ff4c590c24
🧪 Testing prediction API with dummy data...
🌐 Testing URL: http://43.204.97.149/predict/17ff4c590c24
⚠️ Prediction API failed with status: 404
📊 Adding new user with initial training data...
🌐 Adding user at URL: http://43.204.97.149/add_user/17ff4c590c24
📊 Found 25 behavioral data records for training
📤 Uploading 2543 characters of CSV training data...
✅ User added successfully
🧪 Testing prediction API with dummy data...
✅ Prediction API response: {"anomaly": 0, "risk_score": 1234.567}
✅ Prediction API now working after user initialization
✅ User initialization completed successfully
```

## Key Features

1. **Automatic User ID Management**: Generated once, cached, used everywhere
2. **Smart API Testing**: Tests prediction before assuming user exists
3. **Seamless Initialization**: Automatically adds new users with training data
4. **Robust Error Handling**: Graceful fallbacks and detailed logging
5. **Persistent Storage**: User ID saved for future app sessions

## Usage

The workflow is automatically triggered after login. No manual intervention required.

```dart
// In AuthService.login() method:
final userInitService = UserInitializationService();
final initSuccess = await userInitService.initializeUserAfterLogin();
```

## Benefits

- **Eliminates Manual Setup**: No need to manually add users to the ML system
- **Consistent User IDs**: Same ID used across all cloud ML operations
- **Automatic Training Data**: Uses existing local behavioral data for initialization
- **Seamless Integration**: Works with existing authentication flow
- **Robust Error Handling**: Handles network issues and API failures gracefully
