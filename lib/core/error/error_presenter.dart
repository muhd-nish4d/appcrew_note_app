import 'package:flutter/material.dart';
import 'failure.dart';

class ErrorPresenter {
  static void showError(BuildContext context, Failure failure) {
    final theme = Theme.of(context);
    final isNetwork = failure.code == 'network-error' || failure.code == 'network-request-failed';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isNetwork ? Icons.wifi_off : Icons.error_outline,
                color: theme.colorScheme.onError,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  failure.message,
                  style: TextStyle(color: theme.colorScheme.onError),
                ),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 4),
          action: isNetwork
              ? SnackBarAction(
                  label: 'OK',
                  textColor: theme.colorScheme.onError,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                )
              : null,
        ),
      );
  }
}
