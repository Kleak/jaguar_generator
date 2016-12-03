library jaguar_generator.validator;

import 'package:source_gen_help/import.dart';

import 'package:jaguar_generator/parser/parser.dart';

part 'interceptor_func.dart';
part 'input.dart';

class ValidatorOfGroup {
  ParsedGroup group;

  void validate() {
    //TODO check that type implements RequestHandler
  }
}

class ValidatorUpper {
  ParsedUpper upper;

  ValidatorUpper(this.upper);

  void validate() {
    //TODO
  }
}
