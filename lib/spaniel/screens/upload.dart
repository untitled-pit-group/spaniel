import "package:flutter/material.dart";

class SPUpload extends StatelessWidget {
  const SPUpload({Key? key}) : super(key: key);

  Widget _getBody(BuildContext context) {
    return Column(
      children: [
        Text("upload.choose_file"),
        ElevatedButton(
          onPressed: () {},
          child: Text("upload")
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("upload")
      ),
      body: _getBody(context),
    );
  }
}