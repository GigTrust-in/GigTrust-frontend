import 'package:flutter/material.dart';

/// A reusable confirmation dialog with customizable content and actions
class ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? details;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final VoidCallback? onConfirm;
  final bool destructive;
  final Widget? child;

  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor,
    this.onConfirm,
    this.destructive = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveConfirmColor = confirmColor ?? 
        (destructive ? theme.colorScheme.error : theme.colorScheme.primary);

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (details != null) ...[
              const SizedBox(height: 16),
              Text(
                details!,
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (child != null) ...[
              const SizedBox(height: 16),
              child!,
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm?.call();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveConfirmColor,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}