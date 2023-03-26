import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({
    super.key,
    this.todo
  });
  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController title = TextEditingController();
  TextEditingController desciption = TextEditingController();
  bool isEdit = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo = widget.todo;
    if(todo != null){
      isEdit = true;
      final titleEdit = todo['title'];
      final descriptionEdit = todo['description'];
      title.text = titleEdit;
      desciption.text = descriptionEdit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
         isEdit ? "Edit Todo" :"Add Todo"
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: title,
            decoration: InputDecoration(
              hintText: 'Title Todo'
            ),

          ),
          TextField(
            controller: desciption,
            decoration: InputDecoration(
                hintText: 'Description Todo'
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed:isEdit? updateData :submitData,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                    isEdit ? "Update" :"Submit"
                ),
              ),
          ),
        ],
      ),
    );
  }

  Future<void> submitData() async {
    final titledata = title.text;
    final descriptiondata = desciption.text;
    final url = 'http://127.0.0.1:8001/api/v1/todo/message';
    final uri = Uri.parse(url);
    final body = {
      "title": titledata,
      "description":descriptiondata
    };
    final response = await http.post(
        uri,
        body: jsonEncode(body),
        headers: {'Content-Type':'application/json'},
    );
    if (response.statusCode == 201){
      title.text = '';
      desciption.text = '';
      showSuccessMessage('Berhasil membuat todo!');
    }else{
      showErrorMessage('Gagal membuat todo!');
    }
  }

  Future<void> updateData() async {
    final titledata = title.text;
    final descriptiondata = desciption.text;
    final todo = widget.todo;
    if(todo == null){
      print('errr');
      return;
    }
    final id = todo['id'];
    final url = 'http://localhost:8001/api/v1/todo/message/$id';
    final uri = Uri.parse(url);
    final body = {
      "title": titledata,
      "description":descriptiondata
    };
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type':'application/json'},
    );
    if (response.statusCode == 200){
      showSuccessMessage('Berhasil update todo!');
    }else{
      print(response.body);
      showErrorMessage('Gagal update todo!');
    }
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
