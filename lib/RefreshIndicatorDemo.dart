import 'package:flutter/material.dart';

class Refreshindicatordemo extends StatefulWidget {
  const Refreshindicatordemo({super.key});

  @override
  State<Refreshindicatordemo> createState() => _RefreshindicatordemoState();
}

class _RefreshindicatordemoState extends State<Refreshindicatordemo> {
  List<String> items=["Item 1"];

  Future<void> _refreshData()async {

    await Future.delayed(Duration(seconds: 2));
    setState(() {
      items.add("Item${items.length+1}");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("REFRESH INDICATOR PAGE"),
      ),
      body: RefreshIndicator(
          child: ListView.builder(
              itemCount: items.length
              ,itemBuilder: (context,index){
                return ListTile(
                  title: Text(items[index],style: TextStyle(color: Colors.blue),),
                );
          }),
          onRefresh: _refreshData),

    );
  }
}
