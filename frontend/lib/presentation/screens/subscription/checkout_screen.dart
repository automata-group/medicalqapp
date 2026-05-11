import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'native_payment_screen.dart';
import '../../../core/utils/toast_utils.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class CheckoutScreen extends StatefulWidget {
  final String planId;
  final String amount;

  const CheckoutScreen({super.key, required this.planId, required this.amount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Use the same base URL as DioClient
  static const String _baseUrl = 'https://healthlicenseprep.com/api/v1';

  final TextEditingController _promoController = TextEditingController();
  bool _isPromoApplied = false;
  double _discountedAmount = 0.0;
  bool _isApplyingPromo = false;
  String? _appliedPromoCode;

  @override
  void initState() {
    super.initState();
    _discountedAmount = double.tryParse(widget.amount) ?? 0.0;
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() async {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() => _isApplyingPromo = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final dio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
      ));

      final response = await dio.post(
        '/subscriptions/validate-promo',
        data: {'code': code, 'planId': widget.planId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (!mounted) return;

      if (response.data['success'] == true) {
        final data = response.data['data'];
        setState(() {
          _isPromoApplied = true;
          _appliedPromoCode = data['code'];
          if (data['discountedPrice'] != null) {
            _discountedAmount = (data['discountedPrice'] as num).toDouble();
          }
        });
        ToastUtils.showSuccess(context, 'Promo code applied successfully!');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? 'Invalid or expired promo code.';
      ToastUtils.showError(context, msg);
    } catch (_) {
      if (!mounted) return;
      ToastUtils.showError(context, 'Error validating promo code.');
    }

    if (mounted) setState(() => _isApplyingPromo = false);
  }

  void _showSuccessDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              l10n.paymentSuccessful,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(l10n.premiumSuccessMessage, textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.continueText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.checkoutTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Plan Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Mastery PRO - ${widget.planId.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Text(
                        '${widget.amount} SAR',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: _isPromoApplied ? TextDecoration.lineThrough : null,
                          color: _isPromoApplied ? Colors.grey : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  if (_isPromoApplied) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Discount ($_appliedPromoCode)',
                          style: const TextStyle(fontSize: 14, color: Colors.green),
                        ),
                        Text(
                          '-${(double.parse(widget.amount) - _discountedAmount).toStringAsFixed(2)} SAR',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_discountedAmount.toStringAsFixed(2)} SAR',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Promo Code Section
            if (!_isPromoApplied)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      decoration: InputDecoration(
                        hintText: 'Have a promo code?',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isApplyingPromo ? null : _applyPromo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isApplyingPromo
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Apply'),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            // Proceed to Payment Button
            ElevatedButton(
              onPressed: _isApplyingPromo ? null : _startMoyasarCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Proceed to Payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  l10n.securePaymentMoyasar,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startMoyasarCheckout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final response = await dio.post(
        '/subscriptions/pay',
        data: {
          'planId': widget.planId,
          'promoCode': _appliedPromoCode ?? '',
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (response.data['success'] == true) {
        final publishableKey = response.data['publishableKey'] ?? '';
        final amount = response.data['amount'] ?? 0;
        final currency = response.data['currency'] ?? 'SAR';
        final description = response.data['description'] ?? 'Subscription';
        final metadata = (response.data['metadata'] as Map<String, dynamic>?) ?? {};

        final dynamic paymentResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NativePaymentScreen(
              publishableKey: publishableKey,
              amount: amount,
              currency: currency,
              description: description,
              metadata: metadata,
            ),
          ),
        );

        if (paymentResult is String) {
          // Send verification request to backend
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const Center(child: CircularProgressIndicator()),
          );
          try {
            final verifyResponse = await dio.post(
              '/subscriptions/verify-payment',
              data: {'paymentId': paymentResult},
              options: Options(headers: {'Authorization': 'Bearer $token'}),
            );
            
            if (!mounted) return;
            Navigator.pop(context); // close loader
            
            if (verifyResponse.data['success'] == true) {
               // Update user's subscription state so UI reflects it without a restart
               if (mounted) {
                 await Provider.of<AuthProvider>(context, listen: false).refreshProfile();
               }
               _showSuccessDialog();
            } else {
               ToastUtils.showError(context, 'Payment verified but activation failed.');
            }
          } catch (e) {
            if (!mounted) return;
            Navigator.pop(context); // close loader
            ToastUtils.showError(context, 'Error verifying payment: $e');
          }
        } else if (paymentResult == false) {
          if (!mounted) return;
          ToastUtils.showError(context, 'Payment Failed or Canceled');
        }
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ToastUtils.showError(context, 'Error initiating checkout: $e');
    }
  }
}
