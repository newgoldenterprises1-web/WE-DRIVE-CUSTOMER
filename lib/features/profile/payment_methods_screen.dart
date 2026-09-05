import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState
    extends State<PaymentMethodsScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FB);

  static const String _paymentMethodsKey =
      'we_drive_payment_methods';

  List<Map<String, dynamic>> paymentMethods = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  // ==========================================================
  // LOAD SAVED PAYMENT METHODS
  // ==========================================================

  Future<void> _loadPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();

    final savedList = prefs.getStringList(
      _paymentMethodsKey,
    );

    if (savedList == null || savedList.isEmpty) {
      paymentMethods = [
        {
          'type': 'UPI',
          'name': 'Google Pay',
          'details': 'shahed@upi',
          'iconType': 'upi',
          'default': true,
        },
        {
          'type': 'Card',
          'name': 'Visa Card',
          'details': '•••• 4242',
          'iconType': 'card',
          'default': false,
        },
      ];

      await _savePaymentMethods();
    } else {
      paymentMethods = savedList.map((item) {
        final parts = item.split('|');

        return {
          'type': parts.isNotEmpty ? parts[0] : 'Other',
          'name': parts.length > 1 ? parts[1] : 'Payment',
          'details': parts.length > 2 ? parts[2] : '',
          'iconType':
              parts.length > 3 ? parts[3] : 'other',
          'default':
              parts.length > 4 && parts[4] == 'true',
        };
      }).toList();
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  // ==========================================================
  // SAVE PAYMENT METHODS
  // ==========================================================

  Future<void> _savePaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();

    final list = paymentMethods.map((method) {
      return [
        _cleanValue(method['type']),
        _cleanValue(method['name']),
        _cleanValue(method['details']),
        _cleanValue(method['iconType']),
        method['default'] == true ? 'true' : 'false',
      ].join('|');
    }).toList();

    await prefs.setStringList(
      _paymentMethodsKey,
      list,
    );
  }

  String _cleanValue(dynamic value) {
    return value
        .toString()
        .replaceAll('|', ' ')
        .replaceAll('\n', ' ');
  }

  // ==========================================================
  // ADD PAYMENT METHOD
  // ==========================================================

  void _addPaymentMethod() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Add Payment Method',
                style: TextStyle(
                  color: primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 22),

              _addOption(
                icon:
                    Icons.account_balance_wallet_rounded,
                title: 'UPI',
                subtitle:
                    'Google Pay, PhonePe, Paytm',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _addUpi();
                },
              ),

              const SizedBox(height: 12),

              _addOption(
                icon: Icons.credit_card_rounded,
                title: 'Debit / Credit Card',
                subtitle:
                    'Visa, Mastercard, RuPay',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _addCard();
                },
              ),

              const SizedBox(height: 12),

              _addOption(
                icon: Icons.money_rounded,
                title: 'Cash',
                subtitle:
                    'Pay the chauffeur directly',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _addCash();
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // ADD OPTION
  // ==========================================================

  Widget _addOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: primary,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ADD UPI
  // ==========================================================

  void _addUpi() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Add UPI',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType:
                TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'UPI ID',
              hintText: 'example@upi',
              prefixIcon: const Icon(
                Icons.account_balance_wallet_rounded,
                color: primary,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
              ),
              onPressed: () async {
                final upi =
                    controller.text.trim();

                if (upi.isEmpty ||
                    !upi.contains('@')) {
                  _showMessage(
                    'Please enter a valid UPI ID.',
                  );
                  return;
                }

                setState(() {
                  paymentMethods.add({
                    'type': 'UPI',
                    'name': 'UPI Payment',
                    'details': upi,
                    'iconType': 'upi',
                    'default':
                        paymentMethods.isEmpty,
                  });
                });

                await _savePaymentMethods();

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.pop(dialogContext);

                _showMessage(
                  'UPI payment method added.',
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // ADD CARD
  // ==========================================================

  void _addCard() {
    final cardController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Add Card',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: cardController,
            keyboardType:
                TextInputType.number,
            maxLength: 16,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234567890123456',
              prefixIcon: const Icon(
                Icons.credit_card_rounded,
                color: primary,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
              ),
              onPressed: () async {
                final card = cardController.text
                    .replaceAll(' ', '')
                    .trim();

                if (card.length != 16) {
                  _showMessage(
                    'Please enter a valid 16-digit card number.',
                  );
                  return;
                }

                final lastFour =
                    card.substring(
                  card.length - 4,
                );

                setState(() {
                  paymentMethods.add({
                    'type': 'Card',
                    'name':
                        'Visa / Debit Card',
                    'details':
                        '•••• $lastFour',
                    'iconType': 'card',
                    'default':
                        paymentMethods.isEmpty,
                  });
                });

                await _savePaymentMethods();

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.pop(dialogContext);

                _showMessage(
                  'Card added successfully.',
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // ADD CASH
  // ==========================================================

  Future<void> _addCash() async {
    final alreadyExists =
        paymentMethods.any(
      (method) =>
          method['type'] == 'Cash',
    );

    if (alreadyExists) {
      _showMessage(
        'Cash payment is already added.',
      );
      return;
    }

    setState(() {
      paymentMethods.add({
        'type': 'Cash',
        'name': 'Cash Payment',
        'details': 'Pay chauffeur directly',
        'iconType': 'cash',
        'default': paymentMethods.isEmpty,
      });
    });

    await _savePaymentMethods();

    _showMessage(
      'Cash payment added.',
    );
  }

  // ==========================================================
  // SET DEFAULT
  // ==========================================================

  Future<void> _setDefault(int index) async {
    setState(() {
      for (final method in paymentMethods) {
        method['default'] = false;
      }

      paymentMethods[index]['default'] = true;
    });

    await _savePaymentMethods();

    _showMessage(
      'Default payment method updated.',
    );
  }

  // ==========================================================
  // DELETE PAYMENT
  // ==========================================================

  void _deletePayment(int index) {
    final method = paymentMethods[index];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Remove Payment Method?',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Remove ${method['name']} from your payment methods?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                final wasDefault =
                    paymentMethods[index]
                        ['default'] ==
                    true;

                setState(() {
                  paymentMethods
                      .removeAt(index);

                  if (wasDefault &&
                      paymentMethods
                          .isNotEmpty) {
                    paymentMethods[0]
                        ['default'] = true;
                  }
                });

                await _savePaymentMethods();

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.pop(dialogContext);

                _showMessage(
                  'Payment method removed.',
                );
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        foregroundColor: primary,
        centerTitle: true,
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        onPressed: _isLoading
            ? null
            : _addPaymentMethod,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Add Payment',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            )
          : ListView(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                110,
              ),
              children: [
                // ==================================================
                // SECURE PAYMENTS
                // ==================================================

                Container(
                  padding:
                      const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xFF173B6D),
                        Color(0xFF295FA7),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primary
                            .withValues(
                          alpha: .22,
                        ),
                        blurRadius: 20,
                        offset:
                            const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        color: gold,
                        size: 32,
                      ),

                      SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Secure Payments',
                              style: TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              'Your payment information is protected.',
                              style: TextStyle(
                                color:
                                    Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                const Text(
                  'Saved Payment Methods',
                  style: TextStyle(
                    color: primary,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                if (paymentMethods.isEmpty)
                  _emptyPaymentCard(),

                ...List.generate(
                  paymentMethods.length,
                  (index) {
                    final method =
                        paymentMethods[index];

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 14,
                      ),
                      child: _paymentCard(
                        index: index,
                        type:
                            method['type']
                                as String,
                        name:
                            method['name']
                                as String,
                        details:
                            method['details']
                                as String,
                        iconType:
                            method['iconType']
                                as String,
                        isDefault:
                            method['default']
                                as bool,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                const Text(
                  'Payment methods are stored securely and can be managed anytime.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
    );
  }

  // ==========================================================
  // EMPTY CARD
  // ==========================================================

  Widget _emptyPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      margin:
          const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.payment_rounded,
            color: primary,
            size: 55,
          ),

          SizedBox(height: 14),

          Text(
            'No Payment Methods',
            style: TextStyle(
              color: primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'Add a payment method to make bookings easier.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PAYMENT CARD
  // ==========================================================

  Widget _paymentCard({
    required int index,
    required String type,
    required String name,
    required String details,
    required String iconType,
    required bool isDefault,
  }) {
    IconData icon;

    switch (iconType) {
      case 'upi':
        icon =
            Icons.account_balance_wallet_rounded;
        break;

      case 'card':
        icon = Icons.credit_card_rounded;
        break;

      case 'cash':
        icon = Icons.money_rounded;
        break;

      default:
        icon = Icons.payment_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: .05),
            blurRadius: 16,
            offset:
                const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: primary
                  .withValues(alpha: .08),
              borderRadius:
                  BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color: primary,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color: primary,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    if (isDefault) ...[
                      const SizedBox(width: 8),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color: gold
                              .withValues(
                            alpha: .15,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                        child:
                            const Text(
                          'DEFAULT',
                          style:
                              TextStyle(
                            color: gold,
                            fontSize: 9,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  details,
                  style:
                      const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.grey,
            ),
            onSelected: (value) {
              if (value == 'default') {
                _setDefault(index);
              }

              if (value == 'delete') {
                _deletePayment(index);
              }
            },
            itemBuilder: (_) => [
              if (!isDefault)
                const PopupMenuItem<String>(
                  value: 'default',
                  child: Text(
                    'Set as Default',
                  ),
                ),

              const PopupMenuItem<String>(
                value: 'delete',
                child: Text(
                  'Remove',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}