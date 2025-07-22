import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: CheckoutPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Saved Cards (only HDFC)
  final List<SavedCard> savedCards = [
    SavedCard(
      bankName: 'HDFC Bank Credit Card',
      cardNumber: '**** **** **** 1234',
      icon: Icons.credit_card,
      color: Color(0xFFE53E3E),
    ),
  ];

  // Only one other option
  final List<PaymentOption> otherOptions = [
    PaymentOption(
      name: 'Credit / Debit / ATM Card',
      icon: Icons.credit_card,
      color: Color(0xFF38B2AC),
    ),
  ];

  int selectedPaymentIndex = 0;
  bool saveCard = false;

  // Controllers for card details form
  final _cardNumberCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Payments',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Saved Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saved Cards',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _buildSavedCardItem(savedCards[0], 0),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Other Options (modified to Pay with Another Card + Card details subtitle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pay with Another Card',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Card details',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey)),
                const SizedBox(height: 12),
                _buildOptionItem(otherOptions[0], 1),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Card Details Form
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Card Details',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _buildTextField('Card Number', _cardNumberCtrl),
                const SizedBox(height: 12),
                _buildTextField('Cardholder Name', _cardHolderCtrl),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                            'Expiry Date (MM/YY)', _expiryCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('CVV', _cvvCtrl)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: saveCard,
                      onChanged: (v) => setState(() => saveCard = v!),
                      activeColor: Color(0xFF4A90E2),
                    ),
                    const Text('Save this card for later payments'),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Pay Button Box
          Container(
            width: double.infinity,
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: Text(
                'Pay Rs.3500',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('travelwish',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedCardItem(SavedCard card, int index) {
    bool isSelected = selectedPaymentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentIndex = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Color(0xFF4A90E2), width: 2)
              : null,
        ),
        child: Row(
          children: [
            Icon(card.icon, color: card.color),
            const SizedBox(width: 12),
            Text(card.bankName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(card.cardNumber, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(PaymentOption option, int index) {
    bool isSelected = selectedPaymentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentIndex = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Color(0xFF4A90E2), width: 2)
              : null,
        ),
        child: Row(
          children: [
            Icon(option.icon, color: option.color),
            const SizedBox(width: 12),
            Text(option.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}

class SavedCard {
  final String bankName;
  final String cardNumber;
  final IconData icon;
  final Color color;

  SavedCard({
    required this.bankName,
    required this.cardNumber,
    required this.icon,
    required this.color,
  });
}

class PaymentOption {
  final String name;
  final IconData icon;
  final Color color;

  PaymentOption({
    required this.name,
    required this.icon,
    required this.color,
  });
}
