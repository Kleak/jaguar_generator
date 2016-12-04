part of jaguar_generator.validator;

class PathParamsValidator implements Validator {
  final ParameterElementWrap param;

  final ParsedInputPathParams input;

  DartTypeWrap get paramType => param.type;

  PathParamsValidator(this.input, this.param);

  void validate() {
    if (paramType.isDynamic) {
      throw new GeneratorException(
          '', 0, 'Parameter type for InputPathParams cannot be dynamic!');
    }

    ClassElementWrap clazz = paramType.clazz;

    ConstructorElementWrap con = clazz.getNamedConstructors('FromPathParam');

    if (con == null) {
      throw new GeneratorException('', 0,
          'Parameter to InputPathParams must have FromPathParam constructor!');
    }

    if (con.requiredParameters.length != 1) {
      throw new GeneratorException(
          '', 0, 'FromPathParam must have one required argument!');
    }

    if (!con.requiredParameters.first.type
        .isSubTypeOfNamedElement(NamedElement.kTypeMap)) {
      throw new GeneratorException(
          '', 0, "FromPathParam's required argument must be derived from Map!");
    }
  }
}

class QueryParamsValidator implements Validator {
  final ParameterElementWrap param;

  final ParsedInputQueryParams input;

  DartTypeWrap get paramType => param.type;

  QueryParamsValidator(this.input, this.param);

  void validate() {
    if (paramType.isDynamic) {
      throw new GeneratorException(
          '', 0, 'Parameter type for InputQueryParams cannot be dynamic!');
    }

    ClassElementWrap clazz = paramType.clazz;

    ConstructorElementWrap con = clazz.getNamedConstructors('FromQueryParam');

    if (con == null) {
      throw new GeneratorException('', 0,
          'Parameter to InputQueryParams must have FromQueryParam constructor!');
    }

    if (con.requiredParameters.length != 1) {
      throw new GeneratorException(
          '', 0, 'FromQueryParam must have one required argument!');
    }

    if (!con.requiredParameters.first.type
        .isSubTypeOfNamedElement(NamedElement.kTypeMap)) {
      throw new GeneratorException('', 0,
          "FromQueryParam's required argument must be derived from Map!");
    }
  }
}

class InputInterceptorTypeChecker implements Validator {
  final List<ParsedInterceptor> interceptors;

  final ParameterElementWrap param;

  final ParsedInputInterceptor input;

  InputInterceptorTypeChecker(this.input, this.param, this.interceptors);

  void validate() {
    ParsedInterceptor inter = interceptors.firstWhere((inter) {
      return inter.resultName == input.genName;
    }, orElse: () => null);

    if (inter == null) {
      throw new GeneratorException(
          '', 0, 'Interceptor not found for input ${input.genName}!');
    }

    if (inter.pre == null) {
      throw new GeneratorException('', 0,
          "An interceptor that doesn't have pre has been used as input!");
    }

    if (inter.returnsFutureFlattened.isVoid) {
      throw new GeneratorException(
          '', 0, "An interceptor that returns void has been used as input!");
    }

    if (!inter.returnsFutureFlattened.isAssignableTo(param.type)) {
      throw new GeneratorException('', 0,
          "Interceptor's result type does not match input's param type!");
    }
  }
}

/// Validates that the return type of the interceptor and the type of the
/// param are assignable.
class InputTypeChecker implements Validator {
  final ChainFunction host;

  final int inputIndex;

  final List<ParsedInterceptor> interceptors;

  InputTypeChecker(this.host, this.inputIndex, this.interceptors);

  void validate() {
    final ParsedInput input = host.inputs[inputIndex];
    final int paramIdx = host.numDefaultInputs + inputIndex;
    final param = host.method.requiredParameters[paramIdx];

    Validator checker;

    if (input is ParsedInputInterceptor) {
      checker = new InputInterceptorTypeChecker(input, param, interceptors);
    } else if (input is ParsedInputPathParams) {
      checker = new PathParamsValidator(input, param);
    } else if (input is ParsedInputQueryParams) {
      checker = new QueryParamsValidator(input, param);
    }

    checker?.validate();
  }
}
