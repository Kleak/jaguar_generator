library jaguar_generator.models;

import 'package:source_gen_help/source_gen_help.dart';

import 'package:jaguar/src/annotations/import.dart' as ant;

part 'interceptor/param.dart';
part 'interceptor/subparam.dart';
part 'interceptor/interceptor.dart';
part 'route.dart';
part 'input/input.dart';
part 'exception.dart';

class Method {
  final String name;

  final String prototype;

  Method(this.name, this.prototype);
}

class Upper {
  String name;

  String prefix;

  bool usesQueryParam;

  final List<Route> routes = [];

  final List<Group> groups = [];

  final Map<String, Method> methods = {};

  void addMethod(Method method) {
    if (methods.containsKey(method.name)) {
      return;
    }

    methods[method.name] = method;
  }
}
