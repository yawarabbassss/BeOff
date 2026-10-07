import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/confirmation_modal.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(email: email, password: password);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in successfully. Protection settings synced.')),
      );
    }
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      email: email,
      password: password,
      displayName: name.isNotEmpty ? name : 'BeOff User',
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Your local preferences are now backed up.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const CustomAppBar(
        title: 'Account & Synchronization',
        subtitle: 'Backup and sync settings across devices',
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          if (auth.isAuthenticated) ...[
            // Authenticated Profile View
            CustomCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, size: 40, color: Colors.black),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    auth.profile.displayName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.profile.email ?? '',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Sign Out',
                    variant: ButtonVariant.outline,
                    onPressed: () => auth.signOut(),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Delete Account',
                    variant: ButtonVariant.danger,
                    onPressed: () async {
                      final confirm = await ConfirmationModal.show(
                        context,
                        title: 'Delete Cloud Account',
                        message:
                            'This will permanently delete your cloud account and synced preferences. Local protection will continue to function completely uninterrupted.',
                        confirmText: 'Permanently Delete',
                        isDangerous: true,
                      );
                      if (confirm == true && mounted) {
                        await auth.deleteAccount();
                      }
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            // Guest / Login Form View
            CustomCard(
              backgroundColor: AppColors.surfaceDarkSecondary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Optional Cloud Sync',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Creating an account is 100% optional. BeOff protection works fully offline without an account. Signing in allows you to synchronize filter lists across your devices.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondaryDark,
              tabs: const [
                Tab(text: 'Sign In'),
                Tab(text: 'Create Account'),
              ],
            ),
            const SizedBox(height: 20),

            if (auth.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(auth.errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              height: 320,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Sign In
                  Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Sign In & Sync',
                        isLoading: auth.isLoading,
                        onPressed: _handleSignIn,
                      ),
                    ],
                  ),

                  // Sign Up
                  Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Display Name', prefixIcon: Icon(Icons.person_outline)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Create Password', prefixIcon: Icon(Icons.lock_outline)),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Create Account',
                        isLoading: auth.isLoading,
                        onPressed: _handleSignUp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
