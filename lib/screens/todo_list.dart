import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gonotes_mobile/screens/add_page.dart';
import 'package:http/http.dart' as http;
class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List listTodo = [];
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    getTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo List"),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage, label: Text("Add Todo")
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(
          child: CircularProgressIndicator(

          ),
        ),
        replacement: RefreshIndicator(
          onRefresh: getTodoList,
          child: ListView.builder(
              itemCount: listTodo.length,
              itemBuilder: (context, index) {
                final listTodos = listTodo[index] as Map;
                final idTodo = listTodos['id'] as String;
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(listTodos['title']),
                  subtitle: Text(listTodos['description']),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                            navigateToEditPage(listTodos);
                      } else if (value == 'delete') {
                        deleteTodoById(idTodo);
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(child: Text('Edit'), value: 'edit',),
                        PopupMenuItem(child: Text('Delete'), value: 'delete',)
                      ];
                    },
                  ),
                );
              }),
        ),
      ),
    );
  }

  Future<void> deleteTodoById(String idTodo) async {
    final url = 'http://localhost:8001/api/v1/todo/message/$idTodo';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200){
      final filtered = listTodo.where((element) => element['id'] != idTodo).toList();
      setState(() {
        listTodo = filtered;
      });
      showSuccessMessage('Berhasil hapus todo!');
    }else{
      showErrorMessage('Gagal  hapus todo!');
    }
  }

  Future<void> navigateToEditPage(Map listTodos) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo:listTodos),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    getTodoList();
  }


  Future<void> navigateToAddPage() async {
      final route = MaterialPageRoute(
        builder: (context) => AddTodoPage(),
      );
      await Navigator.push(context, route);
      setState(() {
        isLoading = true;
      });
      getTodoList();
  }

  Future<void> getTodoList() async{
    setState(() {
      isLoading = true;
    });
    final url = 'http://localhost:8001/api/v1/todo/?page=1&size=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200){
      final resultJson = jsonDecode(response.body) as Map;
      final resultTodo = resultJson['data'];
      final datas = resultTodo['items'] as List;
      setState(() {
        listTodo = datas;
      });
    }else{

    }
    setState(() {
      isLoading = false;
    });
  }

  void showSuccessMessage(String message){
    final snackBar = SnackBar(content: Text(message), backgroundColor: Colors.lightGreenAccent,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  void showErrorMessage(String message){
    final snackBar = SnackBar(content: Text(message, style: TextStyle(color: Colors.white),), backgroundColor: Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}
