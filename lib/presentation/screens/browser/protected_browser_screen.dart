import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/url_sanitizer.dart';
import '../../providers/protection_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';

class ProtectedBrowserScreen extends StatefulWidget {
  const ProtectedBrowserScreen({super.key});

  @override
  State<ProtectedBrowserScreen> createState() => _ProtectedBrowserScreenState();
}

class _ProtectedBrowserScreenState extends State<ProtectedBrowserScreen> {
  late final WebViewController _controller;
  final TextEditingController _urlInputController = TextEditingController(text: 'https://duckduckgo.com');
  bool _isLoading = false;
  int _blockedElementsCount = 0;
  String _currentUrl = 'https://duckduckgo.com';

  @override
  void initState() {
    super.initState();
    _initWebview();
  }

  void _initWebview() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
              _urlInputController.text = url;
            });
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            _injectProtectionRules();
          },
          onNavigationRequest: (request) {
            // Check for tracking URL parameters and strip them dynamically
            if (UrlSanitizer.hasTrackingParameters(request.url)) {
              final cleaned = UrlSanitizer.sanitizeUrl(request.url);
              _controller.loadRequest(Uri.parse(cleaned));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  Future<void> _injectProtectionRules() async {
    final protection = context.read<ProtectionProvider>();
    final settings = protection.settings;

    // Inject Cosmetic CSS for Ads and Search Cleanup
    if (settings.isAdBlockingEnabled || settings.isCleanSearchEnabled) {
      final jsCode = '''
        (function() {
          let count = 0;
          const adSelectors = '[id*="google_ads"], [class*="ad-container"], [class*="sponsored"], .adsbygoogle, #tvcap';
          document.querySelectorAll(adSelectors).forEach(el => {
            el.style.display = 'none';
            count++;
          });
          return count;
        })();
      ''';
      final result = await _controller.runJavaScriptReturningResult(jsCode);
      if (mounted) {
        setState(() {
          _blockedElementsCount = int.tryParse(result.toString()) ?? _blockedElementsCount;
        });
      }
    }
  }

  void _loadUrl(String input) {
    var url = input.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      if (url.contains('.') && !url.contains(' ')) {
        url = 'https://$url';
      } else {
        url = 'https://duckduckgo.com/?q=${Uri.encodeComponent(url)}';
      }
    }
    final sanitized = UrlSanitizer.sanitizeUrl(url);
    _controller.loadRequest(Uri.parse(sanitized));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: CustomAppBar(
        title: 'Shield Browser',
        subtitle: 'Live webview with on-device content filtering',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: StatusBadge(
                text: '$_blockedElementsCount blocked',
                type: BadgeType.success,
                icon: Icons.shield_rounded,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // URL Navigation Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlInputController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                    onSubmitted: _loadUrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter URL or search...',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.primary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                  onPressed: () => _loadUrl(_urlInputController.text),
                ),
              ],
            ),
          ),

          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: AppColors.surfaceDarkSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 2,
            ),

          // Webview Viewport
          Expanded(
            child: ClipRRect(
              child: WebViewWidget(controller: _controller),
            ),
          ),

          // Bottom Quick Browser Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => _controller.goBack(),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  onPressed: () => _controller.goForward(),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  onPressed: () => _controller.reload(),
                ),
                IconButton(
                  icon: const Icon(Icons.security_rounded, size: 20, color: AppColors.primary),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Site Shield Active: Cosmetic Ad blocker & Tracker Stripper enabled.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
