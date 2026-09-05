import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FB);

  final List<Map<String, String>> methods = [
    {'type': 'UPI', 'title': 'Google Pay', 'subtitle': 'shahed@upi'},
    {'type': 'Card', 'title': 'Visa Card', 'subtitle': '•••• 4587'},
    {'type': 'Cash', 'title': 'Cash', 'subtitle': 'Pay after ride'},
  ];

  int selected = 0;

  IconData _icon(String type) {
    switch (type) {
      case 'Card': return Icons.credit_card_rounded;
      case 'Cash': return Icons.payments_rounded;
      default: return Icons.account_balance_wallet_rounded;
    }
  }

  void _addMethod() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text('Add Payment Method', style: TextStyle(color: primary, fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              _option(sheetContext, Icons.account_balance_wallet_rounded, 'UPI', 'Add a UPI ID', () => _addUpi(sheetContext)),
              const SizedBox(height: 10),
              _option(sheetContext, Icons.credit_card_rounded, 'Debit / Credit Card', 'Add a card', () => _addCard(sheetContext)),
              const SizedBox(height: 10),
              _option(sheetContext, Icons.payments_rounded, 'Cash', 'Pay the chauffeur directly', () => _addCash(sheetContext)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: background,
      leading: Container(width: 46, height: 46, decoration: BoxDecoration(color: primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: primary)),
      title: Text(title, style: const TextStyle(color: primary, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  void _addUpi(BuildContext sheetContext) {
    Navigator.pop(sheetContext);
    final controller = TextEditingController();
    _inputDialog('Add UPI ID', 'UPI ID', controller, (value) {
      if (!value.contains('@')) return false;
      setState(() => methods.add({'type': 'UPI', 'title': 'UPI Payment', 'subtitle': value.trim()}));
      return true;
    });
  }

  void _addCard(BuildContext sheetContext) {
    Navigator.pop(sheetContext);
    final controller = TextEditingController();
    _inputDialog('Add Card', '16-digit card number', controller, (value) {
      final card = value.replaceAll(' ', '');
      if (card.length != 16) return false;
      setState(() => methods.add({'type': 'Card', 'title': 'Debit / Credit Card', 'subtitle': '•••• ${card.substring(12)}'}));
      return true;
    }, keyboardType: TextInputType.number);
  }

  void _addCash(BuildContext sheetContext) {
    Navigator.pop(sheetContext);
    if (methods.any((m) => m['type'] == 'Cash')) {
      _message('Cash payment is already available.');
      return;
    }
    setState(() => methods.add({'type': 'Cash', 'title': 'Cash', 'subtitle': 'Pay after ride'}));
    _message('Cash payment added.');
  }

  void _inputDialog(String title, String label, TextEditingController controller, bool Function(String) save, {TextInputType? keyboardType}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(color: primary, fontWeight: FontWeight.bold)),
        content: TextField(controller: controller, keyboardType: keyboardType, decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: primary),
            onPressed: () {
              if (!save(controller.text.trim())) {
                _message(label == 'UPI ID' ? 'Enter a valid UPI ID.' : 'Enter a valid 16-digit card number.');
                return;
              }
              Navigator.pop(dialogContext);
              _message('Payment method added successfully.');
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _message(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 0, centerTitle: true, foregroundColor: primary, title: const Text('Payment Methods', style: TextStyle(color: primary, fontWeight: FontWeight.bold))),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: methods.length + 2,
        itemBuilder: (context, index) {
          if (index < methods.length) {
            final method = methods[index];
            final isSelected = selected == index;
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 14, offset: const Offset(0, 6))]),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(14)), child: Icon(_icon(method['type']!), color: primary)),
                title: Text(method['title']!, style: const TextStyle(color: primary, fontWeight: FontWeight.bold)),
                subtitle: Text(method['subtitle']!),
                trailing: IconButton(onPressed: () => setState(() => selected = index), icon: Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: isSelected ? gold : Colors.grey)),
              ),
            );
          }
          if (index == methods.length) {
            return SizedBox(height: 52, child: ElevatedButton.icon(onPressed: _addMethod, style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), icon: const Icon(Icons.add), label: const Text('ADD PAYMENT METHOD', style: TextStyle(fontWeight: FontWeight.bold))));
          }
          return const SizedBox(height: 30);
        },
      ),
    );
  }
}
