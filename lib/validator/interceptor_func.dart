part of jaguar_generator.validator;

class ValidatorOfInterceptorFuncDef implements Validator {
  final ParsedInterceptorFuncDef func;

  ValidatorOfInterceptorFuncDef(this.func);

  List<ParameterElementWrap> get requiredParameters =>
      func.method.requiredParameters;

  List<ParsedInput> get inputs => func.inputs;

  int get numDefaultInputs => func.numDefaultInputs;

  void validate() {
    if (requiredParameters.length < inputs.length) {
      throw new Exception(
          "Inputs and parameters to interceptor does not match!");
    }

    for (int index = 0; index < inputs.length; index++) {
      //TODO ParameterElementWrap param = requiredParameters[numDefaultInputs + index];
      ParsedInput input = inputs[index];

      if (input is ParsedInputPathParams) {
        //TODO has FromPathParam constructor and implements PathParams
      } else if (input is ParsedInputQueryParams) {
        //TODO has FromQueryParam constructor and implements QueryParams
      }
    }
  }
}
