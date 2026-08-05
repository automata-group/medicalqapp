import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../../core/utils/toast_utils.dart';

class PromosReferralsScreen extends StatefulWidget {
  const PromosReferralsScreen({super.key});

  @override
  State<PromosReferralsScreen> createState() => _PromosReferralsScreenState();
}

class _PromosReferralsScreenState extends State<PromosReferralsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  String _discountType = 'percentage';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchDiscountCodes();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: isDesktop
          ? AppBar(
              title: const Text('Promos & Referrals'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Form to create new
          Expanded(
            flex: 1,
            child: _buildCreateForm(),
          ),
          // Right: Table of existing
          Expanded(
            flex: 2,
            child: _buildCodesTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create Code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                  labelText: 'Promo Code (e.g. SUMMER20)',
                  border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Value', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _discountType,
                  items: const [
                    DropdownMenuItem(
                        value: 'percentage', child: Text('Percentage %')),
                    DropdownMenuItem(value: 'fixed', child: Text('Fixed SAR')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _discountType = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Generate Code',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodesTable() {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.discountCodes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
              columns: const [
                DataColumn(label: Text('Code')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Value')),
                DataColumn(label: Text('State')),
                DataColumn(label: Text('Actions')),
              ],
              rows: provider.discountCodes.map<DataRow>((code) {
                final isActive = code['isActive'] ?? false;
                final id = (code['id'] ?? code['_id']).toString();
                return DataRow(
                  cells: [
                    DataCell(Text(code['code'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(code['type'] ?? '')),
                    DataCell(Text(code['value'].toString())),
                    DataCell(Switch(
                      value: isActive,
                      activeThumbColor: Colors.green,
                      onChanged: (val) async {
                        await provider.toggleDiscountCodeStatus(id, val);
                      },
                    )),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Delete logic
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitCode() async {
    if (_formKey.currentState!.validate()) {
      final value = num.tryParse(_valueController.text);
      if (value == null) return;

      final provider = Provider.of<AdminProvider>(context, listen: false);
      final success = await provider.createDiscountCode(
          _codeController.text, value, _discountType);

      if (mounted) {
        if (success) {
          ToastUtils.showSuccess(context, 'Promo Code created!');
          _codeController.clear();
          _valueController.clear();
        } else {
          ToastUtils.showError(context, 'Failed to create Promo Code');
        }
      }
    }
  }
}
