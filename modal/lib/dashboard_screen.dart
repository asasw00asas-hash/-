import 'package:flutter/material.dart';
import 'webview_screen.dart';
import 'bulk_sender_screen.dart';
import 'auto_reply_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const WebviewScreen(),
    const BulkSenderScreen(),
    const AutoReplyScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF020512),
          selectedItemColor: const Color(0xFF00BFFF),
          unselectedItemColor: Colors.white54,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.whatsapp),
              label: 'WhatsApp',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.send_rounded),
              label: 'Bulk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.reply_all_rounded),
              label: 'Auto-Reply',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
