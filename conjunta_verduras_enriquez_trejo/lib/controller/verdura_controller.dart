import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../model/verdura_model.dart';
import '../utils/google_drive_utils.dart';
class VerduraController with ChangeNotifier {
  List<Verdura> _verduras = [];
  List<Verdura> get verduras => _verduras;

  late File _localFile;

  // Cargar verduras desde el archivo local o descargarlo desde Google Drive si no existe
  Future<void> loadFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _localFile = File('${directory.path}/verduras.json');

      // Si el archivo no existe, descargarlo desde Google Drive
      if (!await _localFile.exists()) {
        print("Archivo no encontrado, descargando...");
        await GoogleDriveUtils.downloadFile();
      }

      // Ahora leer el archivo (ya sea descargado o existente)
      final contents = await _localFile.readAsString();
      final List<dynamic> data = jsonDecode(contents);
      _verduras = data.map((e) => Verdura.fromJson(e)).toList();
      print("Datos cargados: $_verduras");  // Agregar esto para verificar
    } catch (e) {
      print("Error loading file: $e");
      _verduras = []; // Estado inicial vacío si hay error
    }
    notifyListeners();
  }

  // Guardar las verduras en el archivo local
  Future<void> saveToFile() async {
    try {
      final String data = jsonEncode(_verduras.map((e) => e.toJson()).toList());
      await _localFile.writeAsString(data);
    } catch (e) {
      print("Error saving file: $e");
    }
  }

  // Agregar una nueva verdura
  void addVerdura(Verdura verdura) {
    _verduras.add(verdura);
    saveToFile();
    notifyListeners();
  }

  // Actualizar una verdura existente
  void updateVerdura(int codigo, String descripcion, double precio) {
    final index = _verduras.indexWhere((v) => v.codigo == codigo);
    if (index != -1) {
      _verduras[index].descripcion = descripcion;
      _verduras[index].precio = precio;
      saveToFile();
      notifyListeners();
    }
  }

  // Eliminar una verdura
  void deleteVerdura(int codigo) {
    _verduras.removeWhere((v) => v.codigo == codigo);
    saveToFile();
    notifyListeners();
  }

  // Buscar una verdura por código
  Verdura? searchVerdura(int codigo) {
    try {
      return _verduras.firstWhere((v) => v.codigo == codigo);
    } catch (e) {
      // Si no se encuentra la verdura, devuelve null
      return null;
    }
  }
}
