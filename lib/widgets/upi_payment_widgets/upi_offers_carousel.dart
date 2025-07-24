import 'package:flutter/material.dart';

class UPIOffersCarousel extends StatefulWidget {
  UPIOffersCarousel({super.key});

  @override
  State<UPIOffersCarousel> createState() => _UPIOffersCarouselState();
}

class _UPIOffersCarouselState extends State<UPIOffersCarousel> {
  final List<_OfferBanner> offers = const [
    _OfferBanner(
      title: '5% Cashback at Cafe Coffee Day',
      description: 'Pay with UPI and get instant cashback!',
      color: Color(0xFF007BFF),
    ),
    _OfferBanner(
      title: 'Flat ₹50 Off on Zomato',
      description: 'Use UPI for your next order.',
      color: Color(0xFFFF6F61),
    ),
    _OfferBanner(
      title: 'Win Movie Tickets',
      description: 'Transact 3 times this week via UPI.',
      color: Color(0xFF28A745),
    ),
  ];
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 90,
          child: PageView.builder(
            itemCount: offers.length,
            controller: PageController(viewportFraction: 0.88),
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) {
              final offer = offers[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: offer.color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: offer.color.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      offer.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      offer.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            offers.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _current ? offers[i].color : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfferBanner {
  final String title;
  final String description;
  final Color color;
  const _OfferBanner({required this.title, required this.description, required this.color});
} 