import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../providers/protection_provider.dart';

class ProtectionShieldWidget extends StatefulWidget {
  final ProtectionStateStatus status;
  final VoidCallback onTap;

  const ProtectionShieldWidget({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  State<ProtectionShieldWidget> createState() => _ProtectionShieldWidgetState();
}

class _ProtectionShieldWidgetState extends State<ProtectionShieldWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProtected = widget.status == ProtectionStateStatus.active;
    final isConnecting = widget.status == ProtectionStateStatus.connecting;

    Color glowColor = isProtected
        ? AppColors.primary
        : (isConnecting ? AppColors.warning : AppColors.borderDark);

    return Column(
      children: [
        GestureDetector(
          onTap: isConnecting ? null : widget.onTap,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (ctx, child) {
              return Transform.scale(
                scale: isProtected ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isProtected
                        ? AppColors.shieldActiveGradient
                        : AppColors.shieldInactiveGradient,
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withOpacity(isProtected ? 0.45 : 0.15),
                        blurRadius: isProtected ? 42 : 16,
                        spreadRadius: isProtected ? 8 : 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: isConnecting
                        ? const SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            isProtected ? Icons.shield_rounded : Icons.power_settings_new_rounded,
                            size: 78,
                            color: isProtected ? Colors.black : Colors.white70,
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isProtected
              ? "You're protected."
              : (isConnecting ? "Enabling shield..." : "Protection is off"),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isProtected
                ? AppColors.primaryLight
                : (isConnecting ? AppColors.warning : AppColors.textSecondaryDark),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isProtected
              ? 'Filtering network traffic locally on device'
              : 'Tap shield button to activate real-time protection',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMutedDark,
          ),
        ),
      ],
    );
  }
}
