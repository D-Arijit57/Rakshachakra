import 'package:flutter/material.dart';
import 'package:raksha/widgets/app_drawer.dart';
import 'package:raksha/widgets/upi_payment_widgets/upi_quick_actions.dart';
import 'package:raksha/widgets/upi_payment_widgets/upi_recent_transactions.dart';
import 'package:raksha/widgets/upi_payment_widgets/upi_offers_carousel.dart';
import 'package:raksha/widgets/upi_payment_widgets/upi_linked_accounts.dart';

class UPIPaymentScreen extends StatelessWidget {
  const UPIPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'UPI Payments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/upi_settings'),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: UPIQuickActions(),
            ),
            // Linked Accounts & Balance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: UPILinkedAccounts(),
            ),
            const SizedBox(height: 12),
            // Offers Carousel
            UPIOffersCarousel(),
            const SizedBox(height: 12),
            // Recent Transactions
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: UPIRecentTransactions(),
              ),
            ),
            // New Payment Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFF667EEA),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/send_money'),
                  child: const Text(
                    'New Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}