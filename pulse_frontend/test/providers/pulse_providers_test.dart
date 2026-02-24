import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_frontend/providers/pulse_providers.dart';

void main() {
  group('filteredDataProvider', () {
    test('empty query returns all data', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).state = '';
      final result = container.read(filteredDataProvider);
      final allData = container.read(wbsDataProvider);

      expect(result.length, allData.length);
    });

    test('query matching target name filters correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Use part of the first target's name
      container.read(searchQueryProvider.notifier).state = 'פיתוח מערכת';
      final result = container.read(filteredDataProvider);

      expect(result.isNotEmpty, true);
      expect(result.any((t) => t.name.contains('פיתוח מערכת')), true);
    });

    test('query matching worker name filters correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).state = 'יוסי כהן';
      final result = container.read(filteredDataProvider);

      expect(result.isNotEmpty, true);
      // All returned work items should contain the worker name
      final allItems = result
          .expand((t) => t.children)
          .expand((o) => o.children);
      expect(allItems.every((i) => i.worker.name == 'יוסי כהן'), true);
    });

    test('query with no match returns empty list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).state = 'zzzznotexist';
      final result = container.read(filteredDataProvider);

      expect(result.isEmpty, true);
    });
  });

  group('ExpandedNodesNotifier.toggle', () {
    test('toggle sets false node to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(expandedNodesProvider.notifier).toggle('NEW-NODE');
      expect(container.read(expandedNodesProvider)['NEW-NODE'], true);
    });

    test('toggle sets true node to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // WBS-2026.10 is initially true in the seed state
      container.read(expandedNodesProvider.notifier).toggle('WBS-2026.10');
      expect(container.read(expandedNodesProvider)['WBS-2026.10'], false);
    });

    test('toggle twice restores original state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = container.read(expandedNodesProvider)['WBS-2026.10'] ?? false;
      container.read(expandedNodesProvider.notifier).toggle('WBS-2026.10');
      container.read(expandedNodesProvider.notifier).toggle('WBS-2026.10');
      expect(container.read(expandedNodesProvider)['WBS-2026.10'], initial);
    });
  });
}
