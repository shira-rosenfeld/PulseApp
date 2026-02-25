import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_frontend/models/enums/work_item_status.dart';

void main() {
  group('WorkItemStatus', () {
    test('fromCode returns correct status for valid codes', () {
      expect(WorkItemStatus.fromCode('10'), WorkItemStatus.newTask);
      expect(WorkItemStatus.fromCode('20'), WorkItemStatus.inProgress);
      expect(WorkItemStatus.fromCode('30'), WorkItemStatus.onHold);
      expect(WorkItemStatus.fromCode('40'), WorkItemStatus.done);
      expect(WorkItemStatus.fromCode('90'), WorkItemStatus.canceled);
    });

    test('fromCode falls back to newTask for unknown code', () {
      expect(WorkItemStatus.fromCode('99'), WorkItemStatus.newTask);
      expect(WorkItemStatus.fromCode(''), WorkItemStatus.newTask);
      expect(WorkItemStatus.fromCode('abc'), WorkItemStatus.newTask);
    });

    test('each enum has the correct code value', () {
      expect(WorkItemStatus.newTask.code, '10');
      expect(WorkItemStatus.inProgress.code, '20');
      expect(WorkItemStatus.onHold.code, '30');
      expect(WorkItemStatus.done.code, '40');
      expect(WorkItemStatus.canceled.code, '90');
    });
  });
}
