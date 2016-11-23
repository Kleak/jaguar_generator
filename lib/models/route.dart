part of jaguar_generator.models;

class RouteItem {
  String name;

  String writeValue;
}

class RoutePrototype {
  String writeValue;
}

class RouteParams {}

class RouteMethod {
  String name;

  String returnType;

  List<RouteParams> required;

  List<RouteParams> optional;
}

class Route {
  RouteItem item;

  RoutePrototype prototype;

  RouteMethod method;

  List<Interceptor> interceptors;
}

class Upper {
  String name;

  List<Route> routes;

  List<Group> groups;
}

class Group {
  String type;

  String name;
}