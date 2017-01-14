part of jaguar_generator.models;

class InterceptorRequiredParam {
  final String source;
  final String key;

  InterceptorRequiredParam(this.key, this.source);

  bool get shouldMakeFromParam => source == "makeFromParams";
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

class InterceptorNamedMakeParamSettings implements InterceptorNamedParam {
  final String key;

  final String settingKey;

  final String defaultValue;

  final String filterStr;

  InterceptorNamedMakeParamSettings(
      this.key, this.settingKey, this.defaultValue, this.filterStr);
}
