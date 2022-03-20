import "package:get/get.dart";

// Example for parameters
/*
Map<String, Map<String, String>> get keys => {
    'en_US': {
        'logged_in': 'logged in as @name with email @email',
    },
    'es_ES': {
       'logged_in': 'iniciado sesión como @name con e-mail @email',
    }
};

Text('logged_in'.trParams({
  'name': 'Jhon',
  'email': 'jhon@example.com'
  }));
*/

/// The GetX localizations package is pretty shit, but should be sufficient
/// for our needs. Maybe someone has made a codegen solution so do you don't have
/// to hardcode the keys.
class PifsLocalization extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    "lv_LV": {
      "home_title": "Diezgan neprātīga failu meklēšana",
    },
    "en_US": {
      "app_title": "Pretty Insane File Search",
      "home_title": "Pretty Insane File Search",
      "my_files": "My files",
      "name": "Name",
      "download": "Download",
      "upload": "Upload",
      "upload.choose_file": "Choose a file to upload",
      "search": "Search",
    },
  };
}