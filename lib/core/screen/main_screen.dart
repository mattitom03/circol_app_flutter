import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../../features/home/home_fragment.dart';
import '../../features/events/screen/eventi_fragment.dart';
import '../../features/products/screen/product_catalog_fragment.dart';
import '../../features/profile/profilo_fragment.dart';
import '../../screens/chat_fragment.dart';
import '../../screens/qr_code_fragment.dart';
import '../../screens/notifiche_fragment.dart';
import '../../features/orders/screen/order_screen.dart';

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
        const OrdersScreen(),
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
          icon: Icon(Icons.receipt_long),
          label: 'Ordini',
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
