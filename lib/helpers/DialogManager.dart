import 'package:flutter/material.dart';

class DialogManager {
  /// Show simple info dialog with OK button
  static Future<void> showInfoDialog(
      BuildContext context, String title, String message) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  /// Show Yes/No confirmation dialog
  static Future<bool?> showYesNoDialog(
      BuildContext context, String title, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text("Yes"),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
  }

  /// Show Yes/No/Cancel dialog
  static Future<String?> showYesNoCancelDialog(
      BuildContext context, String title, String message) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop("cancel"),
          ),
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.of(ctx).pop("no"),
          ),
          TextButton(
            child: const Text("Yes"),
            onPressed: () => Navigator.of(ctx).pop("yes"),
          ),
        ],
      ),
    );
  }

  /// Show input prompt dialog
  static Future<String?> showPromptDialog(
      BuildContext context, String title, String message) async {
    final TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter here",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(null),
          ),
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(ctx).pop(controller.text),
          ),
        ],
      ),
    );
  }
}
