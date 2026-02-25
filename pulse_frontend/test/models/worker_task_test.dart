import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_frontend/models/dtos/worker_task.dart';
import 'package:pulse_frontend/models/enums/work_item_status.dart';
import 'package:pulse_frontend/models/enums/worker_type.dart';

WorkerTask _makeTask() {
  return WorkerTask(
    id: 'TASK-001',
    path: 'WBS-2026.10 / NET-80001',
    desc: 'Test Task',
    status: WorkItemStatus.newTask,
    planned: 10.0,
    totalReported: 3.0,
    reportedThisWeek: 0.0,
    workerType: WorkerType.internal,
  );
}

void main() {
  group('WorkerTask.copyWith', () {
    test('status change preserves other fields', () {
      final original = _makeTask();
      final updated = original.copyWith(status: WorkItemStatus.inProgress);

      expect(updated.status, WorkItemStatus.inProgress);
      expect(updated.id, original.id);
      expect(updated.path, original.path);
      expect(updated.desc, original.desc);
      expect(updated.planned, original.planned);
      expect(updated.totalReported, original.totalReported);
      expect(updated.reportedThisWeek, original.reportedThisWeek);
      expect(updated.workerType, original.workerType);
    });

    test('reportedThisWeek change preserves other fields', () {
      final original = _makeTask();
      final updated = original.copyWith(reportedThisWeek: 5.0);

      expect(updated.reportedThisWeek, 5.0);
      expect(updated.status, original.status);
      expect(updated.id, original.id);
      expect(updated.desc, original.desc);
      expect(updated.planned, original.planned);
    });

    test('copyWith with no arguments returns equivalent object', () {
      final original = _makeTask();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.status, original.status);
      expect(copy.reportedThisWeek, original.reportedThisWeek);
    });
  });
}
