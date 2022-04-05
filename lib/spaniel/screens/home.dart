import "package:flutter/material.dart";

class SPHome extends StatelessWidget {
  const SPHome({Key? key}) : super(key: key);

  Widget _getFileList(BuildContext context) {
    return Text("ssssssshhh is ok");
  }

  Widget _getContents(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _getFileList(context)
      ],
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
        title: Text("home_title")
      ),
      body: _getBody(context),
    );
  }
}