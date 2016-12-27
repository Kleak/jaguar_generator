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

  DartTypeWrap get jaguarResponseType {
    if (!returnsResponse) {
      throw new Exception("Bug! Please report it to Jaguar developers!");
    }

    return returnsFutureFlattened.typeArguments.first;
  }

  /// Default constructor. Constructs [InterceptorFuncDef] from the given
  /// method element
  ParsedInterceptorFuncDef(this.method, this.inputs);

  bool get canHaveQueryParams => false;

  static int getNumDefaultInputs(bool httpReq) => httpReq ? 1 : 0;

  @override
  int get numDefaultInputs => getNumDefaultInputs(needsHttpRequest);
}

class ParsedInterceptorFuncDefBuilder {
  final MethodElementWrap method;

  ParsedInterceptorFuncDef _func;

  ParsedInterceptorFuncDef get func => _func;

  ParsedInterceptorFuncDefBuilder(this.method) {
    final List<ParsedInput> inputs = _detectInputs();

    _func = new ParsedInterceptorFuncDef(method, inputs);
  }

  int get numDefaultInputs =>
      ParsedInterceptorFuncDef.getNumDefaultInputs(_needsHttpRequest(method));

  //Detects inputs
  List<ParsedInput> _detectInputs() {
    final List<ParsedInput> inputs =
        ParsedInput.detectInputs(method, method.parameters, numDefaultInputs);

    final int numMethodInps = numDefaultInputs + inputs.length;
    bool hasFinished = false;

    //Detect inputs on parameters
    for (int idx = numDefaultInputs;
        idx < method.requiredParameters.length;
        idx++) {
      final ParameterElementWrap param = method.requiredParameters[idx];

      ParsedInput input = ParsedInput.detectOnParam(param);

      if (idx < numMethodInps) {
        if (input is ParsedInput) {
          final except = new InputException(
              'Input for this method is already specified on method!');
          except.param = param.name;
          throw except;
        }
        continue;
      }

      if (input is ParsedInput) {
        if (hasFinished) {
          final except = new InputException(
              'Inputs must be specified in consecutive params!');
          except.param = param.name;
          throw except;
        }
        inputs.add(input);
      } else {
        hasFinished = true;
      }
    }

    return inputs;
  }
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
