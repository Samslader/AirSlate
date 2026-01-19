import 'package:isar/isar.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;
  
  late String content;
  
  @Index()
  late DateTime createdAt;
  
  @Index()
  late DateTime lastModifiedAt;
  
  Note({
    required this.content,
  }) : createdAt = DateTime.now(),
       lastModifiedAt = DateTime.now();
  
  String get preview {
    const maxLength = 100;
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }
}
