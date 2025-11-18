import 'package:flutter/material.dart';

class LoaderController {
  // keep it public so we can debug easily
  static final ValueNotifier<bool> isLoading = ValueNotifier(false);

  static void showLoader() {
    isLoading.value = true;
  }

  static void hideLoader() {
    isLoading.value = false;
  }

  void simulateProcess() async {
    showLoader();
    debugPrint("Loader enabled ✅");

    // fake delay
    await Future.delayed(const Duration(seconds: 3));

    LoaderController.hideLoader();
    debugPrint("Loader disabled ✅");
  }

  static Widget overlay({required Widget child}) {
    return Stack(
      children: [
        child,
        // This will rebuild when isLoading.value changes
        ValueListenableBuilder<bool>(
          valueListenable: isLoading,
          builder: (context, loading, _) {
            if (!loading) return const SizedBox.shrink();
            return Container(
              color: Colors.black54, // dim background
              child: Center(
                child: Image.asset(
                  'assets/loader.gif',
                  width: 128,
                  height: 128,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
