import 'package:flutter/material.dart';
import '../core/app_strings.dart';
import '../models/enums/work_item_status.dart';

class StatusBadge extends StatelessWidget {
  final WorkItemStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor; Color textColor; Color borderColor; String label; bool isCanceled = false;

    switch (status) {
      case WorkItemStatus.newTask:
        bgColor = const Color(0xFFF1F5F9); textColor = const Color(0xFF475569); borderColor = const Color(0xFFE2E8F0); label = AppStrings.statusNew; break;
      case WorkItemStatus.inProgress:
        bgColor = const Color(0xFFFFF7ED); textColor = const Color(0xFFEA580C); borderColor = const Color(0xFFFED7AA); label = AppStrings.statusInProgress; break;
      case WorkItemStatus.onHold:
        bgColor = const Color(0xFFEFF6FF); textColor = const Color(0xFF1D4ED8); borderColor = const Color(0xFFBFDBFE); label = AppStrings.statusOnHold; break;
      case WorkItemStatus.done:
        bgColor = const Color(0xFFECFDF5); textColor = const Color(0xFF059669); borderColor = const Color(0xFFA7F3D0); label = AppStrings.statusDone; break;
      case WorkItemStatus.canceled:
        bgColor = const Color(0xFFFEF2F2); textColor = const Color(0xFFEF4444); borderColor = const Color(0xFFFEE2E2); label = AppStrings.statusCanceled; isCanceled = true; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bgColor, border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor, decoration: isCanceled? TextDecoration.lineThrough : null),
      ),
    );
  }
}