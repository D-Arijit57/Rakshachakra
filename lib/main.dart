import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raksha/screens/home_screen.dart';
import 'package:raksha/screens/login_screen.dart';
import 'package:raksha/screens/transactions_screen.dart';
import 'package:raksha/screens/transfer_screen.dart';
import 'package:raksha/screens/accounts_screen.dart';
import 'package:raksha/screens/cards_screen.dart';
import 'package:raksha/screens/deposits_screen.dart';
import 'package:raksha/screens/recharge_screen.dart';
import 'package:raksha/screens/safe_deposit_lockers_screen.dart';
import 'package:raksha/screens/upi_payment/upi_payment_screen.dart';
import 'package:raksha/screens/behavior_dashboard_screen.dart';
import 'package:raksha/screens/risk_assessment_screen.dart';
import 'package:raksha/services/auth_service.dart';
import 'package:raksha/models/user.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raksha/services/behavior_monitor_service.dart';
import 'package:raksha/services/touch_event_service.dart';
import 'package:raksha/services/real_time_cloud_risk_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Hive.initFlutter();
  await Hive.openBox('behaviorData');
  
  // Initialize auth service
  await AuthService().initialize();

  // Initialize cloud-based risk assessment service
  await RealTimeCloudRiskService().initialize();

  // Initialize and start behavior monitoring service
  final behaviorMonitor = BehaviorMonitorService();
  await behaviorMonitor.initialize();
  behaviorMonitor.start();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          // Start tap timer
          TouchEventTracker.instance.onPointerDown(event);
        },
        onPointerUp: (event) {
          TouchEventTracker.instance.onPointerUp(event);
        },
        onPointerMove: (event) {
          TouchEventTracker.instance.onPointerMove(event);
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Raksha',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: const Color(0xFF667EEA),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF667EEA),
              brightness: Brightness.light,
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF667EEA),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
              ),
            ),
          ),
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/accounts': (context) => const AccountsScreen(),
            '/transfer': (context) => const TransferScreen(),
            '/transactions': (context) => const TransactionsScreen(),
            '/cards': (context) => const CardsScreen(),
            '/deposits': (context) => const DepositsScreen(),
            '/recharge': (context) => const RechargeScreen(),
            '/safe_deposit_lockers': (context) => const SafeDepositLockersScreen(),
            '/upi_payment': (context) => const UPIPaymentScreen(),
            '/behavior_dashboard': (context) => const BehaviorDashboardScreen(),
            '/risk_assessment': (context) => const RiskAssessmentScreen(),
          },
        ),
      ),
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => _authService.isLoggedIn;
  
  Future<bool> login(String username, String password) async {
    final success = await _authService.login(username, password);
    if (success) {
      notifyListeners();
    }
    return success;
  }
  
  Future<bool> loginWithBiometrics() async {
    final success = await _authService.loginWithBiometrics();
    if (success) {
      notifyListeners();
    }
    return success;
  }
  
  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
