class AddPhotosListItem {
  final String name;
  final String path;
  final String location;
  final String collaborator;
  final bool processing;
  final bool fromFirebase;
  String? firebasePath;

  AddPhotosListItem(
      {required this.name,
      required this.fromFirebase,
      required this.processing,
      required this.path,
      required this.location,
      required this.collaborator,
      this.firebasePath});
}
