/// Method model
class MethodType {
  const MethodType(this.methodName);

  final String methodName;
}

class Method {
  Method({
    required this.type,
    required this.id,
    required this.title,
  });

  String type;
  String id;
  String title;
}

class IV extends Method {
  IV(id, title) : super(type: 'IV', id: id, title: title);
}

class EIS extends Method {
  EIS(id, title) : super(type: 'EIS', id: id, title: title);
}

class Pulse extends Method {
  Pulse(id, title) : super(type: 'Pulse', id: id, title: title);
}

class Battery extends Method {
  Battery(id, title) : super(type: 'Battery', id: id, title: title);
}
