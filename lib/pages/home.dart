import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplydo/constants/colors.dart';
import 'package:simplydo/model/todo.dart';
import 'package:simplydo/widgets/todo_iterm.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ToDo> _foundTodo = [];
  final _todoController = TextEditingController();
  late List<ToDo> _todos = [];
  late bool _isFirstLaunch;

  @override
  void initState() {
    super.initState();
    _isFirstLaunch = true;
    _loadFirstLaunchFlag();
    _loadToDoList();
  }

  Future<void> _loadFirstLaunchFlag() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  }

  Future<void> _loadToDoList() async {
    final prefs = await SharedPreferences.getInstance();
    final todos = prefs.getStringList('todos') ?? [];

    setState(() {
      _todos = todos.map((todoJson) => ToDo.fromJson(todoJson)).toList();
      _foundTodo = _todos;
      _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      if (_isFirstLaunch) {
        _addToDoItem("Start Typing your first task");
        _isFirstLaunch = false;
        prefs.setBool('isFirstLaunch', _isFirstLaunch);
      }
    });
  }

  Future<void> _saveToDoList() async {
  final prefs = await SharedPreferences.getInstance();
  final todosJson = _todos.map((todo) => todo.toJson()).toList();
  prefs.setStringList('todos', todosJson.map((json) => jsonEncode(json)).toList());
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: tbBGColor,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  SearchBar(),
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 50, bottom: 20),
                          child: Text(
                            'My ToDos:',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        for (ToDo todo in _foundTodo.reversed)
                          ToDoItem(
                            todo: todo,
                            onToDoChange: _handleToDoChange,
                            onDeleteItem: _deleteToDoItem,
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20, right: 20, left: 20),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 0.0),
                                blurRadius: 10.0,
                                spreadRadius: 0.0)
                          ],
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        controller: _todoController,
                        decoration: InputDecoration(
                            hintText: 'Add a new task...',
                            border: InputBorder.none),
                            onSubmitted: (String value) {
                              _addToDoItem(value);
                            },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20, right: 20),
                    child: ElevatedButton(
                      child: Text(
                        '+',
                        style: TextStyle(fontSize: 40),
                      ),
                      onPressed: () {
                        _addToDoItem(_todoController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tbBlue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(60, 60),
                        elevation: 10,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Container SearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
        onChanged:(value) => _runFilter(value),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(0),
            prefixIcon: Icon(
              Icons.search,
              color: tbBlack,
              size: 20,
            ),
            prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
            border: InputBorder.none,
            hintText: 'Search',
            hintStyle: TextStyle(color: tbGrey)),
      ),
    );
  }

  void _addToDoItem(String toDo) {
    setState(() {
      if (!toDo.isEmpty){
        final newTodo = ToDo(
        id: DateTime.now().millisecond.toString(),
        todoText: toDo,
        createTime: DateTime.now()
        );
        print(newTodo);
        _todos.add(newTodo);
        FocusScope.of(context).unfocus();
        _todoController.clear();
        _saveToDoList(); // Save the updated list
      }
    });
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
      _saveToDoList(); // Save the updated list
    });
  }

  void _deleteToDoItem(String id) {
    setState(() {
      _todos.removeWhere((item) => item.id == id);
      _saveToDoList(); // Save the updated list
    });
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = _todos;
    } else {
      results = _foundTodo.where((item) =>
          item.todoText!.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
    }

    setState(() {
      _foundTodo = results;
    });
  }
  

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tbBGColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.menu,
            color: tbBlack,
            size: 30,
          ),
          Text('SimplyDo',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
          ),
          Container(
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/logo.jpeg'),
            ),
          )
        ],
      ),
    );
  }
}
