import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';
import '../models/note.dart';

class IsarService {
  static Isar? _isar;
  
  static Future<Isar> getInstance() async {
    if (_isar != null) return _isar!;
    
    final dir = await getApplicationDocumentsDirectory();
    
    _isar = await Isar.open(
      [TaskSchema, NoteSchema],
      directory: dir.path,
    );
    
    return _isar!;
  }
  
  static Isar get instance {
    if (_isar == null) {
      throw Exception('IsarService not initialized. Call getInstance() first.');
    }
    return _isar!;
  }
}
