import 'package:flutter/material.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  // Simulated login role (in real app, get this from AuthProvider)
  String userRole = 'client'; // change to 'worker' to test the other view

  double clientRating = 4.0;
  double workerRating = 3.0;

  void _updateRating(bool isWorkerRating, double newRating) {
    setState(() {
      if (userRole == 'client' && isWorkerRating) {
        workerRating = newRating;
      } else if (userRole == 'worker' && !isWorkerRating) {
        clientRating = newRating;
      } else {
        // User trying to rate themselves → show warning
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You cannot rate yourself."),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  Widget _buildRatingRow({
    required String title,
    required double rating,
    required bool editable,
    required bool isWorkerRating,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                int starIndex = index + 1;
                return IconButton(
                  icon: Icon(
                    starIndex <= rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                  onPressed: editable
                      ? () => _updateRating(isWorkerRating, starIndex.toDouble())
                      : null,
                );
              }),
            ),
            Text(
              "Rating: ${rating.toStringAsFixed(1)} / 5.0",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool clientCanEdit = userRole == 'worker';
    bool workerCanEdit = userRole == 'client';

    return Scaffold(
      appBar: AppBar(title: const Text("Ratings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRatingRow(
              title: "Client's Rating",
              rating: clientRating,
              editable: clientCanEdit,
              isWorkerRating: false,
            ),
            _buildRatingRow(
              title: "Worker's Rating",
              rating: workerRating,
              editable: workerCanEdit,
              isWorkerRating: true,
            ),
            const SizedBox(height: 20),
            Text(
              "Logged in as: $userRole",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  userRole = userRole == 'client' ? 'worker' : 'client';
                });
              },
              child: const Text("Switch Role (for demo)"),
            ),
          ],
        ),
      ),
    );
  }
}