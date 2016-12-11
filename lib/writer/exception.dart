part of jaguar_generator.writer;

class RouteExceptionWriter {
  final Route route;

  RouteExceptionWriter(this.route);

  String generate() {
    StringBuffer sb = new StringBuffer();

    for (ExceptionHandler exception in route.exceptions) {
      sb.writeln(' on ${exception.exceptionName} catch(e, s) {');
      sb.write(exception.handlerName + ' handler = ');
      sb.writeln(exception.instantiationString + ';');

      if (exception.isAsync) {
        sb.write('await ');
      }

      sb.writeln('handler.onRouteException(request, e, s);');

      sb.write('return true;');

      sb.writeln('}');
    }

    return sb.toString();
  }
}
