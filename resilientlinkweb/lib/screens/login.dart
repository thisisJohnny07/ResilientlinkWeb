import 'package:flutter/material.dart';
import 'package:resilientlinkweb/screens/sidenavigation.dart';
import 'package:resilientlinkweb/services/authentication.dart';
import 'package:resilientlinkweb/widgets/button.dart';
import 'package:resilientlinkweb/widgets/snackbar.dart';
import 'package:resilientlinkweb/widgets/text_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool rememberMe = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void loginUser() async {
    String res = await AuntServices().loginUser(
      email: emailController.text,
      password: passwordController.text,
    );
    if (res == "success") {
      setState(() {
        isLoading = true;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SideNavigation(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackbar(context, res);
    }
  }

  void forgotPassword() {
    // Implement forgot password functionality here
    showSnackbar(context, "Forgot password functionality not implemented yet.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: Center(
        child: Container(
          width: 800,
          height: 500,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(2, 4), // Subtle offset for a formal look
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 400,
                height: 500,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6.0),
                      bottomLeft: Radius.circular(6.0)),
                  child: Image.asset(
                    "images/login.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        "images/logo.png",
                        height: 60,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff011222)),
                      ),
                      const Text(
                        "Please login with your personal information",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 160, 160, 160),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "Email *",
                        style: TextStyle(fontSize: 12),
                      ),
                      TextFieldInput(
                          textEditingController: emailController,
                          icon: Icons.email),
                      const Text(
                        "Password *",
                        style: TextStyle(fontSize: 12),
                      ),
                      TextFieldInput(
                        isPass: true,
                        textEditingController: passwordController,
                        icon: Icons.lock,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Transform.scale(
                                scale: 0.8,
                                child: Checkbox(
                                  value: rememberMe,
                                  onChanged: (value) => setState(
                                      () => rememberMe = value ?? false),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3.0),
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1.0,
                                  ),
                                  activeColor: const Color(0xFF015490),
                                  checkColor: Colors.white,
                                ),
                              ),
                              const Text(
                                "Remember Me",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: forgotPassword,
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 49, 49, 49),
                              ),
                            ),
                          ),
                        ],
                      ),
                      MyButton(
                        onTab: loginUser,
                        text: "LOG IN",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
