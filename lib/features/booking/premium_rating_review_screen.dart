import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class PremiumRatingReviewScreen extends StatefulWidget {
  const PremiumRatingReviewScreen({
    super.key,
    this.chauffeurName = "Rahul Sharma",
  });

  final String chauffeurName;

  @override
  State<PremiumRatingReviewScreen> createState() =>
      _PremiumRatingReviewScreenState();
}

class _PremiumRatingReviewScreenState
    extends State<PremiumRatingReviewScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FA);

  int selectedRating = 0;

  final TextEditingController reviewController =
      TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
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
        content: Text("Thank you for your premium feedback!"),
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

  void _skipReview() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Premium Trip Review",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),

            // --------------------------------------------------
            // SUCCESS ICON
            // --------------------------------------------------

            Container(
              height: 92,
              width: 92,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: gold.withValues(alpha: .35),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: gold,
                size: 52,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Premium Trip Completed!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primary,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Thank you for choosing WE DRIVE Premium.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 28),

            // --------------------------------------------------
            // CHAUFFEUR
            // --------------------------------------------------

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: primary,
                      size: 32,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chauffeurName,
                          style: const TextStyle(
                            color: primary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          "Premium Chauffeur",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF16845A),
                    size: 23,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // RATING
            // --------------------------------------------------

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Text(
                    "Rate Your Premium Experience",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primary,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "How was your experience with your chauffeur?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
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

            // --------------------------------------------------
            // REVIEW
            // --------------------------------------------------

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
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

                  const SizedBox(height: 6),

                  const Text(
                    "Tell us about your premium experience.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
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
                      fillColor: background,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: primary.withValues(
                            alpha: .20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --------------------------------------------------
            // SUBMIT
            // --------------------------------------------------

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: gold,
                      size: 22,
                    ),
                    SizedBox(width: 9),
                    Text(
                      "Submit Premium Review",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: _skipReview,
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