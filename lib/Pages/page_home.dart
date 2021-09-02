

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool genre = false;
  double? poids;
  double? age;
  double taille = 170.0;
  int? radioSelectionnee;
  Map mapActivite = {
    0: "Faible",
    1: "Modere",
    2: "Forte"
  };

  // Le résultat de cette application donne 2 dépenses calorique : avec et sans activités
  int? calorieBase;
  int? calorieAvecActivite;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (()=> FocusScope.of(context).requestFocus(new FocusNode())),
      child:(Platform.isAndroid)
        ? CupertinoPageScaffold(
              child: body(),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: setColor(),
            middle: TextAvecStyle("Calories"),
          ),
            )
        : Scaffold(
        appBar: AppBar(
          title: Text("Calories"),
          backgroundColor: setColor(),
        ),
        body: body(),
      ),
    ) ;


  }

  Widget body(){
    return SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextAvecStyle("Remplissez tous les champs pour obtenir votre besoin journalier en calories"),
              Card(
                elevation: 10.0,
                child: Column(
                  children: [
                    Row (
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextAvecStyle("Femme", color: Colors.pink),
                        switchSelonPlatform(),
                        TextAvecStyle("Homme", color: Colors.blue)
                      ],
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(setColor())
                        ),
                        child: TextAvecStyle((age == null)? "Appuyez pour votre age ": "Votre age est de : ${age!.toInt()} ans",color: Colors.white),
                        onPressed: () => montrerPicker()
                    ),
                    Padding(padding: EdgeInsets.only(top: 20.0)),
                    TextAvecStyle("Votre taille est de : ${taille.toInt()} cm.", color: setColor()),
                    Slider(
                      value: taille,
                      activeColor: setColor(),
                      onChanged: (double d){
                        setState(() {
                          taille = d;
                        });
                      },
                      max: 215.0,
                      min: 100.0,
                    ),
                    Padding(padding: EdgeInsets.only(top: 20.0)),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (String value) {
                        setState(() {
                          poids = double.tryParse(value);
                        });
                      },
                      decoration: InputDecoration(labelText: "Entrez votre poids en Kilos."),
                    ),
                    TextAvecStyle("Quelle est votre activité sportive ?", color: setColor()),
                    Padding(padding: EdgeInsets.only(top: 20.0)),
                    rowRadio(),
                    Padding(padding: EdgeInsets.only(top: 20.0)),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 20.0)),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(setColor())
                  ),
                  child: TextAvecStyle("Calculer", color: Colors.white),
                  onPressed: calculerNombreDeCalories
              )
            ],
          ),
        )
    );
  }

  Widget switchSelonPlatform(){
    if(Platform.isAndroid){
      return CupertinoSwitch(
          value: genre,
          activeColor: Colors.blue,
          trackColor: Colors.pink,
          onChanged: (bool b){
            setState(() {
              genre = b;
            });
          });
    }else{
      return Switch(
          value: genre,
          inactiveTrackColor: Colors.pink,
          activeTrackColor: Colors.blue,
          onChanged: (bool b){
            setState(() {
              genre = b;
            });
          });
    }
  }

  Row rowRadio(){
    List<Widget> l = [] ;

    // Cette Row contiendra autant de colonne qu'il y'a de Radio
    mapActivite.forEach((key,value){
      Column colonne = new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Radio(
              activeColor: setColor(),
              value: key,
              groupValue: radioSelectionnee,
              onChanged: (dynamic i){
                setState(() {
                  radioSelectionnee = i;
                });
              }),
          TextAvecStyle(value, color: setColor())
        ],
      );
      l.add(colonne);
    });


    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: l,
    );
  }



  Color setColor(){
    //Genre est à true alors homme sinon femme
    if(genre) {
      return Colors.blue;
    }else{
      return  Colors.pink;
    }
  }

  Future<Null> montrerPicker() async {
    DateTime? choix = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      firstDate: new DateTime(1900),
      lastDate: new DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    print(choix);
    if(choix != null){
      var difference = new DateTime.now().difference(choix);
      var jours = difference.inDays;
      var ans = (jours / 365);
      setState(() {
        age = ans;
      });
    }
  }

  void calculerNombreDeCalories(){
    //Vérification des champs
    if(age != null && poids != null && radioSelectionnee != null){
      if(genre){
        calorieBase = (66.4730 + (13.7516 * poids!) + (5.0033 * taille) - (6.7550 * age!)).toInt();
      }else{
        calorieBase = (655.0955 + (9.5634 * poids!) + (1.8496 * taille) - (4.6756 * age!)).toInt();
      }
      switch(radioSelectionnee){
        case 0:
          calorieAvecActivite = (calorieBase! * 1.2).toInt();
          break;
        case 1:
          calorieAvecActivite = (calorieBase! * 1.5).toInt();
          break;
        case 2:
          calorieAvecActivite = (calorieBase! * 1.8).toInt();
          break;
        default:
          calorieAvecActivite = calorieBase;
          break;
      }
      setState(() {
        dialogue();
      });
    }else{
      //Alerte erreur
      alerte();
    }
  }


  // Fonction qui affiche la boite de dialogue finale
  Future<Null> dialogue() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext buildContext){
          return SimpleDialog(
            title: TextAvecStyle("Votre besoin en calories", color: setColor()),
            contentPadding: EdgeInsets.all(15.0),
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 20.0)),
              TextAvecStyle("Votre besoin de base est de : ${calorieBase}"),
              Padding(padding: EdgeInsets.only(top: 20.0)),
              TextAvecStyle("Votre besoin avec activité sportive est de  : ${calorieAvecActivite}"),
              ElevatedButton(
                onPressed: (){
                  Navigator.pop(buildContext);
                },
                child: TextAvecStyle("OK", color: Colors.white),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(setColor())
                ),
              )
            ],
          );
        }
    );
  }

  // Fonction qui affiche la boite de dialogue erreur
  Future<Null> alerte() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext buildContext){
          return AlertDialog(
            title: TextAvecStyle("Erreur"),
            content: TextAvecStyle("Tous les champs ne sont pas remplis"),
            actions: <Widget>[
              TextButton(
                  onPressed: (){
                    Navigator.pop(buildContext);
                  },
                  child: TextAvecStyle("OK", color: Colors.red))
            ],
          );
        }
    );
  }

  Text TextAvecStyle(String data, {color: Colors.black, fontSize: 15.0}){
    return Text(
      data,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: color,
          fontSize: fontSize
      ),
    );
  }
}
