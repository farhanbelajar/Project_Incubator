import 'package:bayi/Setting/Main_Page.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> slides = [
    {
      "title": "Smart Baby Incubator Monitoring",
      "desc":
      "Aplikasi untuk memantau kondisi inkubator bayi secara real-time menggunakan teknologi IoT.",
      "icon": "incubator"
    },
    {
      "title": "Monitoring Suhu & Detak Bayi",
      "desc":
      "Memantau suhu inkubator dan detak jantung bayi agar kondisi tetap stabil dan aman.",
      "icon": "heart"
    },
    {
      "title": "Live Camera Monitoring",
      "desc":
      "Melihat kondisi bayi di dalam inkubator melalui kamera secara langsung dari aplikasi.",
      "icon": "camera"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double scale = size.width / 375;

    double titleSize = (26 * scale).clamp(22, 38);
    double descSize = (15 * scale).clamp(13, 20);
    double iconSize = (130 * scale).clamp(100, 220);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              /// PAGE VIEW
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (index) {
                    setState(() => currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          /// ICON
                          Icon(
                            _getIcon(slides[index]["icon"]!),
                            size: iconSize,
                            color: Colors.greenAccent,
                          ),

                          const SizedBox(height: 40),

                          /// TITLE
                          Text(
                            slides[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// DESCRIPTION
                          Text(
                            slides[index]["desc"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: descSize,
                              color: Colors.white70,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              /// DOT INDICATOR
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: currentPage == index ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? Colors.greenAccent
                          : Colors.white30,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (currentPage == slides.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Mainpage(),
                        ),
                      );
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    currentPage == slides.length - 1
                        ? "GET STARTED"
                        : "NEXT",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case "incubator":
        return Icons.child_care;
      case "heart":
        return Icons.monitor_heart;
      case "camera":
        return Icons.videocam;
      default:
        return Icons.health_and_safety;
    }
  }
}