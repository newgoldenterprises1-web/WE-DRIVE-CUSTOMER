import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../booking/booking_screen.dart';
import '../../profile/saved_addresses_screen.dart';
import '../../account/executive_support_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 145,
            ),
            itemBuilder: (context, index) {
              return _ActionTile(action: _actions[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _Action {
  final IconData icon;
  final String title;

  const _Action({
    required this.icon,
    required this.title,
  });
}

const List<_Action> _actions = [
  _Action(
    icon: Iconsax.repeat,
    title: "Book\nAgain",
  ),
  _Action(
    icon: Iconsax.location,
    title: "Saved\nPlaces",
  ),
  _Action(
    icon: Iconsax.profile_2user,
    title: "Favourite\nChauffeur",
  ),
  _Action(
    icon: Iconsax.briefcase,
    title: "Corporate",
  ),
];

class _ActionTile extends StatelessWidget {
  final _Action action;

  const _ActionTile({
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          switch (action.title.replaceAll('\n', ' ')) {
            case 'Book Again':
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingScreen()));
              break;
            case 'Saved Places':
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedAddressesScreen()));
              break;
            case 'Favourite Chauffeur':
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ExecutiveSupportScreen()));
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${action.title.replaceAll('\n', ' ')} selected.')),
              );
          }
        },
        child: Ink(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF173B6D).withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    action.icon,
                    color: const Color(0xFF173B6D),
                    size: 28,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: Center(
                    child: Text(
                      action.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}