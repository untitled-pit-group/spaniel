import "package:flutter/material.dart";
import "package:get/get.dart";

class SPUpload extends StatelessWidget {
  const SPUpload({Key? key}) : super(key: key);

  Widget _getBody(BuildContext context) {
    return Column(
      children: [
        Text("upload.choose_file".tr),
        ElevatedButton(
          onPressed: () {},
          child: Text("upload".tr)
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("upload".tr)
      ),
      body: _getBody(context),
    );
  }
}