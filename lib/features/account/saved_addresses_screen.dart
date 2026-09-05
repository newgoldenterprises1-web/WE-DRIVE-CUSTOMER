import 'package:flutter/material.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color background = Color(0xFFF5F7FB);

  final List<Map<String, dynamic>> addresses = [
    {'title': 'Home', 'address': 'Banjara Hills, Hyderabad', 'icon': Icons.home_rounded},
    {'title': 'Office', 'address': 'Hitech City, Hyderabad', 'icon': Icons.business_rounded},
    {'title': 'Favourite', 'address': 'Rajiv Gandhi Airport, Hyderabad', 'icon': Icons.favorite_rounded},
  ];

  void _addAddress({int? editIndex}) {
    final existing = editIndex == null ? null : addresses[editIndex];
    final titleController = TextEditingController(text: existing?['title'] ?? '');
    final addressController = TextEditingController(text: existing?['address'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text(editIndex == null ? 'Add New Address' : 'Edit Address', style: const TextStyle(color: primary, fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              TextField(controller: titleController, decoration: InputDecoration(labelText: 'Address Title', prefixIcon: const Icon(Icons.home_work_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
              const SizedBox(height: 12),
              TextField(controller: addressController, maxLines: 3, decoration: InputDecoration(labelText: 'Full Address', prefixIcon: const Icon(Icons.location_on_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, height: 52, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: () {
                final title = titleController.text.trim();
                final address = addressController.text.trim();
                if (title.isEmpty || address.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter both title and address.')));
                  return;
                }
                final index = editIndex;
                setState(() {
                  final item = {
                    'title': title,
                    'address': address,
                    'icon': index == null
                        ? Icons.location_on_rounded
                        : addresses[index]['icon'],
                  };
                  if (index == null) {
                    addresses.add(item);
                  } else {
                    addresses[index] = item;
                  }
                });
                Navigator.pop(sheetContext);
                _message(editIndex == null ? 'Address saved successfully.' : 'Address updated successfully.');
              }, child: Text(editIndex == null ? 'Save Address' : 'Update Address', style: const TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }

  void _delete(int index) {
    final title = addresses[index]['title'] as String;
    showDialog(context: context, builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Delete Address?', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
      content: Text('Remove $title from saved places?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () { setState(() => addresses.removeAt(index)); Navigator.pop(dialogContext); _message('$title address removed.'); }, child: const Text('Delete')),
      ],
    ));
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 0, centerTitle: true, foregroundColor: primary, title: const Text('Saved Addresses', style: TextStyle(color: primary, fontWeight: FontWeight.bold))),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: addresses.length + 1,
        itemBuilder: (context, index) {
          if (index == addresses.length) return const SizedBox(height: 100);
          final item = addresses[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 14, offset: const Offset(0, 6))]),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(14)), child: Icon(item['icon'] as IconData, color: primary)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['title'] as String, style: const TextStyle(color: primary, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(item['address'] as String, style: TextStyle(color: Colors.grey.shade700, height: 1.35))])),
                PopupMenuButton<String>(onSelected: (value) { if (value == 'edit') _addAddress(editIndex: index); if (value == 'delete') _delete(index); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))]),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(backgroundColor: primary, foregroundColor: Colors.white, onPressed: _addAddress, icon: const Icon(Icons.add), label: const Text('Add Address')),
    );
  }
}
