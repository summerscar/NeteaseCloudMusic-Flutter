// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/api.dart';
import 'package:provider/provider.dart';
import '../state/state.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:progress_state_button/iconed_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  ButtonState nowStatus = ButtonState.idle;

  _LoginPageState() {
    _usernameController.addListener(() {
      setState(() {
        nowStatus = ButtonState.idle;
      });
    });
    _passwordController.addListener(() {
        setState(() {
          nowStatus = ButtonState.idle;
        });
    });
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    void _setStatus (ButtonState status) {
      setState(() {
        nowStatus = status;
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
      ),
      body: SafeArea(
        child: _MainView(
          usernameController: _usernameController,
          passwordController: _passwordController,
          nowStatus: nowStatus,
          setStatus: _setStatus
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _MainView extends StatelessWidget {
  const _MainView({
    Key key,
    this.usernameController,
    this.passwordController,
    this.nowStatus,
    this.setStatus
  }) : super(key: key);

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final ButtonState nowStatus;
  final Function setStatus;

  void _login(BuildContext context) async {
    setStatus(ButtonState.loading);
    Fluttertoast.showToast(
        msg: "登录中……",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
        webPosition: 'center',
        fontSize: 14.0);
    String url;
    if (usernameController.text.contains('@')) {
      url =
          '/login?email=${usernameController.text.trim()}&password=${passwordController.text.trim()}';
    } else if (usernameController.text.contains(RegExp(r'^1[3-9]\d{9}$'))) {
      url =
          '/login/cellphone?phone=${usernameController.text.trim()}&password=${passwordController.text.trim()}';
    } else {
      setStatus(ButtonState.fail);
      Fluttertoast.showToast(
          msg: "用户名/手机格式有误",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Theme.of(context).primaryColor,
          textColor: Colors.white,
          webPosition: 'center',
          fontSize: 14.0);
      return;
    }

    try {
      Response response = await api().get(url);
      if (response.data['code'] == 200) {
        setStatus(ButtonState.success);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('cookie', response.data['cookie']);
        prefs.setString('token', response.data['token']);
        int uid = response.data['profile']['userId'];
        Response userDetail = await api().get('/user/detail?uid=$uid');
        // print(userDetail);
        Provider.of<StateModel>(context, listen: false)
            .setUserInfo(userDetail.data['profile']);
        EasyLoading.dismiss();
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        setStatus(ButtonState.fail);
        Fluttertoast.showToast(
            msg: response.data['msg'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Theme.of(context).primaryColor,
            textColor: Colors.white,
            webPosition: 'center',
            fontSize: 14.0);
        print(response.data);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = false;
    List<Widget> listViewChildren;

    if (isDesktop) {
      final desktopMaxWidth = 400.0 + 100.0 * (1 - 1);
      listViewChildren = [
        _UsernameInput(
          maxWidth: desktopMaxWidth,
          usernameController: usernameController,
        ),
        const SizedBox(height: 12),
        _PasswordInput(
          maxWidth: desktopMaxWidth,
          passwordController: passwordController,
        ),
        _LoginButton(
          maxWidth: desktopMaxWidth,
          onTap: () {
            _login(context);
          },
          nowStatus: nowStatus
        ),
      ];
    } else {
      listViewChildren = [
        _UsernameInput(
          usernameController: usernameController,
        ),
        const SizedBox(height: 12),
        _PasswordInput(
          passwordController: passwordController,
        ),
        _LoginButton(
          onTap: () {
            _login(context);
          },
          nowStatus: nowStatus
        ),
      ];
    }

    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: isDesktop ? Alignment.center : Alignment.topCenter,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: listViewChildren,
            ),
          ),
        ),
      ],
    );
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput({
    Key key,
    this.maxWidth,
    this.usernameController,
  }) : super(key: key);

  final double maxWidth;
  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: TextField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: '用户名/手机',
          ),
        ),
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({
    Key key,
    this.maxWidth,
    this.passwordController,
  }) : super(key: key);

  final double maxWidth;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: '密码',
          ),
          obscureText: true,
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    Key key,
    @required this.onTap,
    this.maxWidth,
    this.nowStatus
  }) : super(key: key);

  final double maxWidth;
  final VoidCallback onTap;
  final ButtonState nowStatus;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FilledButton(
              text: 'login',
              onTap: onTap,
              status: nowStatus
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {

  _FilledButton({@required this.text, @required this.onTap, this.status});

  final String text;
  final VoidCallback onTap;
  final ButtonState status;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ProgressButton.icon(iconedButtons: {
        ButtonState.idle:
          IconedButton(
              text: "登录",
              icon: Icon(Icons.send, color: Colors.white),
              color: Theme.of(context).primaryColor),
        ButtonState.loading:
          IconedButton(
              text: "Loading",
              color: Colors.deepPurple.shade700),
        ButtonState.fail:
          IconedButton(
              text: "Failed",
              icon: Icon(Icons.cancel,color: Colors.white),
              color: Colors.red.shade300),
        ButtonState.success:
          IconedButton(
              text: "Success",
              icon: Icon(Icons.check_circle,color: Colors.white,),
              color: Colors.green.shade400)
      },
      onPressed: onTap,
      state: this.status ?? ButtonState.idle),
    );
  }
}
