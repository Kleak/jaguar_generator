library jaguar.generator.hook.api;

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'package:jaguar/src/annotations/import.dart' as ant;

import 'package:source_gen_help/import.dart';

import 'package:jaguar_generator/parser/parser.dart';
import 'package:jaguar_generator/validator/validator.dart';
import 'package:jaguar_generator/models/models.dart';
import 'package:jaguar_generator/toModel/toModel.dart';
import 'package:jaguar_generator/writer/writer.dart';

class ApiGenerator extends GeneratorForAnnotation<ant.Api> {
  const ApiGenerator();

  /// Generator
  @override
  Future<String> generateForAnnotatedElement(
      Element element, ant.Api api, BuildStep buildStep) async {
    if (element is! ClassElement) {
      throw new Exception("Api annotation can only be defined on a class.");
    }

    ClassElementWrap clazz = new ClassElementWrap(element);

    print("Generating for api class ${clazz.name} ...");

    // Parse source code
    ParsedUpper parsed = new ParsedUpper(clazz, api.path)..parse();

    //Validate
    new ValidatorUpper(parsed)..validate();

    //Create model
    Upper model = new ToModelUpper(parsed).toModel();

    //Write
    return new Writer(model).generate();
  }
}
