library jaguar.generator.parser.route;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/src/annotation.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'package:jaguar/src/annotations/import.dart' as ant;
import 'package:source_gen_help/import.dart';

import 'package:jaguar_generator/common/constants.dart';

part 'exception.dart';
part 'group.dart';
part 'input.dart';
part 'route.dart';
part 'interceptor/func.dart';
part 'interceptor/interceptor.dart';
part 'interceptor/interceptor_help.dart';

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
      AnnotationElementWrap routeAnnot = ParsedRoute.detectRoute(method);

      if (routeAnnot == null) {
        return null;
      }

      routes.add(new ParsedRoute(this, method, routeAnnot));
    }
  }

  void _collectGroups() {
    for (FieldElement field in upper.fields) {
      ant.Group group = ParsedGroup.detectGroup(field);

      if (group == null) {
        continue;
      }

      DartTypeWrap type = new DartTypeWrap(field.type);
      groups.add(new ParsedGroup(group, type, field.name));
    }
  }
}

class GeneratorException {
  final String filename;

  final int line;

  final String message;

  GeneratorException(this.filename, this.line, this.message);
}
