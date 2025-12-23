import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/chat_controller.dart';
import '../../models/chat_model.dart';
import 'model_picker_sheet.dart';

class ModelSelectorButton extends GetView<ChatController> {
  const ModelSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final model = controller.selectedModel.value;

      return GestureDetector(
        onTap: () => _openPicker(context),
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                model.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.expand_more, size: 18, color: Colors.white70),
            ],
          ),
        ),
      );
    });
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const ModelPickerSheet(),
    );
  }
}
