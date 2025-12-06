enum NivelAcesso {
  admin,       // Acesso total ao sistema
  gerente,     // Acesso a relatórios e gestão (sem configurações críticas)
  operador,    // Acesso às operações diárias (produção, materiais, qualidade)
  visualizador // Apenas visualização (sem edição)
}

class UsuarioModel {
  final String id;
  final String nome;
  final String email;
  final String senha; // Em produção, usar hash bcrypt
  final NivelAcesso nivelAcesso;
  final String? telefone;
  final String? cargo;
  final String? setor;
  final bool ativo;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.nivelAcesso,
    this.telefone,
    this.cargo,
    this.setor,
    this.ativo = true,
    required this.createdAt,
    this.lastLogin,
  });

  // Getters auxiliares
  String get nivelAcessoTexto {
    switch (nivelAcesso) {
      case NivelAcesso.admin:
        return 'Administrador';
      case NivelAcesso.gerente:
        return 'Gerente';
      case NivelAcesso.operador:
        return 'Operador';
      case NivelAcesso.visualizador:
        return 'Visualizador';
    }
  }

  String get nivelAcessoDescricao {
    switch (nivelAcesso) {
      case NivelAcesso.admin:
        return 'Acesso total ao sistema';
      case NivelAcesso.gerente:
        return 'Gestão e relatórios';
      case NivelAcesso.operador:
        return 'Operações diárias';
      case NivelAcesso.visualizador:
        return 'Apenas visualização';
    }
  }

  // Permissões por módulo
  bool podeEditar() {
    return nivelAcesso != NivelAcesso.visualizador;
  }

  bool podeExcluir() {
    return nivelAcesso == NivelAcesso.admin || nivelAcesso == NivelAcesso.gerente;
  }

  bool podeAcessarConfiguracoes() {
    return nivelAcesso == NivelAcesso.admin;
  }

  bool podeGerenciarUsuarios() {
    return nivelAcesso == NivelAcesso.admin;
  }

  bool podeAprovarOrdens() {
    return nivelAcesso == NivelAcesso.admin || nivelAcesso == NivelAcesso.gerente;
  }

  bool podeEmitirNotasFiscais() {
    return nivelAcesso == NivelAcesso.admin || 
           nivelAcesso == NivelAcesso.gerente || 
           nivelAcesso == NivelAcesso.operador;
  }

  bool podeAcessarRelatorios() {
    return true; // Todos podem acessar relatórios
  }

  bool podeEditarMateriais() {
    return nivelAcesso != NivelAcesso.visualizador;
  }

  bool podeEditarProducao() {
    return nivelAcesso != NivelAcesso.visualizador;
  }

  bool podeEditarFornecedores() {
    return nivelAcesso == NivelAcesso.admin || nivelAcesso == NivelAcesso.gerente;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'nivelAcesso': nivelAcesso.index,
      'telefone': telefone,
      'cargo': cargo,
      'setor': setor,
      'ativo': ativo,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String,
      nivelAcesso: NivelAcesso.values[map['nivelAcesso'] as int],
      telefone: map['telefone'] as String?,
      cargo: map['cargo'] as String?,
      setor: map['setor'] as String?,
      ativo: map['ativo'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'] as String)
          : null,
    );
  }

  // Criar cópia com alterações
  UsuarioModel copyWith({
    String? id,
    String? nome,
    String? email,
    String? senha,
    NivelAcesso? nivelAcesso,
    String? telefone,
    String? cargo,
    String? setor,
    bool? ativo,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      nivelAcesso: nivelAcesso ?? this.nivelAcesso,
      telefone: telefone ?? this.telefone,
      cargo: cargo ?? this.cargo,
      setor: setor ?? this.setor,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

// Serviço de autenticação
class AuthService {
  UsuarioModel? _usuarioLogado;

  UsuarioModel? get usuarioLogado => _usuarioLogado;
  bool get estaAutenticado => _usuarioLogado != null;

  Future<bool> login(String email, String senha, List<UsuarioModel> usuarios) async {
    try {
      final usuario = usuarios.firstWhere(
        (u) => u.email == email && u.senha == senha && u.ativo,
      );
      _usuarioLogado = usuario.copyWith(lastLogin: DateTime.now());
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _usuarioLogado = null;
  }

  bool temPermissao(Function(UsuarioModel) verificacao) {
    if (_usuarioLogado == null) return false;
    return verificacao(_usuarioLogado!);
  }
}
