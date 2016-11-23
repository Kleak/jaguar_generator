part of jaguar_generator.models;

class SubParam {}

class InjectedSubParam implements SubParam {
  DartTypeWrap type;

  DartTypeWrap injector;

  String id;

  String get injectedString => 'r' + injector.name + id??'';
}