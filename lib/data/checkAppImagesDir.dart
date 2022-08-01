import 'dart:io';

class CheckAppImagesDir{
  ///Verifica se existe/cria o diretório
  checkDir(String dirPath) async {
    if (await Directory(dirPath).exists()) {
      print('The directory already exists');
      print('Directory: $dirPath');
      return true;
    } else {
      print('The directory doesn\'t exists');
      print('Creating directory');
      await Directory(dirPath).create();
      print('Directory created');
      print('Directory: $dirPath');
      return true;
    }
  }
}