import 'dart:convert';
import 'dart:js_interop';

import 'package:crud_app/models/config.dart';
import 'package:crud_app/models/users.dart';
import 'package:crud_app/sidemenu.dart';
import 'package:crud_app/userinfo.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User CRUD',
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/login': (context) => const Login()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  static const routeName = '/';
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget mainBody = Container();
  @override
  void initState() {
    super.initState();
    Users user = Configure.login;
    if (user.id != null) {
      getUsers();
    }
  }

  List<Users> _userList = [];
  Future<void> getUsers() async {
    var url = Uri.http(Configure.server, 'users');
    var resp = await http.get(url);
    setState(() {
      _userList = usersFromJson(resp.body);
      mainBody = showUsers();
    });
    return;
  }

  Future<void> removeUsers(user) async {
    var url = Uri.http(Configure.server, 'users/${user.id}');
    var resp = await http.delete(url);
    print(resp.body);
    return;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: SideMenu(),
      body: mainBody,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String result = await Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserForm()));
          if (result == 'refresh') {
            getUsers();
          }
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }

  Widget showUsers() {
    return ListView.builder(
      itemCount: _userList.length,
      itemBuilder: (context, index) {
        Users user = _userList[index];
        return Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          child: Card(
            child: ListTile(
              title: Text("${user.fullname}"),
              subtitle: Text("${user.email}"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserInfo(),
                        settings: RouteSettings(arguments: user)));
              },
              trailing: IconButton(
                onPressed: () async {
                  String result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserForm(),
                          settings: RouteSettings(arguments: user)));
                  if (result == 'refresh') {
                    getUsers();
                  }
                },
                icon: Icon(Icons.edit),
              ),
            ),
          ),
          onDismissed: (direction) {
            removeUsers(user);
          },
          background: Container(
            color: Colors.red,
            margin: EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class Login extends StatefulWidget {
  static const routeName = "/login";

  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formkey = GlobalKey<FormState>();
  Users user = Users();

  Future<void> login(Users user) async {
    var params = {"email": "aekik25@gmail.com", "password": "4321zszs"};

    var url = Uri.http(Configure.server, 'users', params);
    var resp = await http.get(url);
    print(resp.body);
    List<Users> login_result = usersFromJson(resp.body);
    print(login_result.length);
    if (login_result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("username or password invalid")));
    } else {
      Configure.login = login_result[0];
      Navigator.pushNamed(context, Home.routeName);
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          margin: EdgeInsets.all(10.0),
          child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextHeader(),
                  emailInputField(),
                  passwordInputField(),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      submitButtom(),
                      SizedBox(width: 10.0),
                      backButton(),
                      SizedBox(width: 10.0),
                      registerLink()
                    ],
                  )
                ],
              )),
        ),
        drawer: SideMenu());
  }

  Widget TextHeader() {
    return Column(
      children: [
        Center(
          child: Text(
            "Login",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget emailInputField() {
    return TextFormField(
        decoration:
            InputDecoration(labelText: "Email", icon: Icon(Icons.email)),
        validator: (value) {
          if (value!.isEmpty) {
            return 'this field is required';
          }
          if (!EmailValidator.validate(value)) {
            return 'It is not email format';
          }
          return null;
        },
        onSaved: (newValue) => user.email = newValue);
  }

  Widget passwordInputField() {
    return TextFormField(
        obscureText: true,
        decoration:
            InputDecoration(labelText: "Password", icon: Icon(Icons.lock)),
        validator: (value) {
          if (value!.isEmpty) {
            return 'this field is required';
          }
          return null;
        },
        onSaved: (newValue) => user.password = newValue);
  }

  Widget submitButtom() {
    return ElevatedButton(
      onPressed: () {
        if (_formkey.currentState!.validate()) {
          _formkey.currentState!.save();
          print(user.toJson().toString());
          login(user);
        }
      },
      child: Text("Login"),
    );
  }

  Widget backButton() {
    return ElevatedButton(
      onPressed: () {},
      child: Text('Back'),
    );
  }

  Widget registerLink() {
    return InkWell(
      child: const Text('Sign Up'),
      onTap: () {},
    );
  }
}

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formkey = GlobalKey<FormState>();
  late Users user;

  Future<void> addNewUser(user) async {
    var url = Uri.http(Configure.server, "users");
    var resp = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()));
    var rs = usersFromJson('[${resp.body}]');
    if (rs.length == 1) {
      Navigator.pop(context, 'refresh');
    }
  }

  Future<void> updateDate(user) async {
    var url = Uri.http(Configure.server, "users/${user.id}");
    var resp = await http.put(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()));
    var rs = usersFromJson('[${resp.body}]');
    if (rs.length == 1) {
      Navigator.pop(context, 'refresh');
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      user = ModalRoute.of(context)!.settings.arguments as Users;
      print(user.fullname);
    } catch (e) {
      user = Users();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Form'),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fnameInputField(),
              emailInputField(),
              passInputField(),
              genderFormInput(),
              SizedBox(
                height: 10,
              ),
              submitButtom(),
            ],
          ),
        ),
      ),
    );
  }

  Widget fnameInputField() {
    return TextFormField(
      initialValue: user.fullname,
      decoration:
          InputDecoration(labelText: "FullName", icon: Icon(Icons.person)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.fullname = newValue,
    );
  }

  Widget emailInputField() {
    return TextFormField(
      initialValue: user.email,
      decoration: InputDecoration(labelText: "Email", icon: Icon(Icons.email)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.email = newValue,
    );
  }

  Widget passInputField() {
    return TextFormField(
      initialValue: user.password,
      decoration:
          InputDecoration(labelText: "Password", icon: Icon(Icons.lock)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.password = newValue,
    );
  }

  Widget genderFormInput() {
    var initGen = 'None';
    try {
      if (!user.gender!.isNull) {
        initGen = user.gender!;
      }
    } catch (e) {
      initGen = 'None';
    }
    return DropdownButtonFormField(
        value: initGen,
        decoration: InputDecoration(labelText: "Gender", icon: Icon(Icons.man)),
        items: Configure.gender.map((String val) {
          return DropdownMenuItem(
            value: val,
            child: Text(val),
          );
        }).toList(),
        onChanged: (value) {
          user.gender = value;
        },
        onSaved: (newValue) => user.gender);
  }

  Widget submitButtom() {
    return ElevatedButton(
      onPressed: () {
        if (_formkey.currentState!.validate()) {
          _formkey.currentState!.save();
          print(user.toJson().toString());
          addNewUser(user);
          if (user.id == null) {
            addNewUser(user);
          } else {
            updateDate(user);
          }
        }
      },
      child: Text("Save"),
    );
  }
}
