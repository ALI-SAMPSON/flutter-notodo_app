import 'package:flutter/material.dart';
import 'package:notodo_app/model/nodo_item.dart';
import 'package:notodo_app/util/database_client.dart';
import 'package:notodo_app/util/date_formatter.dart';

class NoToDoScreen extends StatefulWidget {
  @override
  _NoToDoScreenState createState() => _NoToDoScreenState();
}

class _NoToDoScreenState extends State<NoToDoScreen> {

  final TextEditingController _textEditingController = new TextEditingController();

  final List<NoDoItem> _itemList = <NoDoItem>[];

  // getting an instance of db
  var db = new DatabaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // method call to display items
    _showNoDoList();

  }

  // Handle saving of item
  void _handleSubmitted(String text) async{

    if(_textEditingController.text.isNotEmpty){
      _textEditingController.clear();
      /// code to save data
      NoDoItem noDoItem = new NoDoItem(text, dateFormatted());
      int saveItemId = await db.saveItem(noDoItem);

      // getting an added Item and adding to list
      NoDoItem addedItem = await db.getItem(saveItemId);

      setState(() {
        // inserting item into list
        _itemList.insert(0, addedItem);
      });

      print("Item saved id: $saveItemId");

    }
    else{
         SnackBar snackBar = new SnackBar(content: new Text("Please enter an item"),);
         Scaffold.of(context).showSnackBar(snackBar);
    }

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.black87,

        body: new Column(
          children: <Widget>[
            new Flexible(
                child: new ListView.builder(
                    itemCount: _itemList.length,
                    reverse:false,
                    padding: new EdgeInsets.all(5.0),
                    itemBuilder: (_,int index){
                    return new Card(
                      color: Colors.white10,
                      child: new ListTile(
                          title: _itemList[index],
                        // long press to update item
                        onLongPress: () => updateItem(_itemList[index],index),
                        // item to add at the end of a row in a listView
                        trailing: new Listener(
                          key: new Key(_itemList[index].itemName),
                          child: new Icon(Icons.remove_circle,
                            color: Colors.redAccent,),
                            onPointerDown: (pointerEvent) => deleteNotDo(_itemList[index].id,index),
                        ),
                      ),
                    );
                }),
            ),

            new Divider(
              height: 1.0,
            )

          ],
        ),

        floatingActionButton: new FloatingActionButton(
          tooltip: "Add Item",
          child: new ListTile(
            title: new Icon(Icons.add),
          ),
          backgroundColor: Colors.redAccent,
            onPressed: () => _showFormDialog(context)
        ),
    );
  }

  void _showFormDialog(BuildContext context) {

    var alertDialog = new AlertDialog(
      content: new Row(
        children: <Widget>[
          new  Expanded(
              child: new TextField(
                controller: _textEditingController,
                autofocus: true,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                    labelText: "Enter Item",
                    hintText: "eg. Don't buy stuff",
                    icon: new Icon(Icons.note_add)
                ),
              ),
          )
        ],
      ),

      actions: <Widget>[
        new FlatButton(
            onPressed: ()
            {
              // method to save item
              _handleSubmitted(_textEditingController.text);
              _textEditingController.clear();

              // close dialog after item is saved
              Navigator.pop(context);

            },
            child: new Text("Add")),

        new FlatButton(
            onPressed: () => Navigator.pop(context),
            child: new Text("Cancel")),

      ],

    );

    showDialog(context: context,builder: (_){
      return alertDialog;
    });

  }

  _showNoDoList() async{
    List items = await db.getItems();
    items.forEach((item){
      //NoDoItem noDoItem = NoDoItem.fromMap(item);
      setState(() {
        _itemList.add(NoDoItem.map(item));
      });
      //print("db items: ${noDoItem.itemName}" );
    });

  }

  deleteNotDo(int id, int index) async{

    // Open alert Dialog to alert user of deletion
    var alert  = new AlertDialog(
      content: new Text("Are you sure you want to delete this item"),
      actions: <Widget>[
        FlatButton(
            onPressed: () async {

              // Deleting item from db and redraw state of list view widget
              //debugPrint("Delete it now");
              await db.deleteItem(id);
              setState(() {
                // redrawing the state of listView
                _itemList.removeAt(index);
              });

              Navigator.pop(context);

            },
            child: new Text("Yes")),

        FlatButton(
            onPressed: () => Navigator.pop(context) ,
            child: new Text("No")),

      ],
    );

    showDialog(context: context,builder: (context){
      return alert;
    });


  }

  void updateItem(NoDoItem item, int index) {
      var alert = new AlertDialog(
        title: new Text("Update Item"),
        content: new Row(
          children: <Widget>[
            new Expanded(
                child: new TextField(
                  controller: _textEditingController,
                  autofocus: true,

                  decoration: new InputDecoration(
                    labelText: "Enter an item",
                    hintText: "e.g Don't buy stuff",
                    icon: new Icon(Icons.update)
                  ),

                )
            )
          ],
        ),
        
        
        actions: <Widget>[

          FlatButton(
              onPressed: () async{

                if(_textEditingController.text.isNotEmpty){

                  NoDoItem updateItem = NoDoItem.fromMap({
                    "itemName": _textEditingController.text,
                    "dateCreated" : dateFormatted(),
                    "id" : item.id
                  });

                  // method call to remove item and update item at the same time
                  _handleSubmittedUpdate(item,index);
                  await db.updateItem(updateItem); //updating item
                  // read list again to get list of data after item is updated(redrawing the screen with all items saved in db)
                  setState(() {
                    _showNoDoList();
                  });
                  // hide alert Dialog
                  Navigator.pop(context);

                  // clear field
                  _textEditingController.clear();

                }
                else{
                  SnackBar snackBar = new SnackBar(content: new Text("Please enter an item"),);
                  Scaffold.of(context).showSnackBar(snackBar);
                }



              },
              child: new Text("Update")),

          FlatButton(
              onPressed: () => Navigator.pop(context),
              child: new Text("Cancel"))
        ],
        
      );

      showDialog(context: context,builder: (_){
        return alert;
      });
  }

  // method to handle updating of an item
  void _handleSubmittedUpdate(NoDoItem item, int index) {

    setState(() {
      _itemList.removeWhere((element){
          // ignore: unnecessary_statements
          _itemList[index].itemName == item.itemName;
      });

    });
  }

}
