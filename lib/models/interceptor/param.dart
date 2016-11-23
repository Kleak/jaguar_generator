part of jaguar_generator.models;

abstract class InterceptorParam {}

class InterceptorParamInstantiatedConstructor {
  List<SubParam> required;

  List<SubParam> optional;

  InterceptorParamInstantiatedConstructor();
}

class InterceptorParamInstantiated implements InterceptorParam {
  DartTypeWrap type;

  InterceptorParamInstantiatedConstructor constructor;

  InterceptorParamInstantiated();
}

class InterceptorParamReproduced implements InterceptorParam {
  final String string;

  InterceptorParamReproduced(this.string);
}