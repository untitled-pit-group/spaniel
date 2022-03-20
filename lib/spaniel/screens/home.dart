import "package:flutter/material.dart";
import "package:get/get.dart";

class SPHome extends StatelessWidget {
  const SPHome({Key? key}) : super(key: key);

  Widget _getContents(BuildContext context) {
    return Center(
      heightFactor: 20,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("home_title".tr),
        )
      ),
    );
  }

  Widget _getBody(BuildContext context) {
    return SingleChildScrollView(
      child: _getContents(context)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("home_title".tr)
      ),
      body: _getBody(context)
    );
  }
}