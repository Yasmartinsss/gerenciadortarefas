import 'package:flutter/material.dart';
import 'task.dart';
import 'database/db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Tarefas',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _tituloController = TextEditingController();
  final _responsavelController = TextEditingController();
  DateTime? _dataSelecionada;

  List<Task> _tarefas = [];
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    final tarefas = await dbHelper.listarTarefas();
    setState(() {
      _tarefas = tarefas;
    });
  }

  Future<void> _adicionarTarefa() async {
    final titulo = _tituloController.text.trim();
    final responsavel = _responsavelController.text.trim();
    if (titulo.isNotEmpty && responsavel.isNotEmpty && _dataSelecionada != null) {
      final novaTarefa = Task(
        titulo: titulo,
        responsavel: responsavel,
        dataLimite: _dataSelecionada!,
      );
      await dbHelper.inserirTarefa(novaTarefa);
      _tituloController.clear();
      _responsavelController.clear();
      _dataSelecionada = null;
      await _carregarTarefas();
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciador de Tarefas'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(labelText: 'Título da Tarefa'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _responsavelController,
              decoration: InputDecoration(labelText: 'Responsável'),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dataSelecionada == null
                        ? 'Nenhuma data selecionada'
                        : 'Prazo: ${_formatarData(_dataSelecionada!)}',
                  ),
                ),
                TextButton(
                  onPressed: () => _selecionarData(context),
                  child: Text('Selecionar Data'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _adicionarTarefa,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              child: Text('Adicionar'),
            ),
            Divider(height: 30),
            Expanded(
              child: _tarefas.isEmpty
                  ? Center(child: Text('Nenhuma tarefa adicionada'))
                  : ListView.builder(
                      itemCount: _tarefas.length,
                      itemBuilder: (context, index) {
                        final t = _tarefas[index];
                        return ListTile(
                          title: Text(t.titulo),
                          subtitle: Text(
                              'Responsável: ${t.responsavel}\nPrazo: ${_formatarData(t.dataLimite)}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
