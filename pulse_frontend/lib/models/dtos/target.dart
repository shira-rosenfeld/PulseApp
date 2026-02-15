import 'output.dart';

class Target {
  final String id;
  final String name;
  final Map<String, int> stats;
  final List<Output> children;

  Target({required this.id, required this.name, required this.stats, required this.children});
  
  Target copyWith({List<Output>? children}) {
    return Target(
      id: id, 
      name: name, 
      stats: stats, 
      children: children?? this.children
    );
  }
}