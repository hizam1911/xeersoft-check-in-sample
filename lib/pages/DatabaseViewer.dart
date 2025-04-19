import 'package:flutter/material.dart';

import '../helpers/SqfliteDbHelper.dart';

class DatabaseViewer extends StatefulWidget {
  const DatabaseViewer({Key? key}) : super(key: key);

  @override
  State<DatabaseViewer> createState() => _DatabaseViewerState();
}

class _DatabaseViewerState extends State<DatabaseViewer> {
  late final dbService;
  bool _isLoading = true;
  Map<String, List<Map<String, dynamic>>> _tablesData = {};
  Map<String, List<String>> _tablesColumns = {};
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    dbService = SqfliteDbHelper(); // Ensure it's initialized immediately
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await dbService.database; // Await database initialization
      _loadDatabaseData();
    });
  }

  Future<void> _loadDatabaseData() async {
    try {
      setState(() => _isLoading = true);

      // Fetch all table names
      final tableNames = await dbService.getTableNames();

      // Fetch data and columns for each table
      for (String tableName in tableNames) {
        final tableData = await dbService.getTableData(tableName);
        final tableColumns = await dbService.getTableColumns(tableName);
        setState(() {
          _tablesData[tableName] = tableData;
          _tablesColumns[tableName] = tableColumns;
        });
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDatabaseData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_tablesData.isEmpty) {
      return const Center(child: Text('No tables found in the database.'));
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: _tablesData.entries.map((entry) {
        final tableName = entry.key;
        final tableData = entry.value;
        final columns = _tablesColumns[tableName] ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ExpansionTile(
            title: Text(tableName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${tableData.length} rows, ${columns.length} columns'),
            children: [
              // Columns Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Columns:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: columns
                            .map((col) => Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Chip(label: Text(col)),
                        ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Rows Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rows:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...tableData.map((row) => ListTile(
                      title: Text(row.toString(), style: const TextStyle(fontSize: 12)),
                    )),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}