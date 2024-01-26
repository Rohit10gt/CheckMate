import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController _textEditingController = TextEditingController();

  Box? _todosBox;

  @override
  void initState() {
    super.initState();
    Hive.openBox("todo_box").then((_box){
      setState(() {
        _todosBox = _box;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CheckMate",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
          onPressed: (){_displayTextInputDialog(context);},
        child: Icon(Icons.add),),
    );
  }
  Widget _buildUI(){
    if(_todosBox==null){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return ValueListenableBuilder(
        valueListenable: _todosBox!.listenable(),
        builder: (context,box,widget){
          final todosKeys = box.keys.toList();
          return SizedBox.expand(
            child: ListView.builder(
              itemCount: todosKeys.length,
                itemBuilder: (context,index){
                  Map todo = _todosBox!.get(
                    todosKeys[index],
                  );
                return ListTile(
                  title: Text(todo["content"]),
                  trailing: Checkbox(
                    value: todo["isDone"],
                    onChanged: (value) async {
                      todo["isDone"] = value;
                      await _todosBox!.put(todosKeys[index], todo);
                    },
                  ),
                  subtitle: Text(
                    todo["time"],
                  ),
                  onLongPress: () async {
                    await _todosBox!.delete(
                      todosKeys[index],
                    );
                  },
                );
                }
            ),
          );
        }
        );
  }
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add a todo'),
            content: TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(hintText: "Todo...."),
            ),
            actions: [
              MaterialButton(
                color: Colors.redAccent,
                textColor: Colors.white,
                child: const Text('Ok'),
                onPressed: () {
                  _todosBox?.add({
                    "content": _textEditingController.text,
                    "time": DateTime.now().toIso8601String(),
                    "isDone": false,
                  });
                  Navigator.pop(context);
                  _textEditingController.clear();
                },
              ),
            ],
          );
        });
  }
}
