// lib/screens/production_page.dart

class Operador {
  const Operador({
    required this.codEmpresa,
    required this.codOperador,
    required this.nomeOperador,
  });

  factory Operador.fromJson(Map<String, dynamic> json) {
    return Operador(
      codEmpresa: json['COD_EMPRESA'] as int,
      codOperador: json['COD_OPERADOR'] as int,
      nomeOperador: json['NOME_OPERADOR'] as String,
    );
  }

  final int codEmpresa;
  final int codOperador;
  final String nomeOperador;

  Map<String, dynamic> toJson() {
    return {
      'COD_EMPRESA': codEmpresa,
      'COD_OPERADOR': codOperador,
      'NOME_OPERADOR': nomeOperador,
    };
  }
}
