import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:moyasar/moyasar.dart';

class NativePaymentScreen extends StatefulWidget {
  final String publishableKey;
  final int amount;
  final String currency;
  final String description;
  final Map<String, dynamic> metadata;

  const NativePaymentScreen({
    Key? key,
    required this.publishableKey,
    required this.amount,
    required this.currency,
    required this.description,
    required this.metadata,
  }) : super(key: key);

  @override
  State<NativePaymentScreen> createState() => _NativePaymentScreenState();
}

class _NativePaymentScreenState extends State<NativePaymentScreen> {
  late PaymentConfig paymentConfig;

  @override
  void initState() {
    super.initState();
    paymentConfig = PaymentConfig(
      publishableApiKey: widget.publishableKey,
      amount: widget.amount, // in halalas
      description: widget.description,
      metadata: widget.metadata.map((key, value) => MapEntry(key, value.toString())),
      currency: widget.currency,
      creditCard: CreditCardConfig(saveCard: false, manual: false),
      applePay: ApplePayConfig(
        merchantId: 'merchant.com.healthlicenseprep',
        label: 'Medical Q',
        manual: false,
        saveCard: false,
      ),
      samsungPay: SamsungPayConfig(
        serviceId: 'your_samsung_pay_service_id_here', // <-- يجب تغييره لاحقاً من سامسونج
        merchantName: 'Medical Q',
        manual: false,
      ),
    );
  }

  void onPaymentResult(dynamic result) {
    if (result is PaymentResponse) {
      if (result.status == PaymentStatus.paid) {
        // Payment success, pop with the Payment ID
        Navigator.pop(context, result.id);
      } else {
        // Payment failed
        debugPrint('Payment Failed: ${result.status}');
        Navigator.pop(context, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          widget.description,
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(widget.amount / 100).toStringAsFixed(2)} ${widget.currency}',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Apple Pay widget (Only available on iOS)
                if (Platform.isIOS)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ApplePay(
                      config: paymentConfig,
                      onPaymentResult: onPaymentResult,
                    ),
                  ),
                
                // Samsung Pay widget (Only available on Android)
                if (Platform.isAndroid)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SamsungPay(
                      config: paymentConfig,
                      onPaymentResult: onPaymentResult,
                    ),
                  ),

                const Divider(height: 40),
                
                // Native Moyasar Credit Card Widget - Forced LTR to prevent RTL overflow crashes
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: CreditCard(
                    config: paymentConfig,
                    onPaymentResult: onPaymentResult,
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
