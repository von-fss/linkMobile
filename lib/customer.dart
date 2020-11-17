import 'package:uuid/uuid.dart';

class Customer {
  final String id;
  final String nome;
  final int cpf;
  final String tipoPessoa;
  final int v;
  Customer.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        nome = json['nome'],
        cpf = json['cpf'],
        tipoPessoa = json['tipoPessoa'],
        v = json['__v'];
}
