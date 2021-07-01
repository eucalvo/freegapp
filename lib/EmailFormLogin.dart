import 'package:flutter/material.dart';

class EmailFormLogin extends StatefulWidget {
  const EmailFormLogin({required this.callback});
  final void Function(String email) callback;
  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailFormLogin> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<_EmailFormState>.
  final _formKey = GlobalKey<FormState>(debugLabel: '_EmailFormState');
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter your email address to continue';
                  }
                  return null;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 30),
                  child: ElevatedButton(
                    onPressed: () async {
                      // The FormState class contains the validate() method.
                      // When the validate() method is called, it runs the validator() function
                      // for each text field in the form. If everything looks good,
                      // the validate() method returns true. If any text field contains errors,
                      // the validate() method rebuilds the form to display any error messages and returns false.
                      // add ! to assert that it isn’t null (and to throw an exception if it is).
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid,
                        widget.callback(_controller
                            .text); // call to parent with current string the user is editing
                      }
                    },
                    child: const Text('NEXT'),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    ]);
  }
}
