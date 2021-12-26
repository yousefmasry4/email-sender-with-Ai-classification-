import 'dart:convert';

import 'package:email_tutorial/components/text_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The best bigdata project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FeedBackPage(title: 'The best bigdata project'),
    );
  }
}

class FeedBackPage extends StatefulWidget {
  FeedBackPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _FeedBackPageState createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  final _formKey = GlobalKey<FormState>();
  bool _enableBtn = false;
  int api =-1;

  TextEditingController emailController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController apiController = TextEditingController();


  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    apiController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Form(
        key: _formKey,
        onChanged: (() {
          setState(() {
            _enableBtn = _formKey.currentState!.validate();
          });
        }),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFields(
                  controller: apiController,
                  name: "api url",
                  validator: ((value) {
                    if (value!.isEmpty) {
                      return 'you need to set api';
                      return null;
                    }
                    return null;
                  }
                    )
                    ),
              TextFields(
                  controller: subjectController,
                  name: "Subject",
                  validator: ((value) {
                    if (value!.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  })),
              TextFields(
                  controller: emailController,
                  name: "Email",
                  validator: ((value) {
                    if (value!.isEmpty) {
                      return 'Email is required';
                    } else if (!value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  })),
              TextFields(
                  controller: messageController,
                  f: (s) async {
                    if(apiController.text.isNotEmpty){
                        print("callllll");
                        http.Response res=await http.post(
                        Uri.parse('${apiController.text}/api/str'),
                        headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(<String, String>{
                        'txt': s,
                        }),
                        );
                        if(res.statusCode == 200)
                        if(jsonDecode(res.body)["classification"] == "1"){
                          setState(() {
                            api=1;
                          });
                        }else{
                          setState(() {
                            api=0;
                          });
                        }
                    }

                  },
                  name: "Message",
                  validator: ((value) {
                    WidgetsBinding.instance!.addPostFrameCallback((_){
                      if (value!.isNotEmpty) {

                        setState(() {
                          _enableBtn = true;
                          // api=-1;
                        });

                        // return 'Message is required';
                      }else{
                        setState(() {
                          api=-1;
                        });
                      }
                      return null;

                      // Add Your Code here.

                    }
                    );
                    }),
                  maxLines: null,
                  type: TextInputType.multiline),
              Padding(
                  padding: EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed))
                              return Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5);
                            else if (states.contains(MaterialState.disabled))
                              return Colors.grey;
                            return Colors.blue; // Use the component's default.
                          },
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ))),
                    onPressed: _enableBtn
                        ? (() async {
                            final Email email = Email(
                              body: messageController.text,
                              subject: subjectController.text,
                              recipients: [emailController.text],
                              isHTML: false,
                            );

                            await FlutterEmailSender.send(email);
                          })
                        : null,
                    child: Text('Submit'),
                  )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: api!=-1?Container(
        height: 50,
        color: api == 1?Colors.green:Colors.redAccent,
      ):SizedBox()
    );
  }
}
