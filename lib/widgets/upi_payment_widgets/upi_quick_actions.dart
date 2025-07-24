import 'package:flutter/material.dart';

class UPIQuickActions extends StatelessWidget {
  UPIQuickActions({super.key});

  final List<_QuickAction> actions = const [
    _QuickAction(
      label: 'Send Money',
      icon: Icons.send,
      color: Color(0xFF007BFF),
      route: '/send_money',
    ),
    _QuickAction(
      label: 'Request Money',
      icon: Icons.request_page,
      color: Color(0xFF28A745),
      route: '/request_money',
    ),
    _QuickAction(
      label: 'Scan & Pay',
      icon: Icons.qr_code_scanner,
      color: Color(0xFF764BA2),
      route: '/scan_pay',
    ),
    _QuickAction(
      label: 'Split Bill',
      icon: Icons.group,
      color: Color(0xFFFF6F61),
      route: '/split_bill',
    ),
    _QuickAction(
      label: 'AutoPay',
      icon: Icons.calendar_today,
      color: Color(0xFFFFC107),
      route: '/autopay',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final action = actions[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, action.route),
            child: Card(
              color: action.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SizedBox(
                width: 90,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(action.icon, color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      action.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _QuickAction({required this.label, required this.icon, required this.color, required this.route});
} 