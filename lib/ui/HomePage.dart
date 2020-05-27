import 'dart:io';

import 'package:contatos/helpers/contact_helper.dart';
import 'package:contatos/ui/ContactPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper contactHelper = ContactHelper();
  List<Contact> contacts = [];


  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contato"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: Container(
        child: ListView.builder(itemBuilder: (context, index){
          return _contactCard(context, contacts[index]);
        }, padding: EdgeInsets.all(10),itemCount: contacts.length,),
      )
    );
  }

  Widget _contactCard(BuildContext context, Contact contact){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contact.img != null ?
                            FileImage(File(contact.img)):
                            AssetImage("assets/img/user.png")
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contact.name?? "", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                    Text(contact.email?? "", style: TextStyle(fontSize: 18),),
                    Text(contact.phone?? "", style: TextStyle(fontSize: 18),),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: (){
        _showContactPage(contact: contact);
      },
    );
  }
  void _showContactPage({Contact contact}) async{
    final ret = await Navigator.push(context, MaterialPageRoute(
      builder: (context)=>ContactPage(contact: contact,)
    ));
    if(ret != null){
      if(contact != null){
        await contactHelper.updateContact(ret);
        _getAllContacts();
      }else{
        await contactHelper.save(ret);
        _getAllContacts();
      }
    }
  }

  void _getAllContacts(){
    contactHelper.getAllContact().then((value){
      setState(() {
        contacts = value;
      });
    });
  }
}
