import 'dart:io';

///Verifica se existe/cria o diretório
class CheckAppImagesDir {
  checkDir(String dirPath) async {
    if (await Directory(dirPath).exists()) {
      print('The directory already exists');
      print('Directory: $dirPath');
      return true;
    } else {
      print('The directory doesn\'t exists');
      print('Creating directory');
      await Directory(dirPath).create(recursive: true);
      print('Directory created');
      print('Directory: $dirPath');
      return true;
    }
  }
}
