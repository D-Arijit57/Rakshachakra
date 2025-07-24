import 'package:flutter/material.dart';
import 'package:raksha/services/auth_service.dart';
import 'package:raksha/services/user_data_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _authService = AuthService();
  final UserDataService _userDataService = UserDataService();
  String? _currentUsername;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    _currentUsername = user?.username;
    if (_currentUsername != null) {
      _userName = _userDataService.getUserName(_currentUsername!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _buildDrawerHeader(),
            _buildDrawerItem(
              icon: Icons.home_outlined,
              text: 'Home',
              onTap: () => Navigator.pushNamed(context, '/home'),
            ),
            _buildExpansionTile(
              icon: Icons.payment_outlined,
              title: 'Pay',
              subtitle: 'UPI, Transfer, Cards, Recharge...',
              children: [
                _buildSubDrawerItem(text: 'UPI Payment', onTap: () {
                  Navigator.pushNamed(context, '/upi_payment');
                }),
                _buildSubDrawerItem(text: 'Money Transfer', onTap: () {
                  Navigator.pushNamed(context, '/transfer');
                }),
                _buildSubDrawerItem(text: 'Cards', onTap: () {
                  Navigator.pushNamed(context, '/cards');
                }),
                _buildSubDrawerItem(text: 'Recharge', onTap: () {
                  Navigator.pushNamed(context, '/recharge');
                }),
              ],
            ),
             _buildExpansionTile(
              icon: Icons.savings_outlined,
              title: 'Save',
              subtitle: 'Accounts, Deposits, Safe Deposit Lockers',
              children: [
                _buildSubDrawerItem(text: 'Accounts', onTap: () {
                  Navigator.pushNamed(context, '/accounts');
                }),
                _buildSubDrawerItem(text: 'Deposits', onTap: () {
                  Navigator.pushNamed(context, '/deposits');
                }),
                _buildSubDrawerItem(text: 'Safe Deposit Lockers', onTap: () {
                  Navigator.pushNamed(context, '/safe_deposit_lockers');
                }),
              ],
            ),
             _buildExpansionTile(
              icon: Icons.trending_up,
              title: 'Invest',
              subtitle: 'Demat, Mutual Fund',
              children: [
                _buildSubDrawerItem(text: 'Demat', onTap: () {}),
                _buildSubDrawerItem(text: 'Mutual Funds', onTap: () {}),
              ],
            ),
            const Divider(),
             _buildDrawerItem(
              icon: Icons.person_outline,
              text: 'Your Profile',
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.analytics,
              text: 'Behavior Dashboard',
              onTap: () => Navigator.pushNamed(context, '/behavior_dashboard'),
            ),
            _buildDrawerItem(
              icon: Icons.security,
              text: 'Risk Assessment',
              onTap: () => Navigator.pushNamed(context, '/risk_assessment'),
            ),

            _buildDrawerItem(
              icon: Icons.logout,
              text: 'Logout',
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
            const SizedBox(height: 40),
             Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'App Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 40,
              color: const Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Last Login: ${_authService.currentUser?.lastLogin.toString().substring(0, 16) ?? 'Unknown'}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF667EEA)),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  Widget _buildSubDrawerItem({required String text, required GestureTapCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 70), // Indent sub-items
      child: ListTile(
        title: Text(text),
        onTap: onTap,
      ),
    );
  }
  
  Widget _buildExpansionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: const Color(0xFF667EEA)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      children: children,
    );
  }
}
