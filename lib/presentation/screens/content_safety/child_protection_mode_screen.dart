import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/content_safety_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';

class ChildProtectionModeScreen extends StatefulWidget {
  const ChildProtectionModeScreen({super.key});

  @override
  State<ChildProtectionModeScreen> createState() => _ChildProtectionModeScreenState();
}

class _ChildProtectionModeScreenState extends State<ChildProtectionModeScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleEnable() async {
    final pin = _pinController.text.trim();
    final confirm = _confirmPinController.text.trim();

    if (pin.length < 4) {
      setState(() => _errorMessage = 'Parent PIN must be at least 4 digits');
      return;
    }

    if (pin != confirm) {
      setState(() => _errorMessage = 'PIN codes do not match');
      return;
    }

    setState(() => _errorMessage = null);
    final provider = context.read<ContentSafetyProvider>();
    await provider.enableChildMode(pin);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child Protection Mode has been enabled.')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleDisable() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Enter your Parent PIN to unlock');
      return;
    }

    final provider = context.read<ContentSafetyProvider>();
    final success = await provider.disableChildMode(pin);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child Protection Mode disabled.')),
      );
      Navigator.of(context).pop();
    } else {
      setState(() => _errorMessage = 'Incorrect PIN. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContentSafetyProvider>();
    final isChildActive = provider.isChildProtectionMode;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const CustomAppBar(
        title: 'Child Protection Mode',
        subtitle: 'Family protection & parental lock',
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: (isChildActive ? AppColors.primary : AppColors.warning).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isChildActive ? Icons.lock_outline_rounded : Icons.child_care_rounded,
                size: 46,
                color: isChildActive ? AppColors.primary : AppColors.warning,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isChildActive ? 'Child Protection is Active' : 'Enable Child Protection Mode',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Protects young users by enforcing strict SafeSearch, aggressive adult blocking, and locking settings with a parental PIN.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryDark, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Privacy Assurance Note
          CustomCard(
            backgroundColor: AppColors.surfaceDarkSecondary,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.privacy_tip_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No Surveillance Guarantee: BeOff does not track or collect browsing history. Protection protects against harm without spying.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.danger, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (!isChildActive) ...[
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Set 4-6 Digit Parent PIN',
                prefixIcon: Icon(Icons.lock_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Confirm Parent PIN',
                prefixIcon: Icon(Icons.lock_clock_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Enable & Lock Protection',
              onPressed: _handleEnable,
            ),
          ] else ...[
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Enter Parent PIN to Unlock',
                prefixIcon: Icon(Icons.lock_open_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Unlock & Disable Child Mode',
              variant: ButtonVariant.danger,
              onPressed: _handleDisable,
            ),
          ],
        ],
      ),
    );
  }
}
