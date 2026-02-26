import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/app_strings.dart';
import '../models/dtos/worker_task.dart';
import '../models/enums/work_item_status.dart';
import '../providers/worker_providers.dart';

class WorkerWorkspace extends ConsumerWidget {
  const WorkerWorkspace({super.key});

  Color _getStatusColor(WorkItemStatus status) {
    switch (status) {
      case WorkItemStatus.newTask: return const Color(0xFFCBD5E1); // slate-300
      case WorkItemStatus.inProgress: return const Color(0xFFF97316); // orange-500
      case WorkItemStatus.onHold: return const Color(0xFF2563EB); // blue-600
      case WorkItemStatus.done: return const Color(0xFF10B981); // emerald-500
      case WorkItemStatus.canceled: return const Color(0xFFEF4444); // red-500
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(filteredWorkerTasksProvider);
    final hasChanges = ref.watch(hasChangesProvider);

    return Scaffold(
      appBar: _buildAppBar(ref),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1024),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildKpiAndFilters(ref),
                        const SizedBox(height: 24),
                        if (tasks.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48),
                              child: Text(
                                'אין מטלות להצגה',
                                style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 380,
                              mainAxisExtent: 220,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) => _buildTaskCard(tasks[index], ref),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Sticky Save Footer
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: hasChanges ? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                boxShadow: [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -4)),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1024),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(LucideIcons.info, size: 16, color: Color(0xFF2563EB)),
                          SizedBox(width: 8),
                          Text('יש שינויים שלא נשמרו', style: TextStyle(fontSize: 14, color: Color(0xFF334155))),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 4,
                        ),
                        onPressed: () => ref.read(hasChangesProvider.notifier).set(false),
                        icon: const Icon(LucideIcons.save, size: 18),
                        label: const Text('שמור שינויים', style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(WidgetRef ref) {
    final proxyUser = ref.watch(proxyUserProvider);

    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1024),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.layoutDashboard, size: 20, color: Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(AppStrings.appTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          Text('המטלות שלי', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), border: Border.all(color: const Color(0xFFDBEAFE)), borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.user, size: 14, color: Color(0xFF2563EB)),
                        const SizedBox(width: 6),
                        DropdownButton<String>(
                          value: proxyUser,
                          underline: const SizedBox(),
                          isDense: true,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                          items: const [
                            DropdownMenuItem(value: 'SELF', child: Text('עצמי')),
                            DropdownMenuItem(value: 'שירה רוזנפלד', child: Text('שירה רוזנפלד')),
                            DropdownMenuItem(value: 'יוסי כהן', child: Text('יוסי כהן')),
                          ],
                          onChanged: (val) => ref.read(proxyUserProvider.notifier).set(val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiAndFilters(WidgetRef ref) {
    final totalDays = ref.watch(totalWeeklyDaysProvider);
    final filter = ref.watch(taskFilterProvider);
    final tasks = ref.watch(workerTasksProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            _buildStatCard('סה"כ ימים השבוע', '${totalDays.toStringAsFixed(1)} ימים', LucideIcons.clock, const Color(0xFFF0FDF4), const Color(0xFF16A34A), const Color(0xFF1E293B)),
            const SizedBox(width: 12),
            _buildStatCard('משימות פתוחות', '${tasks.where((t) => ['10', '20', '30'].contains(t.status.code)).length}', LucideIcons.listTodo, const Color(0xFFFFF7ED), const Color(0xFFEA580C), const Color(0xFF1E293B)),
            const SizedBox(width: 12),
            _buildStatCard('הושלמו', '${tasks.where((t) => ['40', '90'].contains(t.status.code)).length}', LucideIcons.circleCheck, const Color(0xFFFAF5FF), const Color(0xFF7E22CE), const Color(0xFF1E293B)),
          ],
        ),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: ['ALL', 'OPEN', 'CLOSED'].map((f) {
              final isSelected = filter == f;
              String label = f == 'ALL' ? 'הכל' : f == 'OPEN' ? 'פתוח לדיווח' : 'סגור/בוטל';
              return GestureDetector(
                onTap: () => ref.read(taskFilterProvider.notifier).set(f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isSelected
                        ? [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))]
                        : [],
                  ),
                  child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B))),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color bgColor, Color iconColor, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(minWidth: 160),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(WorkerTask task, WidgetRef ref) {
    final isLocked = ['40', '90'].contains(task.status.code);
    final isDaysLocked = ['30', '40', '90'].contains(task.status.code);
    final isOverBudget = (task.totalReported + task.reportedThisWeek) > task.planned;
    final statusColor = _getStatusColor(task.status);

    return Container(
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFFF8FAFC) : Colors.white,
        border: Border.all(color: isLocked ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Stack(
        children: [
          // Status color bar at top
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.path, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: Text(
                    task.desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: task.status == WorkItemStatus.canceled ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                      decoration: task.status == WorkItemStatus.canceled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButton<WorkItemStatus>(
                          value: task.status,
                          isExpanded: true,
                          underline: const SizedBox(),
                          isDense: true,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                          items: WorkItemStatus.values.map((s) {
                            const labels = {'newTask': 'חדש', 'inProgress': 'בביצוע', 'onHold': 'מוקפא', 'done': 'הסתיים', 'canceled': 'בוטל'};
                            return DropdownMenuItem(value: s, child: Text(labels[s.name] ?? s.name));
                          }).toList(),
                          onChanged: isLocked ? null : (val) => ref.read(workerTasksProvider.notifier).updateStatus(task.id, val!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                        // Direct Alpha manipulation instead of Opacity Widget for sublinear layout speeds
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.minus, size: 12),
                              onPressed: isDaysLocked ? null : () => ref.read(workerTasksProvider.notifier).updateDays(task.id, -0.5),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              color: const Color(0xFF64748B),
                            ),
                            Text('${task.reportedThisWeek.toStringAsFixed(1)} ימים', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            IconButton(
                              icon: const Icon(LucideIcons.plus, size: 12),
                              onPressed: isDaysLocked ? null : () => ref.read(workerTasksProvider.notifier).updateDays(task.id, 0.5),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              color: const Color(0xFF2563EB),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(task.totalReported + task.reportedThisWeek).toStringAsFixed(1)} ימים', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Text('/ ${task.planned.toStringAsFixed(1)} ימים', style: TextStyle(fontSize: 12, color: isOverBudget ? const Color(0xFFEF4444) : const Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (task.totalReported + task.reportedThisWeek) / task.planned,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: isOverBudget ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(task.actualStart ?? 'טרם החל', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    if (isLocked) const Icon(LucideIcons.lock, size: 12, color: Color(0xFFCBD5E1)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
