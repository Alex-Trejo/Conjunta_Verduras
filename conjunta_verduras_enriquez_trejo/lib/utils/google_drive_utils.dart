import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GoogleDriveUtils {
  // Método para descargar el archivo JSON desde Google Drive
  static Future<File> downloadFile() async {
    // URL directa del archivo en Google Drive
    const String url = "https://drive.google.com/uc?export=download&id=1GboxWN9SPXhK_lHmUMUQKf6d9as2qWLj";

    // Realizar la solicitud HTTP para obtener el archivo
    final response = await http.get(Uri.parse(url));
    
    // Verificar si la respuesta fue exitosa
    if (response.statusCode == 200) {
      // Obtener el directorio de documentos de la aplicación
      final directory = await getApplicationDocumentsDirectory();
      
      // Crear el archivo en el directorio de la aplicación
      final file = File('${directory.path}/verduras.json');

      // Verificar si el archivo no existe, y si es así, crear uno nuevo
      if (!await file.exists()) {
        // Guardar el archivo descargado en el dispositivo
        return file.writeAsBytes(response.bodyBytes);
      } else {
        print("El archivo verduras.json ya existe en el almacenamiento local.");
        return file;
      }
    } else {
      throw Exception("Error al descargar el archivo desde Google Drive");
    }
  }
}
