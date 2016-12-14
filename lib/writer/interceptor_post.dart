part of jaguar_generator.writer;

class InterceptorPostWriter extends Object with GenInputs {
  final Route _r;

  final Interceptor _i;

  InterceptorPostWriter(this._r, this._i);

  InterceptorPost get _p => _i.post;

  List<Input> get _inputs => _p.inputs;

  String generate() {
    if (_p is! InterceptorPost) {
      return '';
    }

    StringBuffer sb = new StringBuffer();

    if (_p.returnsResponse) {
      sb.write(
          "Response<${_p.jaguarResponseType}> rRouteResponse${_p.respIndex} = ");
    }

    if (_p.isAsync) {
      sb.write("await ");
    }

    sb.write("${_i.genInstanceName}.post(");

    if (_p.needsHttpRequest) {
      sb.write("request, ");
    }

    sb.write(_genInputs);

    sb.writeln(");");

    return sb.toString();
  }
}
