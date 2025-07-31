import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51P8y3vSIsXN77HqfQG61sW1w5t2S4mBf8Mv9E8P4R7I3cK0Z6O5L3V0k7J0G2T6X7L8T9J2K1J0L7M8N9A0A1B2C3D4E5F6G7H8I9J';
  Stripe.instance.applySettings();

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
  List<SavedCard> _savedCards = [];
  bool _isLoadingSavedCards = true;
  bool _isProcessingPayment = false;
  int selectedPaymentIndex = 0;
  bool saveCard = false;
  final _formKey = GlobalKey<FormState>();
  final _cardNumberCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  final List<PaymentOption> otherOptions = [
    PaymentOption(
      name: 'Credit / Debit / ATM Card',
      icon: Icons.credit_card,
      color: const Color(0xFF38B2AC),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchSavedCards();
  }

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchSavedCards() async {
    setState(() {
      _isLoadingSavedCards = true;
    });
    try {
      final response = await http.get(
        Uri.parse('http://localhost:2000/api/get_saved_cards'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          //'Authorization': 'Bearer YOUR_AUTH_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          _savedCards =
              responseData.map((json) => SavedCard.fromJson(json)).toList();
        });
      } else {
        _showSnackBar('Failed to load saved cards: ${response.reasonPhrase}');
        print(
            'Failed to load saved cards: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Error fetching saved cards: $e');
      print('Error fetching saved cards: $e');
    } finally {
      setState(() {
        _isLoadingSavedCards = false;
      });
    }
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please correct the errors in the card details.');
      return;
    }

    if (selectedPaymentIndex == 0 && _savedCards.isNotEmpty) {
      _showSnackBar('Processing payment with saved card...');
      await Future.delayed(const Duration(seconds: 2));
      _showSnackBar('Payment with saved card successful!');
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final String cardNumber = _cardNumberCtrl.text.replaceAll(' ', '');
      final List<String> expiryParts = _expiryCtrl.text.split('/');
      final int expiryMonth = int.tryParse(expiryParts[0]) ?? 0;
      final int expiryYear = int.tryParse('20${expiryParts[1]}') ?? 0;
      final String cvv = _cvvCtrl.text;

      // CardDetails is no longer directly used
      // final CardDetails cardDetails = CardDetails(
      //   number: cardNumber,
      //   expirationMonth: expiryMonth,
      //   expirationYear: expiryYear,
      //   cvc: cvv,
      // );

      // Use Stripe.instance.createToken with PaymentMethodParams
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails:
                BillingDetails(), // You can add billing details here if needed
          ),
        ),
      );

      // _showSnackBar('Stripe Token created: ${token.id}');
      // print('Stripe Token: ${token.id}');
      // print('Card details used for token:');
      // print('  Number: ${token.card?.last4}');
      // print('  Brand: ${token.card?.brand}');
      // print('  Expiry: ${token.card?.expMonth}/${token.card?.expYear}');

      final chargeResponse = await http.post(
        Uri.parse('http://localhost:2000/api/charge'),
        headers: {
          'Content-Type': 'application/json',
          //'Authorization': 'Bearer YOUR_AUTH_TOKEN',
        },
        body: json.encode({
          'payment_method':
              paymentMethod.id, // Use paymentMethod.id instead of token.id
          'amount': 3500,
          'currency': 'usd',
          'save_card': saveCard,
        }),
      );

      if (chargeResponse.statusCode == 200) {
        _showSnackBar('Payment successful!');
        print('Charge successful: ${chargeResponse.body}');
      } else {
        _showSnackBar('Payment failed: ${chargeResponse.body}');
        print(
            'Charge failed: ${chargeResponse.statusCode} ${chargeResponse.body}');
      }
    } on StripeException catch (e) {
      _showSnackBar('Stripe Error: ${e.error.message}');
      print('Stripe Error: ${e.error.code} - ${e.error.message}');
    } catch (e) {
      _showSnackBar('An unexpected error occurred: $e');
      print('Unexpected error: $e');
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/logo.png', height: 40),
              const SizedBox(width: 8),
              const Text(
                'travelWish',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey,
            child: Icon(
              Icons.person,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(PaymentOption option, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selectedPaymentIndex == index
              ? option.color.withOpacity(0.3)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedPaymentIndex == index
                ? option.color
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(option.icon, color: option.color),
            const SizedBox(width: 12),
            Text(option.name, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (selectedPaymentIndex == index)
              Icon(Icons.check_circle, color: option.color),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saved Cards',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _isLoadingSavedCards
                    ? const Center(child: CircularProgressIndicator())
                    : _savedCards.isEmpty
                        ? const Text('No saved cards available.')
                        : _buildOptionItem(
                            PaymentOption(
                              name: _savedCards[0].name,
                              icon: Icons.credit_card,
                              color: const Color(0xFF4A90E2),
                            ),
                            0,
                          ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pay with Another Card',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _buildOptionItem(otherOptions[0], 1),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _cardNumberCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter card number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cardHolderCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Card Holder Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter card holder name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _expiryCtrl,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        labelText: 'Expiry (MM/YY)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expiry date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cvvCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter CVV';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isProcessingPayment ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                      ),
                      child: _isProcessingPayment
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Pay Now',
                              style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentOption {
  final String name;
  final IconData icon;
  final Color color;

  PaymentOption({required this.name, required this.icon, required this.color});
}

class SavedCard {
  final String id;
  final String name;
  final String last4;
  final String brand;

  SavedCard(
      {required this.id,
      required this.name,
      required this.last4,
      required this.brand});

  factory SavedCard.fromJson(Map<String, dynamic> json) {
    return SavedCard(
      id: json['id'],
      name: json['name'],
      last4: json['last4'],
      brand: json['brand'],
    );
  }
}
