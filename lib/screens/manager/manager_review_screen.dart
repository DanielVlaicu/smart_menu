import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class ManagerReviewScreen extends StatefulWidget {
  const ManagerReviewScreen({Key? key}) : super(key: key);

  @override
  State<ManagerReviewScreen> createState() => _ManagerReviewScreenState();
}

class _ManagerReviewScreenState extends State<ManagerReviewScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final data = await ApiService.getReviews();
      setState(() {
        _reviews = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la încărcarea recenziilor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Recenzii Clienți', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _reviews.isEmpty
          ? const Center(
        child: Text(
          'Nu există recenzii momentan.',
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final r = _reviews[index];
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (r['email'] != null && r['email'].toString().isNotEmpty)
                    Text('Email: ${r['email']}', style: const TextStyle(color: Colors.white)),
                  if (r['phone'] != null && r['phone'].toString().isNotEmpty)
                    Text('Telefon: ${r['phone']}', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(
                    r['message'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (r['image_url'] != null && r['image_url'] != '')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(r['image_url'], height: 160),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
