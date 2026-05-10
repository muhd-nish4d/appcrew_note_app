import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/network_provider.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isOffline = context.watch<NetworkProvider>().isOffline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isOffline ? 40 : 0,
      width: double.infinity,
      color: Colors.redAccent,
      alignment: Alignment.center,
      child: isOffline
          ? const Text(
              'No Internet Connection',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
