import 'work_item.dart';

class Output {
  final String id;
  final String name;
  final List<WorkItem> children;

  Output({required this.id, required this.name, required this.children});
  
  Output copyWith({List<WorkItem>? children}) {
    return Output(
      id: id, 
      name: name, 
      children: children?? this.children
    );
  }
}