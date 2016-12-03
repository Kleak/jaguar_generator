part of jaguar_generator.models;

class InjectedParam {
  DartTypeWrap type;

  DartTypeWrap injector;

  String id;

  String get injectedString => 'r' + injector.name + id ?? '';
}
