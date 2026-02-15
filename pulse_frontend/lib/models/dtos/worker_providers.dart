import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dtos/worker_task.dart';
import '../models/enums/work_item_status.dart';
import '../models/enums/worker_type.dart';

final weekProvider = StateProvider<int>((ref) => 5);
final taskFilterProvider = StateProvider<String>((ref) => 'OPEN');
final proxyUserProvider = StateProvider<String>((ref) => 'SELF');
final hasChangesProvider = StateProvider<bool>((ref) => false);

final workerTasksProvider = StateNotifierProvider<WorkerTasksNotifier, List<WorkerTask>>((ref) {
  return WorkerTasksNotifier(ref,);
});

class WorkerTasksNotifier extends StateNotifier<List<WorkerTask>> {
  final Ref ref;
  WorkerTasksNotifier(this.ref, super.state);

  void updateHours(String id, double delta) {
    ref.read(hasChangesProvider.notifier).state = true;
    state = state.map((task) {
      if (task.id!= id) return task;
      
      final newVal = (task.reportedThisWeek + delta) < 0? 0.0 : (task.reportedThisWeek + delta);
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
    state = state.map((task) => task.id == id? task.copyWith(status: newStatus) : task).toList();
  }
}

final filteredWorkerTasksProvider = Provider<List<WorkerTask>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final tasks = ref.watch(workerTasksProvider);

  return tasks.where((task) {
    if (filter == 'ALL') return true;
    if (filter == 'OPEN') return.contains(task.status);
    if (filter == 'CLOSED') return.contains(task.status);
    return true;
  }).toList();
});

final totalWeeklyHoursProvider = Provider<double>((ref) {
  final tasks = ref.watch(workerTasksProvider);
  return tasks.fold(0.0, (sum, task) => sum + task.reportedThisWeek);
});