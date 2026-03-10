import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:juan_million/widgets/toast_widget.dart';

class SignupDefaultsPage extends StatefulWidget {
  const SignupDefaultsPage({super.key});

  @override
  State<SignupDefaultsPage> createState() => _SignupDefaultsPageState();
}

class _SignupDefaultsPageState extends State<SignupDefaultsPage> {
  final _businessWalletController = TextEditingController();
  final _businessPtsController = TextEditingController();
  final _businessInventoryController = TextEditingController();
  final _businessPtsConversionController = TextEditingController();
  final _coordinatorWalletController = TextEditingController();

  bool _businessVerified = false;
  bool _coordinatorAutoApproved = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  @override
  void dispose() {
    _businessWalletController.dispose();
    _businessPtsController.dispose();
    _businessInventoryController.dispose();
    _businessPtsConversionController.dispose();
    _coordinatorWalletController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaults() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('AdminConfig')
          .doc('SignupDefaults')
          .get();

      final data = doc.data() ?? <String, dynamic>{};

      _businessWalletController.text =
          ((data['businessInitialWallet'] ?? 0) as num).toString();
      _businessPtsController.text = ((data['businessInitialPts'] ?? 0) as num)
          .toString();
      _businessInventoryController.text =
          ((data['businessInitialInventory'] ?? 0) as num).toString();
      _businessPtsConversionController.text =
          ((data['businessInitialPtsConversion'] ?? 0) as num).toString();
      _coordinatorWalletController.text =
          ((data['coordinatorInitialWallet'] ?? 0) as num).toString();

      _businessVerified = (data['businessInitialVerified'] ?? false) as bool;
      _coordinatorAutoApproved =
          (data['coordinatorAutoApproved'] ?? false) as bool;
    } catch (_) {
      showToast('Failed to load signup defaults', type: ToastType.error);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveDefaults() async {
    final int businessWallet =
        int.tryParse(_businessWalletController.text.trim()) ?? 0;
    final int businessPts =
        int.tryParse(_businessPtsController.text.trim()) ?? 0;
    final int businessInventory =
        int.tryParse(_businessInventoryController.text.trim()) ?? 0;
    final double businessPtsConversion =
        double.tryParse(_businessPtsConversionController.text.trim()) ?? 0;
    final int coordinatorWallet =
        int.tryParse(_coordinatorWalletController.text.trim()) ?? 0;

    setState(() {
      _saving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('AdminConfig')
          .doc('SignupDefaults')
          .set({
            'businessInitialWallet': businessWallet,
            'businessInitialPts': businessPts,
            'businessInitialInventory': businessInventory,
            'businessInitialPtsConversion': businessPtsConversion,
            'businessInitialVerified': _businessVerified,
            'coordinatorInitialWallet': coordinatorWallet,
            'coordinatorAutoApproved': _coordinatorAutoApproved,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      showToast('Signup defaults saved', type: ToastType.success);
    } catch (_) {
      showToast('Failed to save signup defaults', type: ToastType.error);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        title: TextWidget(
          text: 'Global Signup Defaults',
          fontSize: 18,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'Affiliate Defaults',
                    fontSize: 16,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(height: 10),
                  _buildNumberField(
                    label: 'Initial Wallet',
                    controller: _businessWalletController,
                  ),
                  _buildNumberField(
                    label: 'Initial Points',
                    controller: _businessPtsController,
                  ),
                  _buildNumberField(
                    label: 'Initial Inventory',
                    controller: _businessInventoryController,
                  ),
                  _buildNumberField(
                    label: 'Initial Points Conversion',
                    controller: _businessPtsConversionController,
                    isDecimal: true,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: TextWidget(
                      text: 'Auto-verify new affiliates',
                      fontSize: 14,
                      fontFamily: 'Medium',
                    ),
                    value: _businessVerified,
                    onChanged: (value) {
                      setState(() {
                        _businessVerified = value;
                      });
                    },
                  ),
                  const Divider(height: 32),
                  TextWidget(
                    text: 'Coordinator Defaults',
                    fontSize: 16,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(height: 10),
                  _buildNumberField(
                    label: 'Initial Wallet',
                    controller: _coordinatorWalletController,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: TextWidget(
                      text: 'Auto-approve new coordinators',
                      fontSize: 14,
                      fontFamily: 'Medium',
                    ),
                    value: _coordinatorAutoApproved,
                    onChanged: (value) {
                      setState(() {
                        _coordinatorAutoApproved = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveDefaults,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: TextWidget(
                        text: _saving ? 'Saving...' : 'Save Defaults',
                        fontSize: 14,
                        fontFamily: 'Bold',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    bool isDecimal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: isDecimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primary),
          ),
        ),
      ),
    );
  }
}
