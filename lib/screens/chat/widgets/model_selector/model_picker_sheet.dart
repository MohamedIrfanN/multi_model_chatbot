import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/chat_controller.dart';
import '../../models/chat_model.dart';

class ModelPickerSheet extends GetView<ChatController> {
  const ModelPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ChatModel.values.map((model) {
          return Obx(() {
            final isSelected =
                controller.selectedModel.value == model;

            return ListTile(
              onTap: () {
                controller.setModel(model);
                Navigator.pop(context);
              },
              leading: Icon(
                isSelected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color:
                    isSelected ? Colors.greenAccent : Colors.white38,
              ),
              title: Text(
                model.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }
}