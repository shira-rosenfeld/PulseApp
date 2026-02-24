import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dtos/worker_task.dart';
import '../models/enums/work_item_status.dart';
import '../models/enums/worker_type.dart';

class WeekNotifier extends Notifier<int> {
  @override
  int build() => 5;
}

final weekProvider = NotifierProvider<WeekNotifier, int>(WeekNotifier.new);

class TaskFilterNotifier extends Notifier<String> {
  @override
  String build() => 'OPEN';
}

final taskFilterProvider = NotifierProvider<TaskFilterNotifier, String>(TaskFilterNotifier.new);

class ProxyUserNotifier extends Notifier<String> {
  @override
  String build() => 'SELF';
}

final proxyUserProvider = NotifierProvider<ProxyUserNotifier, String>(ProxyUserNotifier.new);

class HasChangesNotifier extends Notifier<bool> {
  @override
  bool build() => false;
}

final hasChangesProvider = NotifierProvider<HasChangesNotifier, bool>(HasChangesNotifier.new);

final workerTasksProvider = NotifierProvider<WorkerTasksNotifier, List<WorkerTask>>(WorkerTasksNotifier.new);

List<WorkerTask> _initialTasks() {
  return [
    WorkerTask(
      id: 'TASK-1004',
      path: 'WBS-2026.10 / NET-80002',
      desc: 'ממשק מנהל - שולחן עבודה',
      status: WorkItemStatus.inProgress,
      planned: 20,
      totalReported: 14,
      reportedThisWeek: 0,
      actualStart: '2026-01-15',
      workerType: WorkerType.internal,
    ),
    WorkerTask(
      id: 'TASK-1005',
      path: 'WBS-2026.10 / NET-80002',
      desc: 'ממשק עובד - דיווח שבועי',
      status: WorkItemStatus.inProgress,
      planned: 16,
      totalReported: 10,
      reportedThisWeek: 0,
      actualStart: '2026-01-20',
      workerType: WorkerType.internal,
    ),
    WorkerTask(
      id: 'TASK-1006',
      path: 'WBS-2026.10 / NET-80002',
      desc: 'בדיקות UI',
      status: WorkItemStatus.newTask,
      planned: 12,
      totalReported: 0,
      reportedThisWeek: 0,
      workerType: WorkerType.internal,
    ),
    WorkerTask(
      id: 'TASK-1002',
      path: 'WBS-2026.10 / NET-80001',
      desc: 'תכנון API',
      status: WorkItemStatus.onHold,
      planned: 8,
      totalReported: 5,
      reportedThisWeek: 0,
      actualStart: '2026-01-10',
      workerType: WorkerType.internal,
    ),
    WorkerTask(
      id: 'TASK-1001',
      path: 'WBS-2026.10 / NET-80001',
      desc: 'עיצוב מסד נתונים',
      status: WorkItemStatus.done,
      planned: 10,
      totalReported: 9,
      reportedThisWeek: 0,
      actualStart: '2026-01-05',
      workerType: WorkerType.internal,
    ),
    WorkerTask(
      id: 'TASK-1013',
      path: 'WBS-2026.11 / NET-80005',
      desc: 'בדיקות חדירה',
      status: WorkItemStatus.canceled,
      planned: 8,
      totalReported: 0,
      reportedThisWeek: 0,
      workerType: WorkerType.external,
    ),
  ];
}

class WorkerTasksNotifier extends Notifier<List<WorkerTask>> {
  @override
  List<WorkerTask> build() => _initialTasks();

  void updateHours(String id, double delta) {
    ref.read(hasChangesProvider.notifier).state = true;
    state = state.map((task) {
      if (task.id != id) return task;

      final newVal = (task.reportedThisWeek + delta) < 0 ? 0.0 : (task.reportedThisWeek + delta);
      WorkItemStatus newStatus = task.status;

      // Optimistic UI: If hours reported on 'New' task, move to 'InProgress'
      if (newVal > 0 && task.status == WorkItemStatus.newTask) {
        newStatus = WorkItemStatus.inProgress;
      }
      return task.copyWith(reportedThisWeek: newVal, status: newStatus);
    }).toList();
  }

  void updateStatus(String id, WorkItemStatus newStatus) {
    ref.read(hasChangesProvider.notifier).state = true;
    state = state.map((task) => task.id == id ? task.copyWith(status: newStatus) : task).toList();
  }
}

final filteredWorkerTasksProvider = Provider<List<WorkerTask>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final tasks = ref.watch(workerTasksProvider);

  return tasks.where((task) {
    if (filter == 'ALL') return true;
    if (filter == 'OPEN') return [WorkItemStatus.newTask, WorkItemStatus.inProgress, WorkItemStatus.onHold].contains(task.status);
    if (filter == 'CLOSED') return [WorkItemStatus.done, WorkItemStatus.canceled].contains(task.status);
    return true;
  }).toList();
});

final totalWeeklyHoursProvider = Provider<double>((ref) {
  final tasks = ref.watch(workerTasksProvider);
  return tasks.fold(0.0, (sum, task) => sum + task.reportedThisWeek);
});
