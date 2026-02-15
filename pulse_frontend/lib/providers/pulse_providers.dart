import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dtos/target.dart';
import '../models/dtos/output.dart';
import '../models/dtos/work_item.dart';
import '../models/dtos/worker.dart';
import '../models/enums/worker_type.dart';
import '../models/enums/work_item_status.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final expandedNodesProvider = StateNotifierProvider<ExpandedNodesNotifier, Map<String, bool>>((ref) {
  return ExpandedNodesNotifier({'WBS-2026.10': true, 'NET-80001': true, 'NET-80002': true});
});

class ExpandedNodesNotifier extends StateNotifier<Map<String, bool>> {
  ExpandedNodesNotifier(super.state);
  void toggle(String id) {
    state = {...state, id:!(state[id]?? false)};
  }
}

// Mock Data Source
final wbsDataProvider = Provider<List<Target>>((ref) {
  return,
        ),
      ],
    )
  ];
});

// Deep Search Logic (Targets, Outputs, and Workers)
final filteredDataProvider = Provider<List<Target>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final data = ref.watch(wbsDataProvider);
  
  if (query.isEmpty) return data;

  List<Target> result =;
  
  for (var target in data) {
    bool targetMatches = target.name.toLowerCase().contains(query) |

| target.id.toLowerCase().contains(query);
    List<Output> filteredOutputs =;

    for (var output in target.children) {
      bool outputMatches = output.name.toLowerCase().contains(query) |

| output.id.toLowerCase().contains(query);
      List<WorkItem> filteredItems =;

      for (var item in output.children) {
        // Matches Task Description, Task ID, OR Worker Name
        bool itemMatches = item.desc.toLowerCase().contains(query) ||
                           item.id.toLowerCase().contains(query) ||
                           item.worker.name.toLowerCase().contains(query);
                           
        if (itemMatches |

| outputMatches |
| targetMatches) {
          filteredItems.add(item);
        }
      }

      if (filteredItems.isNotEmpty |

| outputMatches |
| targetMatches) {
        filteredOutputs.add(output.copyWith(
          children: (filteredItems.isEmpty && (outputMatches |

| targetMatches))? output.children : filteredItems
        ));
      }
    }

    if (filteredOutputs.isNotEmpty |

| targetMatches) {
      result.add(target.copyWith(
        children: (filteredOutputs.isEmpty && targetMatches)? target.children : filteredOutputs
      ));
    }
  }
  return result;
});