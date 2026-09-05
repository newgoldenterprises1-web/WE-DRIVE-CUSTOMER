class OnboardingModel {
  final String title;
  final String subtitle;
  final String emoji;

  const OnboardingModel({
    required this.title,
    required this.subtitle,
    required this.emoji,
  });
}

const onboardingData = [

  OnboardingModel(
    emoji: "🚘",
    title: "Book Premium Chauffeurs",
    subtitle:
        "Professional, verified and luxury chauffeurs available anytime.",
  ),

  OnboardingModel(
    emoji: "📍",
    title: "Track Your Journey",
    subtitle:
        "Live location, real-time updates and complete ride transparency.",
  ),

  OnboardingModel(
    emoji: "⭐",
    title: "Safe & Reliable",
    subtitle:
        "Premium experience with secure payments and trusted drivers.",
  ),

];