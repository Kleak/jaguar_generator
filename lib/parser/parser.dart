library jaguar.generator.parser.route;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/constant/value.dart';

import 'package:jaguar/src/annotations/import.dart' as ant;
import 'package:source_gen_help/source_gen_help.dart';

import 'package:jaguar_generator/common/constants.dart';

part 'exception.dart';
part 'group.dart';
part 'input.dart';
part 'route.dart';
part 'interceptor/func.dart';
part 'interceptor/interceptor.dart';
part 'interceptor/make_param.dart';
part 'interceptor/route_wrapper.dart';

class ParsedUpper {
  final ClassElementWrap upper;

  final String path;

  String get name => upper.name;

  final List<ParsedRoute> routes = <ParsedRoute>[];

  final List<ParsedInterceptor> interceptors = <ParsedInterceptor>[];

  final List<ParsedGroup> groups = <ParsedGroup>[];

  final List<ParsedExceptionHandler> exceptions = <ParsedExceptionHandler>[];

  ParsedUpper(this.upper, this.path);

  void parse() {
    _collectInterceptor();

    _collectRoutes();

    _collectGroups();

    ParsedExceptionHandler.detectAllExceptions(upper).forEach(exceptions.add);
  }

  void _collectInterceptor() {
    interceptors.addAll(ParsedInterceptor.detectInterceptors(upper));
  }

  void _collectRoutes() {
    for (MethodElementWrap method in upper.methods) {
      ParsedRoute route = ParsedRoute.detectRoute(this, method);

      if (route == null) {
        continue;
      }

      routes.add(route);
    }
  }

  void _collectGroups() {
    for (FieldElement field in upper.fields) {
      ParsedGroup group = ParsedGroup.detectGroup(field);

      if (group == null) {
        continue;
      }

      groups.add(group);
    }
  }
}

class GeneratorException {
  final String filename;

  final int line;

  final String message;

  GeneratorException(this.filename, this.line, this.message);

  String toString() => message;
}

class InputInterceptorException {
  final String message;

  String upper;

  String route;

  String interceptor;

  String input;

  String param;

  InputInterceptorException(this.message);

  String toString() {
    StringBuffer sb = new StringBuffer();

    sb.writeln('Message: $message');
    sb.writeln('RequestHandler: $upper');
    sb.writeln('Route: $route');
    if (interceptor is String) {
      sb.writeln('Interceptor: $interceptor');
    }
    if (input is String) {
      sb.writeln('Input: $input');
    }
    if (param is String) {
      sb.writeln('Input: $param');
    }

    return sb.toString();
  }
}
