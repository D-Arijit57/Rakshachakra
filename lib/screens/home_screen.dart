import 'package:flutter/material.dart';
import 'package:raksha/widgets/app_drawer.dart';
import 'package:raksha/services/user_data_service.dart';
import 'package:raksha/services/auth_service.dart';
import '../mixins/behavior_monitor_mixin.dart';
import '../screens/add_payee_screen.dart';
import '../screens/bill_payments_screen.dart';
import '../screens/scan_pay_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with BehaviorMonitorMixin {
  int _selectedIndex = 0;
  final UserDataService _userDataService = UserDataService();
  final AuthService _authService = AuthService();
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final userData = await _authService.getUserData(_currentUsername ?? '');
    if (userData != null) {
      setState(() {
        _currentUsername = userData['username'];
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: const Color(0xFF667EEA),
            pinned: true,
            floating: true,
            expandedHeight: 150.0,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.shield_outlined, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'rakshaChakra',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(left: 16, bottom: 16),
                alignment: Alignment.bottomLeft,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildAccountCard()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
            ),
          ),
          _buildQuickActions(),
        ],
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Pay',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings_outlined),
            label: 'Save',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Invest',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF667EEA),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildAccountCard() {
    if (_currentUsername == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Loading account information...'),
        ),
      );
    }

    final balance = _userDataService.getUserBalance(_currentUsername!);
    final accountType = _userDataService.getUserAccount(_currentUsername!).accountType;
    final accountNumber = _userDataService.getUserAccount(_currentUsername!).maskedAccountNumber;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/accounts');
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ACCOUNTS',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        accountType,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '₹${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        accountNumber,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              ],
            ),
            const Divider(height: 30),
            Center(
              child: Text(
                'View All',
                style: TextStyle(
                  color: const Color(0xFF667EEA),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  SliverGrid _buildQuickActions() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      delegate: SliverChildListDelegate(
        [
          _buildActionItem(Icons.receipt_long, 'Bill Payments', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BillPaymentsScreen()),
            );
          }),
          _buildActionItem(Icons.swap_horiz, 'Transfer', () {
            Navigator.pushNamed(context, '/transfer');
          }),
          _buildActionItem(Icons.person_add_alt_1_outlined, 'Add Payee', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPayeeScreen()),
            );
          }),
          _buildActionItem(Icons.qr_code_scanner, 'Scan & Pay', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanPayScreen()),
            );
          }),
          _buildActionItem(Icons.battery_charging_full, 'Recharge', () {
            Navigator.pushNamed(context, '/recharge');
          }),
          _buildActionItem(Icons.send_to_mobile, 'UPI Payment', () {
            Navigator.pushNamed(context, '/upi_payment');
          }),
          _buildActionItem(Icons.analytics, 'Behavior Dashboard', () {
            Navigator.pushNamed(context, '/behavior_dashboard');
          }),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFF667EEA), size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
