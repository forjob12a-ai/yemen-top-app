import 'package:flutter/material.dart';
import '../config/theme.dart';

/// فاصل «أو» وزر «المتابعة بحساب Google»
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.label = 'المتابعة بحساب Google',
  });

  @override
  Widget build(BuildContext context) {
    final line = Expanded(child: Divider(color: AppColors.muted.withValues(alpha: 0.3)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            line,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('أو', style: TextStyle(color: AppColors.muted)),
            ),
            line,
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Text(
            'G',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF4285F4)),
          ),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        ),
      ],
    );
  }
}
