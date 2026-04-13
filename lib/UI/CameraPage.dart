import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

class Camerapage extends StatefulWidget {
  const Camerapage({super.key});

  @override
  State<Camerapage> createState() => _CamerapageState();
}

class _CamerapageState extends State<Camerapage> {
  List<Map<String, dynamic>> imageList = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchImagesFromSupabase();

    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchImagesFromSupabase();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ================= FETCH =================
  Future<void> fetchImagesFromSupabase() async {
    final storage = Supabase.instance.client.storage;
    final files = await storage.from('fotobayi').list();

    final newList = <Map<String, dynamic>>[];

    for (var file in files) {
      final url = storage.from('fotobayi').getPublicUrl(file.name);

      DateTime? date;

      try {
        // 🔥 PARSE DARI NAMA FILE
        final name = file.name
            .replaceAll("esp32_", "")
            .replaceAll(".jpg", "");

        date = DateFormat("yyyyMMdd_HHmmss").parse(name).toLocal();
      } catch (e) {
        debugPrint("Parse error: $e");
      }

      newList.add({
        'url': url,
        'date': date,
      });
    }

    // 🔥 SORT TERBARU DI ATAS
    newList.sort((a, b) {
      final d1 = a['date'] ?? DateTime(2000);
      final d2 = b['date'] ?? DateTime(2000);
      return d2.compareTo(d1);
    });

    setState(() => imageList = newList);
  }

  // ================= FORMAT DATE =================
  String formatDate(DateTime? date) {
    if (date == null) return "Unknown";

    return DateFormat('dd MMM yyyy • HH:mm').format(date);
  }

  // ================= ZOOM =================
  void openImage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(title: const Text("Detail Foto")),
          body: PhotoView(
            imageProvider: CachedNetworkImageProvider(url),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget header() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff1E3C72), Color(0xff2A5298)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: const [
          Icon(Icons.camera_alt, color: Colors.white, size: 30),
          SizedBox(width: 10),
          Text(
            "Monitoring Kamera Bayi",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ================= DESKRIPSI =================
  Widget description() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff132A4A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        "Menampilkan hasil tangkapan kamera dari ESP32-CAM secara otomatis dan tersimpan di Supabase Storage.",
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  // ================= GALLERY =================
  Widget gallery() {
    if (imageList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imageList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final img = imageList[index];

        return GestureDetector(
          onTap: () => openImage(img['url']),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xff132A4A),
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 8,
                )
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                    child: CachedNetworkImage(
                      imageUrl: img['url'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    formatDate(img['date']), // 🔥 SUDAH BENAR
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1E3A),
      appBar: AppBar(
        backgroundColor: const Color(0xff0B1E3A),
        title: const Text("Camera Monitoring"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchImagesFromSupabase,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            header(),
            description(),
            const SizedBox(height: 20),
            gallery(),
          ],
        ),
      ),
    );
  }
}