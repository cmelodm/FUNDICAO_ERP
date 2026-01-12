import 'permissao_model.dart';

// Enum de compatibilidade com código antigo
enum NivelAcesso {
  admin,
  gerente,
  operador,
  visualizador,
}

extension NivelAcessoExtension on NivelAcesso {
  Role toRole() {
    switch (this) {
      case NivelAcesso.admin:
        return Role.administrador;
      case NivelAcesso.gerente:
        return Role.gerente;
      case NivelAcesso.operador:
        return Role.operador;
      case NivelAcesso.visualizador:
        return Role.visualizador;
    }
  }

  String get texto {
    switch (this) {
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
  final String? avatar;
  final bool ativo;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? criadoPor;
  final String? ultimaAtualizacao;

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.nivelAcesso,
    this.telefone,
    this.cargo,
    this.setor,
    this.avatar,
    this.ativo = true,
    required this.createdAt,
    this.lastLogin,
    this.criadoPor,
    this.ultimaAtualizacao,
  });

  // Getters de compatibilidade
  Role get role => nivelAcesso.toRole();
  
  RoleModel get roleModel => RoleModel(
    id: role.name,
    role: role,
    permissoes: role.permissoesPadrao,
    ativo: true,
  );

  // Getters auxiliares
  String get nomeRole => role.nome;
  String get descricaoRole => role.descricao;
  String get nivelAcessoTexto => nivelAcesso.texto;

  /// Verifica se tem uma permissão específica
  bool temPermissao(String chavePermissao) {
    return roleModel.temPermissao(chavePermissao);
  }

  /// Verifica se pode acessar um módulo
  bool podeAcessarModulo(Modulo modulo) {
    return roleModel.podeAcessarModulo(modulo);
  }

  /// Verifica se pode executar uma ação em um módulo
  bool podeExecutar(Modulo modulo, Acao acao) {
    return roleModel.podeExecutar(modulo, acao);
  }

  // Permissões específicas (wrappers para facilitar uso)
  bool get podeVisualizarDashboard => podeExecutar(Modulo.dashboard, Acao.visualizar);
  
  bool get podeVisualizarProducao => podeExecutar(Modulo.producao, Acao.visualizar);
  bool get podeCriarProducao => podeExecutar(Modulo.producao, Acao.criar);
  bool get podeEditarProducao => podeExecutar(Modulo.producao, Acao.editar);
  bool get podeExcluirProducao => podeExecutar(Modulo.producao, Acao.excluir);
  bool get podeGerenciarProducao => podeExecutar(Modulo.producao, Acao.gerenciar);
  
  bool get podeVisualizarMateriais => podeExecutar(Modulo.materiais, Acao.visualizar);
  bool get podeCriarMateriais => podeExecutar(Modulo.materiais, Acao.criar);
  bool get podeEditarMateriais => podeExecutar(Modulo.materiais, Acao.editar);
  bool get podeExcluirMateriais => podeExecutar(Modulo.materiais, Acao.excluir);
  
  bool get podeVisualizarLigas => podeExecutar(Modulo.ligas, Acao.visualizar);
  bool get podeCriarLigas => podeExecutar(Modulo.ligas, Acao.criar);
  bool get podeEditarLigas => podeExecutar(Modulo.ligas, Acao.editar);
  bool get podeExcluirLigas => podeExecutar(Modulo.ligas, Acao.excluir);
  
  bool get podeVisualizarGestao => podeExecutar(Modulo.gestao, Acao.visualizar);
  bool get podeCriarGestao => podeExecutar(Modulo.gestao, Acao.criar);
  bool get podeEditarGestao => podeExecutar(Modulo.gestao, Acao.editar);
  bool get podeGerenciarGestao => podeExecutar(Modulo.gestao, Acao.gerenciar);
  
  bool get podeVisualizarUsuarios => podeExecutar(Modulo.usuarios, Acao.visualizar);
  bool get podeCriarUsuarios => podeExecutar(Modulo.usuarios, Acao.criar);
  bool get podeEditarUsuarios => podeExecutar(Modulo.usuarios, Acao.editar);
  bool get podeExcluirUsuarios => podeExecutar(Modulo.usuarios, Acao.excluir);
  bool get podeGerenciarUsuarios => podeExecutar(Modulo.usuarios, Acao.gerenciar);
  
  bool get podeVisualizarRelatorios => podeExecutar(Modulo.relatorios, Acao.visualizar);
  bool get podeExportarRelatorios => podeExecutar(Modulo.relatorios, Acao.exportar);
  
  bool get podeVisualizarQualidade => podeExecutar(Modulo.qualidade, Acao.visualizar);
  bool get podeCriarQualidade => podeExecutar(Modulo.qualidade, Acao.criar);
  bool get podeEditarQualidade => podeExecutar(Modulo.qualidade, Acao.editar);
  bool get podeAprovarQualidade => podeExecutar(Modulo.qualidade, Acao.aprovar);
  
  bool get podeVisualizarFinanceiro => podeExecutar(Modulo.financeiro, Acao.visualizar);
  bool get podeCriarFinanceiro => podeExecutar(Modulo.financeiro, Acao.criar);
  bool get podeEditarFinanceiro => podeExecutar(Modulo.financeiro, Acao.editar);
  bool get podeAprovarFinanceiro => podeExecutar(Modulo.financeiro, Acao.aprovar);
  
  bool get podeVisualizarFornecedores => podeExecutar(Modulo.fornecedores, Acao.visualizar);
  bool get podeCriarFornecedores => podeExecutar(Modulo.fornecedores, Acao.criar);
  bool get podeEditarFornecedores => podeExecutar(Modulo.fornecedores, Acao.editar);
  bool get podeExcluirFornecedores => podeExecutar(Modulo.fornecedores, Acao.excluir);

  // Atalhos para verificações específicas
  bool get isAdmin => nivelAcesso == NivelAcesso.admin;
  bool get isGerente => nivelAcesso == NivelAcesso.gerente;
  bool get isOperador => nivelAcesso == NivelAcesso.operador;
  bool get isVisualizador => nivelAcesso == NivelAcesso.visualizador;

  UsuarioModel copyWith({
    String? id,
    String? nome,
    String? email,
    String? senha,
    NivelAcesso? nivelAcesso,
    String? telefone,
    String? cargo,
    String? setor,
    String? avatar,
    bool? ativo,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? criadoPor,
    String? ultimaAtualizacao,
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
      avatar: avatar ?? this.avatar,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      criadoPor: criadoPor ?? this.criadoPor,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'nivelAcesso': nivelAcesso.name,
      'telefone': telefone,
      'cargo': cargo,
      'setor': setor,
      'avatar': avatar,
      'ativo': ativo,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'criadoPor': criadoPor,
      'ultimaAtualizacao': ultimaAtualizacao,
    };
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String,
      nivelAcesso: NivelAcesso.values.firstWhere(
        (e) => e.name == map['nivelAcesso'],
        orElse: () => NivelAcesso.visualizador,
      ),
      telefone: map['telefone'] as String?,
      cargo: map['cargo'] as String?,
      setor: map['setor'] as String?,
      avatar: map['avatar'] as String?,
      ativo: map['ativo'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'] as String)
          : null,
      criadoPor: map['criadoPor'] as String?,
      ultimaAtualizacao: map['ultimaAtualizacao'] as String?,
    );
  }
}

/// Serviço de Autenticação Simples (em memória)
class AuthService {
  UsuarioModel? _usuarioLogado;

  UsuarioModel? get usuarioLogado => _usuarioLogado;
  bool get isAuthenticated => _usuarioLogado != null;

  Future<bool> login(String email, String senha, List<UsuarioModel> usuarios) async {
    // Em produção, fazer requisição à API
    // Por enquanto, buscar no usuário na lista
    try {
      final usuario = usuarios.firstWhere(
        (u) => u.email == email && u.senha == senha && u.ativo,
      );
      
      // Atualizar lastLogin
      _usuarioLogado = usuario.copyWith(lastLogin: DateTime.now());
      return true;
    } catch (e) {
      return false;
    }
  }

  void setUsuarioLogado(UsuarioModel usuario) {
    _usuarioLogado = usuario;
  }

  void logout() {
    _usuarioLogado = null;
  }

  bool temPermissao(String permissao) {
    if (_usuarioLogado == null) return false;
    return _usuarioLogado!.temPermissao(permissao);
  }

  bool podeAcessarModulo(Modulo modulo) {
    if (_usuarioLogado == null) return false;
    return _usuarioLogado!.podeAcessarModulo(modulo);
  }
}
