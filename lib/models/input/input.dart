part of jaguar_generator.models;

abstract class Input {
  String get writeVal;
}

class InputInterceptor implements Input {
  final String id;

  final String type;

  String get writeVal => 'r$type' + (id ?? '');

  const InputInterceptor(this.id, this.type);
}

class InputCookie implements Input {
  final String key;

  const InputCookie(this.key);

  String get writeVal =>
      "request.cookies.firstWhere((cookie) => cookie.name == '$key', orElse: () => null)?.value";
}

class InputCookies implements Input {
  const InputCookies();

  String get writeVal => "request.cookies";
}

class InputHeader implements Input {
  final String key;

  const InputHeader(this.key);

  String get writeVal => "request.headers.value('$key')";
}

class InputHeaders implements Input {
  const InputHeaders();

  String get writeVal => "request.headers";
}

class InputPathParams implements Input {
  final String type;

  const InputPathParams(this.type);

  String get writeVal => 'new $type.FromPathParam(pathParams)';
}

class InputQueryParams implements Input {
  final String type;

  const InputQueryParams(this.type);

  String get writeVal => 'new $type.FromQueryParam(queryParams)';
}

class InputRouteResponse implements Input {
  int respIndex = 0;

  InputRouteResponse([this.respIndex = 0]);

  String get writeVal => 'rRouteResponse${respIndex}';
}
