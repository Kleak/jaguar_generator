import 'package:jaguar_generator/models/models.dart';

class Writer {
  Upper _u;

  List<Route> get _r => _u.routes;

  List<Group> get _g => _u.groups;

  String generate() {
    StringBuffer sb = new StringBuffer();
    sb.writeln(
        "abstract class _\$Jaguar${_u.name} implements RequestHandler {");

    sb.writeln(_writeRouteList());

    sb.writeln(_writeGroupDecl());

    sb.writeln(_writeRoutePrototype());

    sb.writeln(_writeReqHandler());

    sb.writeln('}');

    return sb.toString();
  }

  String _writeRouteList() {
    StringBuffer sb = new StringBuffer();

    sb.writeln("static const List<RouteBase> routes = const <RouteBase>[");
    String routeList = _r.map((Route route) => route.item.writeValue).join(',');
    sb.write(routeList);
    sb.writeln("];");

    return sb.toString();
  }

  String _writeGroupDecl() {
    StringBuffer sb = new StringBuffer();

    _g.forEach((Group group) {
      sb.writeln('${group.type} get ${group.name};');
    });

    return sb.toString();
  }

  String _writeRoutePrototype() {
    StringBuffer sb = new StringBuffer();

    _r.forEach((Route route) {
      sb.writeln(route.prototype.writeValue);
    });

    return sb.toString();
  }

  String _writeReqHandler() {
    StringBuffer sb = new StringBuffer();

    //TODO

    return sb.toString();
  }
}
