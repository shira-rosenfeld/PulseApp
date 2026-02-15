import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
        children:,
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
          
          // Sticky Save Footer
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: hasChanges? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                boxShadow:,
              ),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1024),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:,
                          ),
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
                        onPressed: () => ref.read(hasChangesProvider.notifier).state = false,
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
    final week = ref.watch(weekProvider);
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
                children:,
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref.read(weekProvider.notifier).state = (week > 1? week - 1 : 1),
                          icon: Icon(LucideIcons.chevronLeft.dir(), size: 18, color: const Color(0xFF64748B)),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), border: Border.all(color: const Color(0xFFDBEAFE)), borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children:,
                            onChanged: (val) => ref.read(proxyUserProvider.notifier).state = val!,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiAndFilters(WidgetRef ref) {
    final totalHours = ref.watch(totalWeeklyHoursProvider);
    final filter = ref.watch(taskFilterProvider);
    final tasks = ref.watch(workerTasksProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children:.contains(t.status.code)).length}', LucideIcons.checkCircle, const Color(0xFFFAF5FF), const Color(0xFF7E22CE), const Color(0xFF1E293B)),
          ],
        ),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.all(4),
          child: Row(
            children:.map((f) {
              final isSelected = filter == f;
              String label = f == 'ALL'? 'הכל' : f == 'OPEN'? 'פתוח לדיווח' : 'סגור/בוטל';
              return GestureDetector(
                onTap: () => ref.read(taskFilterProvider.notifier).state = f,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: isSelected? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(6), boxShadow: isSelected? :),
                  child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected? const Color(0xFF2563EB) : const Color(0xFF64748B))),
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
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFF1F5F9)), borderRadius: BorderRadius.circular(12), boxShadow: const),
      child: Row(
        children:,
          )
        ],
      ),
    );
  }

  Widget _buildTaskCard(WorkerTask task, WidgetRef ref) {
    final isLocked = ['40', '90'].contains(task.status.code);
    final isOverBudget = (task.totalReported + task.reportedThisWeek) > task.planned;
    final statusColor = _getStatusColor(task.status);

    return Container(
      decoration: BoxDecoration(
        color: isLocked? const Color(0xFFF8FAFC) : Colors.white,
        border: Border.all(color: isLocked? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const,
      ),
      child: Stack(
        children:,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: Text(task.desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: task.status == WorkItemStatus.canceled? const Color(0xFF94A3B8) : const Color(0xFF1E293B), decoration: task.status == WorkItemStatus.canceled? TextDecoration.lineThrough : null)),
                ),
                const Spacer(),
                Row(
                  children:,
                            onChanged: (val) => ref.read(workerTasksProvider.notifier).updateStatus(task.id, val!),
                          ),
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
                          children:,
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
                  children:,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (task.totalReported + task.reportedThisWeek) / task.planned,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: isOverBudget? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:,
                    ),
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