import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(CallbookApp());

class CallbookApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Callbook POC Indonesia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        colorScheme: ColorScheme.dark(primary: Colors.tealAccent),
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      home: CallbookHome(),
    );
  }
}

class CallbookHome extends StatefulWidget {
  @override
  _CallbookHomeState createState() => _CallbookHomeState();
}

class _CallbookHomeState extends State<CallbookHome> {
  List<Map<String, String>> data = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString('callbook');
    if (raw != null) {
      setState(() {
        data = List<Map<String, String>>.from(json.decode(raw));
      });
    }
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('callbook', json.encode(data));
  }

  void addEntry(String name, String callsign) {
    setState(() {
      data.add({'name': name, 'callsign': callsign});
    });
    saveData();
  }

  void editEntry(int index, String name, String callsign) {
    setState(() {
      data[index] = {'name': name, 'callsign': callsign};
    });
    saveData();
  }

  void deleteEntry(int index) {
    setState(() {
      data.removeAt(index);
    });
    saveData();
  }

  void showForm({int? index}) {
    final nameController = TextEditingController(
        text: index != null ? data[index]['name'] : '');
    final callsignController = TextEditingController(
        text: index != null ? data[index]['callsign'] : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(index == null ? 'Tambah Anggota' : 'Edit Anggota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Nama', labelStyle: TextStyle(color: Colors.white)),
            ),
            TextField(
              controller: callsignController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Callsign', labelStyle: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Simpan'),
            onPressed: () {
              if (index == null) {
                addEntry(nameController.text, callsignController.text);
              } else {
                editEntry(index, nameController.text, callsignController.text);
              }
              Navigator.pop(context);
            },
          ),
          TextButton(child: Text('Batal'), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Callbook POC Indonesia'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Image.asset('assets/logo.png', height: 100),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (ctx, i) {
                final item = data[i];
                return Card(
                  child: ListTile(
                    title: Text(item['name']!, style: TextStyle(color: Colors.white)),
                    subtitle: Text(item['callsign']!, style: TextStyle(color: Colors.tealAccent)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit), onPressed: () => showForm(index: i)),
                        IconButton(icon: Icon(Icons.delete), onPressed: () => deleteEntry(i)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}