part of jaguar_generator.validator;

class InterceptorOrderValidator implements Validator {
  final ParsedUpper upper;

  final ParsedRoute route;

  InterceptorOrderValidator(this.upper, this.route);

  void validate() {
    List<ParsedInterceptor> interceptors = upper.interceptors.toList();
    interceptors.addAll(route.interceptors);

    Map<String, bool> interceptorsAlreadyDefined = {};

    for (ParsedInterceptor inter in interceptors) {
      if (inter.pre != null) {
        inter.pre.inputs
            .where((inp) => inp is ParsedInputInterceptor)
            .forEach((ParsedInputInterceptor inp) {
          if (!interceptorsAlreadyDefined.containsKey(inp.genName)) {
            throw new GeneratorException(
                '', 0, 'The interceptor ${inp.genName} is not defined yet!');
          }
        });
      }

      inter.routeWrapper.params.values
          .where((ParsedMakeParam param) => param is ParsedMakeParamType)
          .forEach((ParsedMakeParamType inst) {
        inst.inputs
            .where((inp) => inp is ParsedInputInterceptor)
            .forEach((ParsedInputInterceptor inp) {
          if (!interceptorsAlreadyDefined.containsKey(inp.genName)) {
            throw new GeneratorException(
                '', 0, 'The interceptor ${inp.genName} is not defined yet!');
          }
        });
      });

      interceptorsAlreadyDefined[inter.resultName] = true;
    }
  }
}
