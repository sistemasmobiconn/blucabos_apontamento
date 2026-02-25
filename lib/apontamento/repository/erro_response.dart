class ErroResponse {
  ErroResponse({
    required this.erro,
  });

  factory ErroResponse.fromJson(Map<String, dynamic> json) {
    return ErroResponse(
      erro: Erro.fromJson(json['erro'] as Map<String, dynamic>),
    );
  }
  final Erro erro;

  Map<String, dynamic> toJson() {
    return {
      'erro': erro.toJson(),
    };
  }

  static bool isError(String body) {
    return body.contains('erro') &&
        body.contains('codigo') &&
        body.contains('mensagem');
  }
}

class Erro {
  Erro({
    required this.codigo,
    required this.mensagem,
  });

  factory Erro.fromJson(Map<String, dynamic> json) {
    return Erro(
      codigo: json['codigo'] as String,
      mensagem: json['mensagem'] as String,
    );
  }
  final String codigo;
  final String mensagem;

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'mensagem': mensagem,
    };
  }
}
