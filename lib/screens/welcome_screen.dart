import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/component/RoundedButton.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id ='welcome_screen';
  //declare as static so we can call this variable easily from the main class without needing to instantiate another class object
  //we can also declare as const so we wont accidentally edit it somewhere
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin{
  //SingleTickerProviderStateMixin = ticker provider
  //with SingleTickerProviderStateMixin meaning provide the _WelcomeScreenState with the ability to act as a ticker using the 'with' keyword

  AnimationController? controller;
  Animation<double>? animation;
  Animation? animationColor;


  @override
  void initState() {
    //custom animation
    controller = AnimationController(
        duration: Duration(seconds: 1),
        vsync: this, // meaning refer to this class = _WelcomeScreenState
       // upperBound: 100, //curvedanimation only allow 0 to 1
    );
    controller?.forward();

    animation = CurvedAnimation(parent: controller!, curve: Curves.decelerate); //implement CurvedAnimation into customAnimation
    animationColor = ColorTween(begin: Colors.blueGrey, end: Colors.white).animate(controller!);
    //animate() means we animated the ColorTween (from blurGrey to white) and return this animation to animationColor
    controller?.addListener(() {
      setState(() {
        
      });
      print(animation?.value);
      //everytime the animation execute, values add 1 til it reaches upper bound
      // (ticker is the electric supply which provide energy to animation controller to triggers & rebuild new setState() everytime with the addListener() callback'
      // C:\Users\yanqi\OneDrive\Desktop\flutter\flash-chat-flutter\photoComment\ticker vs animation controller.JPG
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animationColor?.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: animation!.value * 70,
                  ),
                ),

              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 45.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                        'Flash Chat',
                        speed: Duration(milliseconds: 100))
                  ],
                ),
              ),
                // TypewriterAnimatedTextKit(
                //   text: ['Flash Chat'],
                //   textStyle: TextStyle(
                //     fontSize: 45.0,
                //     fontWeight: FontWeight.w900,
                //   ),
                // ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              title: 'Login',
              color: Colors.lightBlueAccent,
              onPressed: (){Navigator.pushNamed(context, LoginScreen.id);},
            ),
            RoundedButton(
              title: 'Register',
              color: Colors.blueAccent,
              onPressed: (){Navigator.pushNamed(context, RegistrationScreen.id);},
            ),
          ],
        ),
      ),
    );
  }
}


