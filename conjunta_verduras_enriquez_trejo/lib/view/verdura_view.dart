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

    return Scaffold(
      appBar: AppBar(
        title: Text("Gestión de Verduras"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Muestra un indicador de carga mientras se cargan los datos
          : verduraController.verduras.isEmpty
              ? Center(child: Text("No hay verduras disponibles"))
              : ListView.builder(
                  itemCount: verduraController.verduras.length,
                  itemBuilder: (context, index) {
                    final verdura = verduraController.verduras[index];
                    return ListTile(
                      title: Text("${verdura.descripcion}"),
                      subtitle: Text("Precio: \$${verdura.precio}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditDialog(context, verdura);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              verduraController.deleteVerdura(verdura.codigo);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddDialog(context);
        },
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
        title: Text("Agregar Verdura"),
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
            child: Text("Cancelar"),
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
                _showErrorDialog(ctx, "La descripción solo debe contener letras.");
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
            child: Text("Agregar"),
          ),
        ],
      ),
    );
  }

  // Mostrar el cuadro de diálogo para editar una verdura
  void _showEditDialog(BuildContext context, Verdura verdura) {
    final descripcionController = TextEditingController(text: verdura.descripcion);
    final precioController = TextEditingController(text: verdura.precio.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Editar Verdura"),
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
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              final descripcion = descripcionController.text;
              final precio = double.tryParse(precioController.text) ?? 0.0;

              // Validaciones
              if (descripcion.isEmpty || precio <= 0) {
                _showErrorDialog(ctx, "Todos los campos son requeridos.");
              } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(descripcion)) {
                _showErrorDialog(ctx, "La descripción solo debe contener letras.");
              } else {
                Provider.of<VerduraController>(context, listen: false)
                    .updateVerdura(verdura.codigo, descripcion, precio);
                Navigator.of(ctx).pop();
              }
            },
            child: Text("Actualizar"),
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
        title: Text("Error"),
        content: Text(message),
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
