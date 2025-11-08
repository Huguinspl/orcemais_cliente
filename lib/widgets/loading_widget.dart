import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/constants.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(color: AppConstants.primaryColor, size: 50.0),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(message!, style: const TextStyle(fontSize: 16)),
          ],
        ],
      ),
    );
  }
}
