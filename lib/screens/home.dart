import 'package:flutter/material.dart';
import 'package:sistema_de_reservas/screens/DetalleReserva.dart';

import 'CreateReservas.dart';
import 'horario_disponible.dart';
import 'CreateReservas.dart';
import '../util/colores.dart';
import '../util/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MisReservas.dart';
import 'Perfil.dart';

class PantallaHome extends StatefulWidget {
  const PantallaHome({super.key});

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _categories = const [
    {'label': 'Gym', 'icon': Icons.fitness_center, 'color': Color(0xFF4F8CFF)},
    {'label': 'Pool', 'icon': Icons.pool, 'color': Color(0xFF27C1D9)},
    {'label': 'Meeting', 'icon': Icons.groups_2, 'color': Color(0xFF6A63FF)},
    {'label': 'Lounge', 'icon': Icons.weekend, 'color': Color(0xFF17B978)},
    {'label': 'Events', 'icon': Icons.event, 'color': Color(0xFFFF9F1C)},
  ];

  final List<Map<String, dynamic>> _featuredFacilities = const [
    {
      'title': 'Rooftop Infinity Pool',
      'subtitle': 'Heated salt-water pool with skyline views',
      'tag': 'Trending',
      'image':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
    },
    {
      'title': 'Zen Yoga Studio',
      'subtitle': 'Peaceful space for mind and body',
      'tag': 'New',
      'image':
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=1200&q=80',
    },
  ];

  final List<Map<String, dynamic>> _availableNow = const [
    {
      'label': 'GYM',
      'title': 'Main Fitness\nCenter',
      'capacity': 'Capacity: 25 People',
      'status': 'AVAILABLE',
      'image':
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1200&q=80',
      'statusColor': Color(0xFF22C55E),
    },
    {
      'label': 'MEETING',
      'title': 'Conference\nRoom B',
      'capacity': 'Capacity: 8 People',
      'status': 'BUSY',
      'image':
          'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1200&q=80',
      'statusColor': Color(0xFFFF5A5F),
    },
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
    BottomNavigationBarItem(
      icon: Icon(Icons.explore_outlined),
      label: 'Explore',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month_outlined),
      label: 'Bookings',
    ),
    BottomNavigationBarItem(icon: _AlertsIcon(), label: 'Alerts'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
  ];

  late final List<Widget> _pages = [
    _HomeTab(
      categories: _categories,
      featuredFacilities: _featuredFacilities,
      availableNow: _availableNow,
    ),
    PantallaHorario(),
    PantallaMisReservas(),
    PantallaDetalleReserva(reserva: {}),
    PantallaPerfil(),
  ];

  void _openCreateReserva() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaCreateReserva()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF4AA3FF);

    return Scaffold(
      backgroundColor: const Color(0xFF111417),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              elevation: 8,
              backgroundColor: accent,
              onPressed: _openCreateReserva,
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF12161A),
        elevation: 0,
        selectedItemColor: accent,
        unselectedItemColor: const Color(0xFF758396),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        iconSize: 26,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: _navItems,
      ),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> featuredFacilities;
  final List<Map<String, dynamic>> availableNow;

  const _HomeTab({
    required this.categories,
    required this.featuredFacilities,
    required this.availableNow,
  });

  @override
  Widget build(BuildContext context) {
    const textMain = Colors.white;
    const textSecondary = Color(0xFF94A3B8);

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF111417), Color(0xFF0F1418), Color(0xFF111417)],
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 18),
              Text(
                'Hi, Resident! 👋',
                style: TextStyle(
                  color: textMain,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'What would you like to reserve today?',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              _buildSearchBar(),
              const SizedBox(height: 18),
              _buildSectionHeader(
                title: 'Categories',
                actionText: 'See All',
                onTap: () {},
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    return _CategoryItem(
                      label: item['label'] as String,
                      icon: item['icon'] as IconData,
                      color: item['color'] as Color,
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Featured Facilities',
                style: TextStyle(
                  color: textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredFacilities.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = featuredFacilities[index];
                    return _FeaturedCard(
                      width: 270,
                      imageUrl: item['image'] as String,
                      tag: item['tag'] as String,
                      title: item['title'] as String,
                      subtitle: item['subtitle'] as String,
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Text(
                        'Available Now',
                        style: TextStyle(
                          color: textMain,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.circle, size: 8, color: Color(0xFF22C55E)),
                    ],
                  ),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableNow.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = availableNow[index];
                    return _AvailableCard(
                      width: 175,
                      imageUrl: item['image'] as String,
                      label: item['label'] as String,
                      title: item['title'] as String,
                      capacity: item['capacity'] as String,
                      status: item['status'] as String,
                      statusColor: item['statusColor'] as Color,
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              _buildWeekCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF20262C),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.flash_on_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const Text(
          'ResiBook',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2026),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF232B33)),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Color(0xFF8E9BAA), size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search facilities or equipment...',
              style: TextStyle(
                color: Color(0xFF73808E),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                actionText,
                style: const TextStyle(
                  color: Color(0xFF8FA3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF8FA3B8),
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E3552),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF11486E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: Color(0xFF7FC8FF),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR WEEK',
                  style: TextStyle(
                    color: Color(0xFF7FC8FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '3 Reservations confirmed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Next: Rooftop Pool today at 4:00 PM',
                  style: TextStyle(
                    color: Color(0xFFC5D3E2),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF7FC8FF),
            size: 26,
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB8C4D1),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final double width;
  final String imageUrl;
  final String tag;
  final String title;
  final String subtitle;

  const _FeaturedCard({
    required this.width,
    required this.imageUrl,
    required this.tag,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF1B2127),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: const Color(0xFF2B333B),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white54,
                      size: 34,
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.transparent,
                    Colors.black.withOpacity(0.78),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF5DA9FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE6EDF5),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailableCard extends StatelessWidget {
  final double width;
  final String imageUrl;
  final String label;
  final String title;
  final String capacity;
  final String status;
  final Color statusColor;

  const _AvailableCard({
    required this.width,
    required this.imageUrl,
    required this.label,
    required this.title,
    required this.capacity,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF191E23),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF262D35)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 126,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: const Color(0xFF2A3138),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.white54,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.08),
                          Colors.transparent,
                          Colors.black.withOpacity(0.35),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF6FE58F),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    capacity,
                    style: const TextStyle(
                      color: Color(0xFF98A6B5),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertsIcon extends StatelessWidget {
  const _AlertsIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none_outlined),
        Positioned(
          right: -1,
          top: -1,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5A5F),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF12161A), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _AlertsPage extends StatelessWidget {
  const _AlertsPage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111417),
      child: const Center(
        child: Text(
          'Alerts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
