library jaguar.generator.hook.api;

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'package:jaguar_generator/writer/import.dart';

import 'package:jaguar/src/annotations/import.dart' as ant;

import 'package:jaguar_generator/parser/import.dart';

class ApiGenerator extends GeneratorForAnnotation<ant.Api> {
  const ApiGenerator();

  /// Generator
  @override
  Future<String> generateForAnnotatedElement(
      Element element, ant.Api api, BuildStep buildStep) async {
    if (element is! ClassElement) {
      throw new Exception("Api annotation can only be defined on a class.");
    }

    ClassElement classElement = element;
    String className = classElement.name;

    print("Generating for Api class $className ...");

    final String prefix = api.url;

    Writer writer = new Writer(className, prefix: prefix);

    List<InterceptorInfo> interceptors = parseInterceptor(element);

    List<ExceptionHandlerInfo> exceptions = collectExceptionHandlers(element);

    List<RouteInfo> routes =
        collectRoutes(classElement, prefix, interceptors, exceptions, []);

    writer.addGroups(collectGroups(classElement));

    writer.addAllRoutes(routes);

    return writer.toString();
  }
}
