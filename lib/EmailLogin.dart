import 'package:flutter/material.dart';
import 'src/LogInError.dart';

class EmailLogin extends StatelessWidget {
  EmailLogin({
    Key? key,
    required this.email,
    required this.verifyEmail,
  }) : super(key: key); // Initializes key for subclasses.
  final String? email;
  final void Function(
    //  typedef myFunction = final void Function(String email, void Function(Exception e) error,);
    String email,
    void Function(Exception e) error,
  ) verifyEmail; //  myFunction verifyEmail() = {}

  @override
  Widget build(BuildContext context) {
    return EmailForm(
        callback: (email) => verifyEmail(email,
            (e) => LogInError().showErrorDialog(context, 'Invalid email', e)));
  }
}

class EmailForm extends StatefulWidget {
  const EmailForm({required this.callback});
  final void Function(String email) callback;
  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
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
