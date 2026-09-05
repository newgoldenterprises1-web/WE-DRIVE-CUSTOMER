import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const Color primary = Color(0xFF173B6D);

  Widget transactionTile(
    IconData icon,
    Color color,
    String title,
    String date,
    String amount,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Wallet"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF173B6D),
                  Color(0xFF2563EB),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Wallet Balance",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "₹4,850",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) {
                    final controller = TextEditingController();
                    return AlertDialog(
                      title: const Text("Add Money"),
                      content: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          prefixText: "₹ ",
                          labelText: "Amount",
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("Cancel"),
                        ),
                        FilledButton(
                          onPressed: () {
                            final amount = controller.text.trim();
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(amount.isEmpty ? "Enter an amount." : "₹$amount selected to add to wallet.")),
                            );
                          },
                          child: const Text("Continue"),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("ADD MONEY"),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "Recent Transactions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),
                    transactionTile(
            Icons.arrow_downward,
            Colors.green,
            "Money Added",
            "Today • 10:15 AM",
            "+ ₹1,000",
          ),

          transactionTile(
            Icons.local_taxi,
            Colors.red,
            "Chauffeur Booking",
            "Yesterday • 7:45 PM",
            "- ₹850",
          ),

          transactionTile(
            Icons.card_giftcard,
            Colors.orange,
            "Cashback Reward",
            "12 Jul 2026",
            "+ ₹250",
          ),

          transactionTile(
            Icons.account_balance_wallet,
            Colors.green,
            "Wallet Refund",
            "08 Jul 2026",
            "+ ₹500",
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}