part of jaguar_generator.models;

class InterceptorRequiredParam {
  final String source;

  InterceptorRequiredParam(this.source);
}

abstract class InterceptorNamedParam {
  String get key;
}

class InterceptorNamedParamProvided implements InterceptorNamedParam {
  final String key;

  final String type;

  final List<Input> inputs;

  InterceptorNamedParamProvided(this.key, this.type, this.inputs);
}

class InterceptorNamedParamState implements InterceptorNamedParam {
  String get key => 'state';

  InterceptorNamedParamState();
}
