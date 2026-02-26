import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/app_strings.dart';
import '../providers/pulse_providers.dart';
import '../models/dtos/target.dart';
import '../models/dtos/output.dart';
import '../models/dtos/work_item.dart';
import '../models/enums/worker_type.dart';
import 'status_badge.dart';
import 'task_modals.dart';

class ManagerWorkspace extends ConsumerWidget {
  const ManagerWorkspace({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredData = ref.watch(filteredDataProvider);
    final expandedNodes = ref.watch(expandedNodesProvider);

    // Flatten the hierarchical tree for lazy-loading performance
    final flatList = _buildFlatList(context, filteredData, expandedNodes, ref);

    return Scaffold(
      appBar: _buildHeader(ref),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTableHeader(),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: flatList.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                itemBuilder: (context, index) => flatList[index],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFlatList(BuildContext context, List<Target> targets, Map<String, bool> expandedNodes, WidgetRef ref) {
    final List<Widget> list = [];
    for (var target in targets) {
      list.add(_buildTargetRow(target, expandedNodes, ref));
      if (expandedNodes[target.id] == true) {
        for (var output in target.children) {
          list.add(_buildOutputRow(context, output, expandedNodes, ref));
          if (expandedNodes[output.id] == true) {
            if (output.children.isEmpty) {
              list.add(
                const Padding(
                  padding: EdgeInsetsDirectional.only(end: 64, top: 16, bottom: 16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(AppStrings.noTasks, style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
                  ),
                ),
              );
            } else {
              for (var item in output.children) {
                list.add(_buildWorkItemRow(context, item));
              }
            }
          }
        }
      }
    }
    return list;
  }

  PreferredSizeWidget _buildHeader(WidgetRef ref) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.layoutDashboard, size: 20, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.appTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    Text('ניהול מטלות', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: 300,
              child: TextField(
                onChanged: (val) => ref.read(searchQueryProvider.notifier).set(val),
                decoration: InputDecoration(
                  hintText: AppStrings.searchPlaceholder,
                  prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
                  filled: true, fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            const CircleAvatar(
              backgroundColor: Color(0xFF1E293B),
              child: Text('י.י', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Row(
        children: [
          Expanded(flex: 5, child: Text(AppStrings.hierarchyCol, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
          Expanded(flex: 2, child: Center(child: Text(AppStrings.statusCol, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))))),
          Expanded(flex: 2, child: Text(AppStrings.workerCol, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
          Expanded(flex: 2, child: Text(AppStrings.progressCol, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
          Expanded(flex: 1, child: Center(child: Text(AppStrings.actionsCol, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))))),
        ],
      ),
    );
  }

  Widget _buildTargetRow(Target target, Map<String, bool> expandedNodes, WidgetRef ref) {
    bool isExpanded = expandedNodes[target.id] ?? false;
    return InkWell(
      onTap: () => ref.read(expandedNodesProvider.notifier).toggle(target.id),
      child: Container(
        color: const Color(0xFFF1F5F9).withAlpha(178), // 70% opacity
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight, size: 16, color: const Color(0xFF64748B)),
            const SizedBox(width: 8),
            const Icon(LucideIcons.folder, size: 16, color: Color(0xFF2563EB)),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(target.id, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  Text(target.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ],
              ),
            ),
            Expanded(
              flex: 7,
              child: Text('${target.stats['total'] ?? 0} מטלות', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputRow(BuildContext context, Output output, Map<String, bool> expandedNodes, WidgetRef ref) {
    bool isExpanded = expandedNodes[output.id] ?? false;
    return InkWell(
      onTap: () => ref.read(expandedNodesProvider.notifier).toggle(output.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: BorderDirectional(start: BorderSide(color: isExpanded ? const Color(0xFF3B82F6) : Colors.transparent, width: 4)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const SizedBox(width: 24),
            Icon(isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight, size: 14, color: const Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            const Icon(LucideIcons.fileText, size: 14, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(output.id, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  Text(output.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                ],
              ),
            ),
            Expanded(
              flex: 7,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    backgroundColor: const Color(0xFFEFF6FF),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: () => showDialog(context: context, builder: (_) => const CreateTaskModal()),
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text('הוסף מטלה', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWorkItemRow(BuildContext context, WorkItem item) {
    bool isCanceled = item.status.name == 'canceled';
    return Container(
      color: isCanceled ? const Color(0xFFF8FAFC).withAlpha(127) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 48),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.id, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                Text(
                  item.desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: isCanceled ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                    decoration: isCanceled ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Center(child: StatusBadge(status: item.status))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.worker.type == WorkerType.internal ? Colors.blue[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.worker.name[0],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: item.worker.type == WorkerType.internal ? Colors.blue : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.worker.name, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                    Text(
                      item.worker.type == WorkerType.internal ? AppStrings.internalWorker : AppStrings.externalWorker,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.actual.toStringAsFixed(1)} ימים', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      Text('/ ${item.planned.toStringAsFixed(1)} ימים', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: item.actual / item.planned,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF1F5F9),
                      color: item.actual > item.planned ? Colors.red : Colors.green,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: PopupMenuButton<String>(
                icon: const Icon(LucideIcons.ellipsisVertical, size: 16, color: Color(0xFF94A3B8)),
                color: Colors.white,
                position: PopupMenuPosition.under,
                onSelected: (value) {
                  if (value == 'edit') {
                    showDialog(context: context, builder: (_) => const EditTaskModal());
                  } else if (value == 'delete') {
                    showDialog(context: context, builder: (_) => const DeleteConfirmModal());
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(LucideIcons.pencil, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(AppStrings.actionEdit),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(LucideIcons.trash2, size: 14, color: Color(0xFFEF4444)),
                        SizedBox(width: 8),
                        Text(AppStrings.actionDelete, style: TextStyle(color: Color(0xFFEF4444))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
