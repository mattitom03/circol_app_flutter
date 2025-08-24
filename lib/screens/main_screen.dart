import 'package:flutter/material.dart';
import '../models/user_role.dart';
import 'fragments/home_fragment.dart';
import 'fragments/eventi_fragment.dart';
import 'fragments/product_catalog_fragment.dart';
import 'fragments/profilo_fragment.dart';
import 'fragments/chat_fragment.dart';
import 'fragments/qr_code_fragment.dart';
import 'fragments/notifiche_fragment.dart';

class MainScreen extends StatefulWidget {
  final UserRole userRole;

  const MainScreen({
    super.key,
    required this.userRole,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _bottomNavItems;

  @override
  void initState() {
    super.initState();
    _setupNavigationBasedOnRole();
  }

  void _setupNavigationBasedOnRole() {
    if (widget.userRole == UserRole.admin) {
      // Configurazione per ADMIN
      _pages = [
        const ProductCatalogFragment(),
        const EventiFragment(),
        const ChatFragment(),
        const NotificheFragment(),
        const ProfiloFragment(),
      ];

      _bottomNavItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Catalogo',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Eventi',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifiche',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profilo',
        ),
      ];
    } else {
      // Configurazione per USER normale
      _pages = [
        const HomeFragment(),
        const EventiFragment(),
        const QrCodeFragment(),
        const ChatFragment(),
        const ProfiloFragment(),
      ];

      _bottomNavItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Eventi',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.qr_code),
          label: 'QR Code',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profilo',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: _bottomNavItems,
      ),
    );
  }
}
