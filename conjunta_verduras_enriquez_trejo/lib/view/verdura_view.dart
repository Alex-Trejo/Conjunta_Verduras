import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/verdura_controller.dart';
import '../model/verdura_model.dart';

class VerduraView extends StatefulWidget {
  @override
  _VerduraViewState createState() => _VerduraViewState();
}

class _VerduraViewState extends State<VerduraView> {
  bool _isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    // Cargar las verduras desde el archivo al iniciar la vista
    _loadData();
  }

  Future<void> _loadData() async {
    await Provider.of<VerduraController>(context, listen: false).loadFromFile();
    setState(() {
      _isLoading = false; // Cuando los datos se hayan cargado, desactivamos el indicador de carga
    });
  }

  @override
  Widget build(BuildContext context) {
    final verduraController = Provider.of<VerduraController>(context);

    return MaterialApp(
      theme: ThemeData(
  primarySwatch: Colors.lightBlue,
  scaffoldBackgroundColor: Color(0xFFE3F2FD),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF81D4FA),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF29B6F6),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(fontSize: 16, color: Colors.black87), // Reemplazamos bodyText2 por bodyMedium
  ),
),

      home: Scaffold(
        appBar: AppBar(
          title: Text("Gestión de Verduras"),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : verduraController.verduras.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.no_food, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "No hay verduras disponibles",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: verduraController.verduras.length,
                    itemBuilder: (context, index) {
                      final verdura = verduraController.verduras[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        color: Color(0xFFB3E5FC),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFF81D4FA),
                            child: Icon(
                              Icons.local_florist,
                              color: Colors.white,
                            ),
                          ),
                          title: Text("${verdura.descripcion}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text("Precio: \$${verdura.precio}",
                              style: TextStyle(color: Colors.black54)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _showEditDialog(context, verdura);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  verduraController
                                      .deleteVerdura(verdura.codigo);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white),
          onPressed: () {
            _showAddDialog(context);
          },
        ),
      ),
    );
  }

  // Mostrar el cuadro de diálogo para agregar una nueva verdura
  void _showAddDialog(BuildContext context) {
    final codigoController = TextEditingController();
    final descripcionController = TextEditingController();
    final precioController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFFE1F5FE),
        title: Text("Agregar Verdura", style: TextStyle(color: Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codigoController,
              decoration: InputDecoration(labelText: "Código"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descripcionController,
              decoration: InputDecoration(labelText: "Descripción"),
            ),
            TextField(
              controller: precioController,
              decoration: InputDecoration(labelText: "Precio"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              final codigo = int.tryParse(codigoController.text) ?? 0;
              final descripcion = descripcionController.text;
              final precio = double.tryParse(precioController.text) ?? 0.0;

              // Validaciones
              if (codigo <= 0 || descripcion.isEmpty || precio <= 0) {
                _showErrorDialog(ctx, "Todos los campos son requeridos.");
              } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(descripcion)) {
                _showErrorDialog(
                    ctx, "La descripción solo debe contener letras.");
              } else {
                Provider.of<VerduraController>(context, listen: false)
                    .addVerdura(Verdura(
                  codigo: codigo,
                  descripcion: descripcion,
                  precio: precio,
                ));
                Navigator.of(ctx).pop();
              }
            },
            child: Text("Agregar", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // Mostrar el cuadro de diálogo para editar una verdura
  void _showEditDialog(BuildContext context, Verdura verdura) {
    final descripcionController =
        TextEditingController(text: verdura.descripcion);
    final precioController =
        TextEditingController(text: verdura.precio.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFFE1F5FE),
        title: Text("Editar Verdura", style: TextStyle(color: Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descripcionController,
              decoration: InputDecoration(labelText: "Descripción"),
            ),
            TextField(
              controller: precioController,
              decoration: InputDecoration(labelText: "Precio"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              final descripcion = descripcionController.text;
              final precio = double.tryParse(precioController.text) ?? 0.0;

              // Validaciones
              if (descripcion.isEmpty || precio <= 0) {
                _showErrorDialog(ctx, "Todos los campos son requeridos.");
              } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(descripcion)) {
                _showErrorDialog(
                    ctx, "La descripción solo debe contener letras.");
              } else {
                Provider.of<VerduraController>(context, listen: false)
                    .updateVerdura(verdura.codigo, descripcion, precio);
                Navigator.of(ctx).pop();
              }
            },
            child: Text("Actualizar", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // Función para mostrar el mensaje de error
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFFE1F5FE),
        title: Text("Error", style: TextStyle(color: Colors.red)),
        content: Text(message, style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text("Aceptar"),
          ),
        ],
      ),
    );
  }
}
