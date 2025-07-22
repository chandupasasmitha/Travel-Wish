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
            content: Text('Card saving is not supported on web (Chrome).')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params:
            PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
      );

      print('Payment Method ID: ${paymentMethod.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card details saved securely')),
      );
    } catch (e) {
      print('Error saving card: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save card')),
      );
    }

    setState(() {
      _isLoading = false;
    });
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
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Card Details'),
            ),
          ],
        ),
      ),
    );
  }
}
