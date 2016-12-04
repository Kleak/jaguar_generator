library jaguar_generator.validator.interceptor;

import 'package:jaguar_generator/parser/parser.dart';
import 'package:jaguar_generator/common/validator.dart';

class NoPrePost implements Validator {
  final ParsedInterceptor interceptor;

  NoPrePost(this.interceptor);

  void validate() {
    if (interceptor.pre == null && interceptor.post == null) {
      throw new GeneratorException('', 0,
          'Atleast one of pre or post method must be specified in an Interceptor!');
    }
  }
}
