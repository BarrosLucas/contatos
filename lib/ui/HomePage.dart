import 'dart:io';

import 'package:contatos/helpers/contact_helper.dart';
import 'package:contatos/ui/ContactPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza}

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
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context)=> <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordernar de A a Z"),
                value: OrderOptions.orderaz,
              ),const PopupMenuItem<OrderOptions>(
                child: Text("Ordernar de Z a A"),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          )
        ],
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
                            AssetImage("assets/img/user.png"),
                    fit: BoxFit.cover
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

        _showOptions(context, contact);
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
      }else{
        await contactHelper.save(ret);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts(){
    contactHelper.getAllContact().then((value){
      setState(() {
        contacts = value;
      });
    });
  }

  _showOptions(BuildContext context, Contact contact){
    showModalBottomSheet(context: context, builder: (context){
      return BottomSheet(
        onClosing: (){},
        builder: (context){
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  padding: EdgeInsets.all(10),
                  child: Text("Ligar", style: TextStyle(
                    color: Colors.red, fontSize: 20
                  ),),
                  onPressed: (){
                    Navigator.pop(context);
                    launch("tel: ${contact.phone}");
                  },
                ),
                FlatButton(
                  padding: EdgeInsets.all(10),
                  child: Text("Editar", style: TextStyle(
                      color: Colors.red, fontSize: 20
                  ),),
                  onPressed: (){
                    Navigator.pop(context);
                    _showContactPage(contact: contact);
                    //
                  },
                ),
                FlatButton(
                  padding: EdgeInsets.all(10),
                  child: Text("Excluir", style: TextStyle(
                      color: Colors.red, fontSize: 20
                  ),),
                  onPressed: (){
                    contactHelper.deleteContact(contact.id);
                    setState(() {
                      _getAllContacts();
                      Navigator.pop(context);
                    });
                  },
                )
              ],
            ),
          );
        },
      );
    });
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a,b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a,b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;

    }
    setState(() {

    });
  }
}
