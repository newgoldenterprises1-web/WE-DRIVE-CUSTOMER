import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class RatingReviewScreen extends StatefulWidget {
  const RatingReviewScreen({super.key});

  @override
  State<RatingReviewScreen> createState() =>
      _RatingReviewScreenState();
}

class _RatingReviewScreenState
    extends State<RatingReviewScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  int selectedRating = 0;

  final TextEditingController reviewController =
      TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  void submitReview() {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a rating."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Thank you for your feedback!"),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(
      const Duration(milliseconds: 800),
      () {
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
          (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Rate Your Trip"),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),

            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: primary,
                size: 55,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Trip Completed!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "How was your experience with your chauffeur?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    "Rate Your Chauffeur",
                    style: TextStyle(
                      color: primary,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) {
                        final rating = index + 1;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRating = rating;
                            });
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: Icon(
                              rating <= selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: gold,
                              size: 42,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    selectedRating == 0
                        ? "Tap a star to rate"
                        : "$selectedRating / 5",
                    style: const TextStyle(
                      color: primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Write a Review",
                    style: TextStyle(
                      color: primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: reviewController,
                    maxLines: 5,
                    textInputAction:
                        TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText:
                          "Share your experience...",
                      filled: true,
                      fillColor:
                          const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Submit Review",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "Skip",
                style: TextStyle(
                  color: primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}