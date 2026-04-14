import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pulse_providers.dart';
import '../core/app_strings.dart';

class WorkspaceToggle extends ConsumerWidget {
  const WorkspaceToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(currentWorkspaceProvider);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(ref, 'WORKER', AppStrings.workspaceWorker, workspace),
          _buildOption(ref, 'MANAGER', AppStrings.workspaceManager, workspace),
        ],
      ),
    );
  }

  Widget _buildOption(WidgetRef ref, String value, String label, String current) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: () => ref.read(currentWorkspaceProvider.notifier).set(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
