class AddPhotosListItem {
  final String name;
  final String path;
  final String location;
  final String collaborator;
  final bool processing;
  String? firebasePath;

  AddPhotosListItem({
    required this.name,
    required this.processing,
    required this.path,
    required this.location,
    required this.collaborator,
    this.firebasePath
  });
}
