import 'package:flutter/material.dart';

import '../core/constants.dart';
import 'images_screen.dart';
import 'upload_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            UploadScreen(onUploaded: () => _goTo(1)),
            const ImagesScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navBg,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: _goTo,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.green,
          unselectedItemColor: AppColors.text,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 32),
              label: 'Upload',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined, size: 30),
              label: 'Images',
            ),
          ],
        ),
      ),
    );
  }
}
