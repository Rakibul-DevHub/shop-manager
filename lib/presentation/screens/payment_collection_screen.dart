import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/text/app_text.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/payment.dart';
import '../state/shop_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';

class PaymentCollectionScreen extends StatefulWidget {
  const PaymentCollectionScreen({super.key, required this.customer});

  final Customer customer;

  @override
  State<PaymentCollectionScreen> createState() =>
      _PaymentCollectionScreenState();
}

class _PaymentCollectionScreenState extends State<PaymentCollectionScreen> {
  final _amountController = TextEditingController();
  DateTime? _paidAt;
  bool _saving = false;
  bool _loadingHistory = true;
  List<Payment> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final store = context.read<ShopStore>();
    final id = widget.customer.id;
    if (id == null) {
      setState(() {
        _payments = [];
        _loadingHistory = false;
      });
      return;
    }
    final list = await store.paymentsForCustomer(id);
    if (!mounted) return;
    setState(() {
      _payments = list;
      _loadingHistory = false;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _paidAt ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: AppText(context.read<ShopStore>().languageCode).paymentDate,
    );
    if (picked != null) {
      setState(() {
        _paidAt = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _savePayment() async {
    final store = context.read<ShopStore>();
    final t = AppText(store.languageCode);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    if (_paidAt == null) {
      showAppMessage(context, t.paymentDateRequired);
      return;
    }

    setState(() => _saving = true);
    final error = await store.collectPayment(
      customer: widget.customer,
      amount: amount,
      paidAt: _paidAt!,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      showAppMessage(context, error);
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.savePayment),
        content: Text(
          '${widget.customer.name}: ${formatTaka(amount)}\n'
          '${t.paymentDate}: ${DateFormat('dd MMM yyyy').format(_paidAt!)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(t.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final customer = store.dueCustomers
            .where((c) => c.id == widget.customer.id)
            .firstOrNull ??
        widget.customer;
    final dateLabel = _paidAt == null
        ? t.pickPaymentDate
        : DateFormat('dd MMM yyyy').format(_paidAt!);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.paymentTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: OfflineBadge(label: t.offline)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: ListTile(
                      title: Text(
                        customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(customer.phone),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            t.totalDueLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            formatTaka(customer.dueAmount),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${t.howMuchReceived} *',
                      prefixText: '৳ ',
                      hintText: '500',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${t.paymentDate} *',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dateLabel,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: _paidAt == null
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              t.pickPaymentDate,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t.paymentHistory,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_loadingHistory)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_payments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        t.noPaymentsYet,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ..._payments.map(
                      (p) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Icon(
                              Icons.payments_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            formatTaka(p.amount),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${t.paymentDate}: ${DateFormat('dd MMM yyyy').format(p.createdAt)}',
                          ),
                          trailing: Text(
                            t.paidAmount,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PrimaryButton(
                label: _saving ? '...' : t.savePayment,
                onPressed: _saving ? null : _savePayment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
