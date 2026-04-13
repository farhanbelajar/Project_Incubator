import 'package:bayi/UI/AboutPage.dart';
import 'package:bayi/UI/CameraPage.dart';
import 'package:bayi/UI/Data_Sensor.dart';
import 'package:bayi/UI/Incubator2.dart';
import 'package:bayi/UI/Incubator3.dart';
import 'package:flutter/material.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  final PageController _pageController = PageController();

  int awalIndex = 0;

  late final List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _children = const [
     DataSensor(),
      Incubator2(),
      Incubator3(),
      Camerapage(),
      Aboutpage()
    ];
  }

  void tap(int index) {
    setState(() {
      awalIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  BottomNavigationBarItem _buildItem(
      IconData icon, String label, bool active) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF3B7DDD).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 24,
          color: active
              ? const Color(0xFF3B7DDD)
              : Colors.grey[600],
        ),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FB),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: _children,
          onPageChanged: (index) {
            setState(() {
              awalIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            )
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: awalIndex,
            onTap: tap,
            selectedItemColor: const Color(0xFF3B7DDD),
            unselectedItemColor: Colors.grey[600],
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w400),
            items: [
              _buildItem(Icons.home_rounded, 'Home', awalIndex == 0),
              _buildItem(Icons.bedroom_baby, 'Incu2', awalIndex == 1),
              _buildItem(Icons.bedroom_baby, 'Incu3', awalIndex == 2),
              _buildItem(Icons.camera_alt, 'Camera', awalIndex == 4),
              _buildItem(Icons.info_outline_rounded, 'About', awalIndex == 5),
            ],
          ),
        ),
      ),
    );
  }
}