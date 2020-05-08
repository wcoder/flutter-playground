import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {

  final void Function(
    String email,
    String password,
    String username,
    bool isLogin,
    BuildContext ctx)
    submitForm;

  final bool isLoading;

  const AuthForm(this.submitForm, this.isLoading);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  String _email = "";
  String _username = "";
  String _password = "";

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();

    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();

      widget.submitForm(
        _email.trim(),
        _username.trim(),
        _password.trim(),
        _isLogin,
        context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    key: ValueKey("email"),
                    validator: (value) {
                      if (value.isEmpty || !value.contains("@")) {
                        return "Please enter a valid email address.";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email address",
                    ),
                    onSaved: (value) {
                      _email = value;
                    },
                  ),
                  _isLogin
                    ? Container()
                    : TextFormField(
                      key: ValueKey("username"),
                      validator: (value) {
                        if (value.isEmpty || value.length < 4) {
                          return "Please enter at least 4 characters.";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Username",
                      ),
                      onSaved: (value) {
                        _username = value;
                      },
                    ),
                  TextFormField(
                    key: ValueKey("password"),
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return "Password must be at least 7 characters long.";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Password",
                    ),
                    obscureText: true,
                    onSaved: (value) {
                      _password = value;
                    },
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  widget.isLoading
                    ? CircularProgressIndicator()
                    : RaisedButton(
                      child: Text(_isLogin ? "Login" : "Singup"),
                      onPressed: _trySubmit,
                    ),
                  widget.isLoading
                    ? Container()
                    :FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      child: Text(_isLogin ? "Create new account" : "I already have an account"),
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}