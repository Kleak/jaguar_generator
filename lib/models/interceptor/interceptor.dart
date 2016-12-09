part of jaguar_generator.models;

class InterceptorCreator {
  final String name;

  final List<InterceptorRequiredParam> required;

  final List<InterceptorNamedParam> optional;

  InterceptorCreator(this.name, this.required, this.optional);
}

class InterceptorPre {
  bool needsHttpRequest;

  String returnType;

  bool isAsync;

  bool isVoid;

  bool isResultUseful;

  List<Input> inputs;
}

class InterceptorPost {
  bool needsHttpRequest;

  bool returnsResponse;

  bool isAsync;

  List<Input> inputs;
}

class Interceptor {
  String name;

  String id;

  InterceptorCreator creator;

  InterceptorPre pre;

  InterceptorPost post;

  Interceptor();

  String get _genBaseName => name + (id ?? '');

  String get genInstanceName => 'i$_genBaseName';

  String get genReturnVarName => 'r$_genBaseName';
}
