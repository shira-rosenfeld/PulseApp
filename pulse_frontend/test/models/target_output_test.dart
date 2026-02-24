import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_frontend/models/dtos/target.dart';
import 'package:pulse_frontend/models/dtos/output.dart';
import 'package:pulse_frontend/models/dtos/work_item.dart';
import 'package:pulse_frontend/models/dtos/worker.dart';
import 'package:pulse_frontend/models/enums/work_item_status.dart';
import 'package:pulse_frontend/models/enums/worker_type.dart';

WorkItem _makeItem(String id) => WorkItem(
  id: id,
  desc: 'Item $id',
  status: WorkItemStatus.newTask,
  worker: Worker(name: 'Test Worker', type: WorkerType.internal),
  planned: 5,
  actual: 0,
);

Output _makeOutput(String id, List<WorkItem> children) =>
    Output(id: id, name: 'Output $id', children: children);

Target _makeTarget(String id, List<Output> children) =>
    Target(id: id, name: 'Target $id', stats: {'total': children.length}, children: children);

void main() {
  group('Target.copyWith', () {
    test('replaces children list', () {
      final item = _makeItem('I1');
      final output1 = _makeOutput('O1', [item]);
      final output2 = _makeOutput('O2', []);
      final target = _makeTarget('T1', [output1]);

      final updated = target.copyWith(children: [output2]);

      expect(updated.children.length, 1);
      expect(updated.children.first.id, 'O2');
      expect(updated.id, target.id);
      expect(updated.name, target.name);
    });

    test('default copyWith returns same children', () {
      final output = _makeOutput('O1', []);
      final target = _makeTarget('T1', [output]);

      final copy = target.copyWith();
      expect(copy.children.length, 1);
      expect(copy.children.first.id, 'O1');
    });
  });

  group('Output.copyWith', () {
    test('replaces children list', () {
      final item1 = _makeItem('I1');
      final item2 = _makeItem('I2');
      final output = _makeOutput('O1', [item1]);

      final updated = output.copyWith(children: [item2]);

      expect(updated.children.length, 1);
      expect(updated.children.first.id, 'I2');
      expect(updated.id, output.id);
      expect(updated.name, output.name);
    });

    test('default copyWith returns same children', () {
      final item = _makeItem('I1');
      final output = _makeOutput('O1', [item]);

      final copy = output.copyWith();
      expect(copy.children.length, 1);
      expect(copy.children.first.id, 'I1');
    });
  });
}
