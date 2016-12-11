part of jaguar.generator.parser.route;

bool _needsHttpRequest(MethodElementWrap method) {
  if (method.parameters.length < 1) {
    return false;
  }

  return kHttpRequest.compareNamedElement(method.parameters[0].type);
}

/// Holds information about interceptor functions
class ParsedInterceptorFuncDef extends Object
    with MethodReturnTypeMixin, ChainFunction {
  /// The function or method element
  final MethodElementWrap method;

  /// Inputs declared on the interceptor
  final List<ParsedInput> inputs;

  /// Does this function return jaguar response?
  bool get returnsResponse =>
      returnsFutureFlattened.compareNamedElement(kJaguarResponse);

  /// Default constructor. Constructs [InterceptorFuncDef] from the given
  /// method element
  ParsedInterceptorFuncDef(this.method, this.inputs);

  factory ParsedInterceptorFuncDef.Make(MethodElementWrap method) {
    List<ParsedInput> inputs = ParsedInput.detectInputs(method,
        method.parameters, getNumDefaultInputs(_needsHttpRequest(method)));

    return new ParsedInterceptorFuncDef(method, inputs);
  }

  bool get canHaveQueryParams => false;

  static int getNumDefaultInputs(bool httpReq) => httpReq ? 1 : 0;

  @override
  int get numDefaultInputs => getNumDefaultInputs(needsHttpRequest);
}

abstract class ChainFunction {
  /// The function or method element
  MethodElementWrap get method;

  List<ParsedInput> get inputs;

  /// Can this chain function have query params;
  bool get canHaveQueryParams;

  bool get needsHttpRequest => _needsHttpRequest(method);

  int get numDefaultInputs;

  int get allInputsLen => inputs.length + numDefaultInputs;

  List<ParameterElementWrap> get optionalParams => method.optionalParameters;

  bool get areOptionalParamsPositional => method.areOptionalParamsPositional;

  List<ParameterElementWrap> get nonInputParams {
    if (method.requiredParameters.length <= allInputsLen) {
      return <ParameterElementWrap>[];
    } else {
      return method.requiredParameters.sublist(allInputsLen);
    }
  }

  bool get usesQueryParam {
    if (inputs.any((ParsedInput inp) => inp is ParsedInputQueryParams)) {
      return true;
    }

    if (canHaveQueryParams) {
      if (!areOptionalParamsPositional && optionalParams.length != 0) {
        return true;
      }
    }

    return false;
  }
}
