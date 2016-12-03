part of jaguar_generator.models;

class ExceptionHandler {
  final String exceptionName;

  final String handlerName;

  final String _instantiationString;

  String get instantiationString => 'new ' + _instantiationString;

  final bool isAsync;

  ExceptionHandler(this.exceptionName, this.handlerName,
      this._instantiationString, this.isAsync);
}
