import 'package:flutter/material.dart';
import 'package:contatos/helpers/contact.dart';
import 'package:contatos/uiPages/contactpage.dart';
import 'package:url_launcher/url_launcher.dart';

ContactHelper helper = ContactHelper();
List<Contact> _contactsList = [];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Contatos",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 3),
          semanticsLabel:
              "Isso e uma Appbar, onde esta escrito contatos, que tambem e o nome do app aberto",
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
          child: ListView.builder(
              itemBuilder: (context, index) {
                return customCard(index);
              },
              itemCount:
                  _contactsList.length == null ? 0 : _contactsList.length)),
    );
  }

  Widget customCard(index) {
    return GestureDetector(
        child: Card(
          elevation: 1,
          color: Colors.white,
          borderOnForeground: true,
          semanticContainer: true,
          margin: EdgeInsets.fromLTRB(10, index == 0 ? 20 : 5, 10,
              index == _contactsList.length - 1 ? 20 : 5),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin:
                    EdgeInsets.only(left: 10, right: 15, top: 10, bottom: 10),
                height: 90,
                width: 90,
                child: CircleAvatar(
                  backgroundImage: AssetImage(_contactsList[index].img == null
                      ? "images/contact-icon.png"
                      : _contactsList[index].img),
                  backgroundColor: Colors.transparent,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      _contactsList[index].name == null
                          ? ""
                          : _contactsList[index].name,
                      overflow: TextOverflow.ellipsis,
                      semanticsLabel: "Nome do contato",
                      maxLines: 2,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Container(
                    child: Text(
                      _contactsList[index].phone == null
                          ? ""
                          : _contactsList[index].phone,
                      overflow: TextOverflow.ellipsis,
                      semanticsLabel: "Numero do contato",
                      maxLines: 2,
                      style: TextStyle(color: Colors.black45, fontSize: 12),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        onTap: () {
          showOptions(context, index);
        });
  }

  void showOptions(context, index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(0),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            FlatButton.icon(
                                onPressed: () async {
                                  if (await canLaunch(
                                      "tel:${_contactsList[index].phone}")) {
                                    Navigator.pop(context);
                                    launch("tel:${_contactsList[index].phone}");
                                  } else {
                                    throw ("um erro inesperado aconteceu");
                                  }
                                },
                                padding: EdgeInsets.only(left: 50, right: 150),
                                icon: Icon(Icons.call),
                                label: Text("Ligar"))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            FlatButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showContactPage(
                                      contact: _contactsList[index]);
                                },
                                padding: EdgeInsets.only(left: 50, right: 150),
                                icon: Icon(Icons.edit),
                                label: Text("Editar"))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            FlatButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  reallyDelete(context, index);
                                },
                                padding: EdgeInsets.only(left: 50, right: 150),
                                icon: Icon(Icons.delete),
                                label: Text("Excluir"))
                          ],
                        ),
                      ]),
                );
              });
        });
  }

  getAllContacts() {
    helper.getAllContacts().then((value) {
      setState(() {
        _contactsList = value;
      });
    });
  }

  _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));
    if (recContact != null) {
      if (contact != null) {
        helper.updateContact(recContact);
        getAllContacts();
      } else {
        helper.saveContact(recContact);
        getAllContacts();
      }
    }
  }

  void reallyDelete(context, index) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Tem certeza?"),
              content:
                  Text("Voce deseja deletar o contato ${_contactsList[index].name}?"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Nao")),
                FlatButton(
                    onPressed: () {
                      helper.deleteContact(_contactsList[index].id);
                      Navigator.pop(context);
                      getAllContacts();
                    },
                    child: Text("Sim")),
              ],
            ));
  }
}
