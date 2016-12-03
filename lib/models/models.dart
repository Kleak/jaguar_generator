library jaguar_generator.models;

import 'package:source_gen_help/import.dart';

import 'package:jaguar/src/annotations/import.dart' as ant;

part 'interceptor/param.dart';
part 'interceptor/subparam.dart';
part 'interceptor/interceptor.dart';
part 'route.dart';
part 'input/input.dart';
part 'exception.dart';

class Upper {
  String name;

  String prefix;

  bool usesQueryParam;

  final List<Route> routes = [];

  final List<Group> groups = [];
}
