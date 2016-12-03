part of jaguar_generator.writer;

class InterceptorPreWriter extends Object with GenInputs {
  final Route _r;

  final Interceptor _i;

  InterceptorPreWriter(this._r, this._i);

  InterceptorPre get _p => _i.pre;

  List<Input> get _inputs => _p.inputs;

  String generate() {
    StringBuffer sb = new StringBuffer();

    InterceptorCreateWriter writer = new InterceptorCreateWriter(_r, _i);
    sb.write(writer.generate());

    if (_p is! InterceptorPre) {
      return sb.toString();
    }

    if (!_p.isVoid && _p.isResultUseful) {
      sb.write('${_p.returnType} ${_i.genReturnVarName} = ');
    }

    if (_p.isAsync) {
      sb.write("await ");
    }

    sb.write('${_i.genInstanceName}.pre(');

    if (_p.needsHttpRequest) {
      sb.write("request, ");
    }

    sb.write(_genInputs);

    sb.writeln(");");

    return sb.toString();
  }
}
