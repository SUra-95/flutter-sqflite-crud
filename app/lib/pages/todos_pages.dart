import 'package:app/database/todo_db.dart';
import 'package:app/model/todo.dart';
import 'package:app/widget/create_todo_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  Future<List<Todo>>? futureTodos;
  final todoDB = TodoDB();

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  void fetchTodos() {
    setState(() {
      futureTodos = todoDB.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Todo List"),
        ),
        body: FutureBuilder<List<Todo>>(
          future: futureTodos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              final todos = snapshot.data!;

              return todos.isEmpty
                  ? Center(
                      child: Text(
                        'No Todos...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    )
                  : ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        final subtitle = DateFormat('yyyy/MM/dd').format(
                            DateTime.parse(todo.updatedAt ?? todo.createdAt));
                        return ListTile(
                          title: Text(
                            todo.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(subtitle),
                          trailing: IconButton(
                            onPressed: () async {
                              await todoDB.delete(todo.id);
                              fetchTodos();
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                          onTap: () {
                            showDialog(
                              context: context, 
                              builder: (context) => CreateTodoWidget(
                                todo: todo,
                                onSubmit: (title) async {
                                  await todoDB.update(id: todo.id, title: title);
                                  fetchTodos();
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                              }),
                            );
                          },
                        );
                      },
                    );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => CreateTodoWidget(
                      onSubmit: (title) async {
                        await todoDB.create(title: title);
                        if (!mounted) return;
                        fetchTodos();
                        Navigator.of(context).pop();
                      },
                    ));
          },
        ),
      );
}
