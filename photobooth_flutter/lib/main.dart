import 'package:flutter/material.dart';

import 'src/app/photobooth_app.dart';
import 'src/composition/production_composition_root.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PhotoboothApp(dependencies: buildProductionDependencies()));
}
