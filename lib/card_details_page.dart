import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class CardDetailsPage extends StatefulWidget {
  @override
  _CardDetailsPageState createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  CardFieldInputDetails? _cardDetails;
  bool _isLoading = false;

  void _saveCardDetails() async {
    if (_cardDetails == null || !_cardDetails!.complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the card form')),
      );
      return;
    }

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Card saving is not supported on web browsers. Please use our mobile app for this feature.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: 'example@email.com', // Add user's email
              // Add other billing details as needed
            ),
          ),
        ),
      );

      print('Payment Method ID: ${paymentMethod.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card details saved securely')),
      );
    } catch (e) {
      print('Error saving card: $e');
      String errorMessage = 'Failed to save card';
      if (e is StripeException) {
        errorMessage = e.error.message ?? 'Payment failed';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // Add any cleanup here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!kIsWeb)
              CardField(
                onCardChanged: (card) {
                  setState(() {
                    _cardDetails = card;
                  });
                  // Add validation feedback
                  if (card?.complete == true) {
                    print('Card is valid and complete');
                  } else if (card != null) {
                    if (card.validNumber == false) {
                      print('Card number is invalid');
                    }
                    if (card.validExpiryDate == false) {
                      print('Expiry date is invalid');
                    }
                    if (card.validCVC == false) {
                      print('CVC is invalid');
                    }
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your card details',
                ),
              )
            else
              const Text(
                'Stripe CardField is not supported on the Web.',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveCardDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Text('Save Card Details'),
            ),
          ],
        ),
      ),
    );
  }
}
