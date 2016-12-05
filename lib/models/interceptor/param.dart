part of jaguar_generator.models;

class InterceptorRequiredParam {
  final String source;

  InterceptorRequiredParam(this.source);
}

abstract class InterceptorNamedParam {
  String get key;
}

class InterceptorNamedMakeParamType implements InterceptorNamedParam {
  final String key;

  final String type;

  final List<Input> inputs;

  InterceptorNamedMakeParamType(this.key, this.type, this.inputs);
}

class InterceptorNamedMakeParamMethod implements InterceptorNamedParam {
  final String key;

  final String methodName;

  final bool isAsync;

  InterceptorNamedMakeParamMethod(this.key, this.methodName, this.isAsync);
}

class InterceptorNamedParamState implements InterceptorNamedParam {
  String get key => 'state';

  InterceptorNamedParamState();
}
