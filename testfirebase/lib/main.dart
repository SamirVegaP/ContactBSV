// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ContactBSV',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomeReadUsers(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future createUser(User user) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();
    user.id = docUser.id;

    final json = user.toJson();

    await docUser.set(json);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final dateController = TextEditingController();
    final ageController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Añade un Contacto"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Ingresa tu nombre',
            ),
          ),
          SizedBox(
            height: 24,
          ),
          TextField(
            controller: ageController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Ingresa tu edad',
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(
            height: 24,
          ),
          TextField(
            controller: dateController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Ingrese su Fecha de Nacimiento',
            ),
            keyboardType: TextInputType.none,
            onTap: () async {
              DateTime? pickeddate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );

              if (pickeddate != null) {
                dateController.text =
                    DateFormat('yyyy-MM-dd').format(pickeddate);
              }
            },
          ),
          SizedBox(
            height: 24,
          ),
          TextField(
            controller: phoneController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Ingresa número de celular',
            ),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(
            height: 24,
          ),
          SizedBox(
            height: 24,
          ),
          ElevatedButton(
              onPressed: () {
                if (nameController.text != "" &&
                    ageController.text != "" &&
                    dateController.text != "") {
                  if (num.parse(ageController.text) > 99 ||
                      num.parse(ageController.text) < 0 ||
                      IsDecimal(num.parse(ageController.text))) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verificar ingreso de dato'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    final user = User(
                      name: nameController.text,
                      age: int.parse(ageController.text),
                      birthday: dateController.text,
                      phone: phoneController.text,
                    );
                    String nameuser = nameController.text;
                    createUser(user);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bienvenido ${nameuser}'),
                        backgroundColor: Colors.green,
                        action: SnackBarAction(
                          label: 'Otro Usuario',
                          textColor: Colors.white,
                          onPressed: () {
                            nameController.text = "";
                            ageController.text = "";
                            dateController.text = "";
                          },
                        ),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verifica todos tus items ingresados'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text("Añade"))
        ],
      ),
    );
  }
}

Widget buildUser(User user) => ListTile(
      leading: CircleAvatar(child: Text("${user.age}")),
      title: Text(user.name),
      subtitle: Text(
          "Cumpleaños: ${user.birthday} \n Número de Celular: \n ${user.phone}"),
      trailing: IconButton(
          onPressed: () {
            deleteeUser(user.id);
          },
          icon: Icon(Icons.delete)),
    );

Future deleteeUser(String useid) async {
  final docuser = FirebaseFirestore.instance.collection("users").doc(useid);

  docuser.delete();
  return true;
}

Stream<List<User>>? readUserList() =>
    FirebaseFirestore.instance.collection('users').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());

class HomeReadUsers extends StatefulWidget {
  const HomeReadUsers({super.key});

  @override
  State<HomeReadUsers> createState() => _HomeReadUsersState();
}

class _HomeReadUsersState extends State<HomeReadUsers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todos sus contactos"),
      ),
      body: StreamBuilder(
        stream: readUserList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(
                "Algo anda mal /n Código de consulta: ${snapshot.error}");
          } else if (snapshot.hasData) {
            final users = snapshot.data!;
            return ListView(
              children: users.map(buildUser).toList(),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_reaction),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyHomePage(title: "ContactBSV")));
        },
      ),
    );
  }
}

class User {
  late String id;
  late final String name;
  late final int age;
  late final String birthday;
  late String phone;

  User(
      {this.id = "",
      required this.name,
      required this.age,
      required this.birthday,
      required this.phone});
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "age": age,
        "birthday":
            DateFormat("MMMMd").format(DateTime.parse(birthday)).toString(),
        "phone": phone,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        age: json['age'],
        birthday: json['birthday'],
        phone: json['phone'],
      );
}

bool IsDecimal(valuenumber) {
  if (valuenumber % 1 == 0) {
    return false;
  } else {
    return true;
  }
}
