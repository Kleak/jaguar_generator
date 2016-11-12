part of jaguar.generator.parser.interceptor;

/// Holds information about interceptor functions
class InterceptorFuncDef {
  /// The function or method element
  final MethodElementWrap _method;

  DartType get returnType => _method.returnType;

  bool get returnsVoid => returnType.isVoid;

  bool get returnsFuture => returnType.isDartAsyncFuture;

  DartType get returnsFutureFlattened {
    if (returnType == null) {
      return null;
    }

    if (!returnsFuture) {
      return returnType;
    }

    return returnType.flattenFutures(returnType.element.context.typeSystem);
  }

  bool get returnsResponse => new DartTypeWrap(returnsFutureFlattened)
      .compare('Response', 'jaguar.src.http.response');

  /// Inputs declared on the interceptor
  List<Input> inputs = <Input>[];

  /// Default constructor. Constructs [InterceptorFuncDef] from the given
  /// method element
  InterceptorFuncDef(MethodElement aMethod)
      : _method = new MethodElementWrap(aMethod) {
    /// Initialize constant values
    _method.metadata
        .forEach((ElementAnnotation annot) => annot.computeConstantValue());

    /// Find and collect Inputs to the interceptor
    _method.metadata
        .map(createInput)
        .where((Input instance) => instance is Input)
        .forEach((Input inp) => inputs.add(inp));

    _validate();
  }

  void _validate() {
    if (_method.requiredParameters.length < inputs.length) {
      throw new Exception(
          "Inputs and parameters to interceptor does not match!");
    }

    for (int index = 0; index < inputs.length; index++) {
      ParameterElement param =
          _method.requiredParameters[_numDefaultInputs + index];
      Input input = inputs[index];

      if (input is InputPathParams) {
        //TODO has FromPathParam constructor and implements PathParams
        input.type = new DartTypeWrap(param.type);
      } else if (input is InputQueryParams) {
        //TODO has FromQueryParam constructor and implements QueryParams
        input.type = new DartTypeWrap(param.type);
      }
    }
  }

  bool get needsHttpRequest {
    if (_method.parameters.length < 1) {
      return false;
    }

    return _method.parameters[0].type.name ==
        "HttpRequest"; //TODO check which HttpRequest
  }

  int get _numDefaultInputs => needsHttpRequest ? 1 : 0;

  int get _allInputsLen => inputs.length + _numDefaultInputs;

  List<ParameterElement> get optionalParams => _method.optionalParameters;

  List<ParameterElement> get nonInputParams {
    if (_method.requiredParameters.length <= _allInputsLen) {
      return <ParameterElement>[];
    } else {
      return _method.requiredParameters.sublist(_allInputsLen);
    }
  }

  bool get shouldKeepQueryParam {
    if (inputs.any((Input inp) => inp is InputQueryParams)) {
      return true;
    }

    if (optionalParams.length != 0) {
      return true;
    }

    return false;
  }
}
