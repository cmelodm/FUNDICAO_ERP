import 'package:flutter/material.dart';

/// Enum de Módulos do Sistema
enum Modulo {
  dashboard,
  producao,
  materiais,
  ligas,
  gestao,
  usuarios,
  relatorios,
  qualidade,
  financeiro,
  fornecedores,
}

extension ModuloExtension on Modulo {
  String get nome {
    switch (this) {
      case Modulo.dashboard:
        return 'Dashboard';
      case Modulo.producao:
        return 'Produção';
      case Modulo.materiais:
        return 'Materiais';
      case Modulo.ligas:
        return 'Ligas';
      case Modulo.gestao:
        return 'Gestão';
      case Modulo.usuarios:
        return 'Usuários';
      case Modulo.relatorios:
        return 'Relatórios';
      case Modulo.qualidade:
        return 'Qualidade';
      case Modulo.financeiro:
        return 'Financeiro';
      case Modulo.fornecedores:
        return 'Fornecedores';
    }
  }

  IconData get icone {
    switch (this) {
      case Modulo.dashboard:
        return Icons.dashboard;
      case Modulo.producao:
        return Icons.factory;
      case Modulo.materiais:
        return Icons.inventory;
      case Modulo.ligas:
        return Icons.science;
      case Modulo.gestao:
        return Icons.business;
      case Modulo.usuarios:
        return Icons.people;
      case Modulo.relatorios:
        return Icons.analytics;
      case Modulo.qualidade:
        return Icons.verified;
      case Modulo.financeiro:
        return Icons.attach_money;
      case Modulo.fornecedores:
        return Icons.local_shipping;
    }
  }
}

/// Enum de Ações/Permissões
enum Acao {
  visualizar,
  criar,
  editar,
  excluir,
  exportar,
  aprovar,
  gerenciar,
}

extension AcaoExtension on Acao {
  String get nome {
    switch (this) {
      case Acao.visualizar:
        return 'Visualizar';
      case Acao.criar:
        return 'Criar';
      case Acao.editar:
        return 'Editar';
      case Acao.excluir:
        return 'Excluir';
      case Acao.exportar:
        return 'Exportar';
      case Acao.aprovar:
        return 'Aprovar';
      case Acao.gerenciar:
        return 'Gerenciar';
    }
  }

  IconData get icone {
    switch (this) {
      case Acao.visualizar:
        return Icons.visibility;
      case Acao.criar:
        return Icons.add_circle;
      case Acao.editar:
        return Icons.edit;
      case Acao.excluir:
        return Icons.delete;
      case Acao.exportar:
        return Icons.download;
      case Acao.aprovar:
        return Icons.check_circle;
      case Acao.gerenciar:
        return Icons.settings;
    }
  }
}

/// Modelo de Permissão
class Permissao {
  final String id;
  final Modulo modulo;
  final Acao acao;
  final String descricao;

  Permissao({
    required this.id,
    required this.modulo,
    required this.acao,
    required this.descricao,
  });

  /// Gera ID único da permissão
  String get chave => '${modulo.name}_${acao.name}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'modulo': modulo.name,
      'acao': acao.name,
      'descricao': descricao,
    };
  }

  factory Permissao.fromMap(Map<String, dynamic> map) {
    return Permissao(
      id: map['id'] as String,
      modulo: Modulo.values.firstWhere((m) => m.name == map['modulo']),
      acao: Acao.values.firstWhere((a) => a.name == map['acao']),
      descricao: map['descricao'] as String,
    );
  }
}

/// Enum de Papéis/Roles do Sistema
enum Role {
  administrador,
  gerente,
  supervisor,
  operador,
  visualizador,
}

extension RoleExtension on Role {
  String get nome {
    switch (this) {
      case Role.administrador:
        return 'Administrador';
      case Role.gerente:
        return 'Gerente';
      case Role.supervisor:
        return 'Supervisor';
      case Role.operador:
        return 'Operador';
      case Role.visualizador:
        return 'Visualizador';
    }
  }

  String get descricao {
    switch (this) {
      case Role.administrador:
        return 'Acesso total ao sistema, pode gerenciar usuários e permissões';
      case Role.gerente:
        return 'Acesso a gestão, relatórios e aprovações';
      case Role.supervisor:
        return 'Acesso a produção, qualidade e operações';
      case Role.operador:
        return 'Acesso limitado à produção e operações básicas';
      case Role.visualizador:
        return 'Apenas leitura, sem permissão para modificar dados';
    }
  }

  Color get cor {
    switch (this) {
      case Role.administrador:
        return Colors.red;
      case Role.gerente:
        return Colors.purple;
      case Role.supervisor:
        return Colors.blue;
      case Role.operador:
        return Colors.green;
      case Role.visualizador:
        return Colors.grey;
    }
  }

  IconData get icone {
    switch (this) {
      case Role.administrador:
        return Icons.admin_panel_settings;
      case Role.gerente:
        return Icons.business_center;
      case Role.supervisor:
        return Icons.supervisor_account;
      case Role.operador:
        return Icons.engineering;
      case Role.visualizador:
        return Icons.visibility;
    }
  }

  int get nivel {
    switch (this) {
      case Role.administrador:
        return 5;
      case Role.gerente:
        return 4;
      case Role.supervisor:
        return 3;
      case Role.operador:
        return 2;
      case Role.visualizador:
        return 1;
    }
  }

  /// Retorna as permissões padrão para cada role
  List<String> get permissoesPadrao {
    switch (this) {
      case Role.administrador:
        // Acesso total a tudo
        return [
          'dashboard_visualizar',
          'producao_visualizar', 'producao_criar', 'producao_editar', 'producao_excluir', 'producao_gerenciar',
          'materiais_visualizar', 'materiais_criar', 'materiais_editar', 'materiais_excluir',
          'ligas_visualizar', 'ligas_criar', 'ligas_editar', 'ligas_excluir',
          'gestao_visualizar', 'gestao_criar', 'gestao_editar', 'gestao_excluir', 'gestao_gerenciar',
          'usuarios_visualizar', 'usuarios_criar', 'usuarios_editar', 'usuarios_excluir', 'usuarios_gerenciar',
          'relatorios_visualizar', 'relatorios_exportar',
          'qualidade_visualizar', 'qualidade_criar', 'qualidade_editar', 'qualidade_aprovar',
          'financeiro_visualizar', 'financeiro_criar', 'financeiro_editar', 'financeiro_aprovar',
          'fornecedores_visualizar', 'fornecedores_criar', 'fornecedores_editar', 'fornecedores_excluir',
        ];
      
      case Role.gerente:
        return [
          'dashboard_visualizar',
          'producao_visualizar', 'producao_criar', 'producao_editar', 'producao_aprovar',
          'materiais_visualizar', 'materiais_criar', 'materiais_editar',
          'ligas_visualizar', 'ligas_criar', 'ligas_editar',
          'gestao_visualizar', 'gestao_criar', 'gestao_editar',
          'usuarios_visualizar',
          'relatorios_visualizar', 'relatorios_exportar',
          'qualidade_visualizar', 'qualidade_aprovar',
          'financeiro_visualizar', 'financeiro_criar', 'financeiro_editar',
          'fornecedores_visualizar', 'fornecedores_criar', 'fornecedores_editar',
        ];
      
      case Role.supervisor:
        return [
          'dashboard_visualizar',
          'producao_visualizar', 'producao_criar', 'producao_editar',
          'materiais_visualizar', 'materiais_criar', 'materiais_editar',
          'ligas_visualizar',
          'gestao_visualizar',
          'relatorios_visualizar', 'relatorios_exportar',
          'qualidade_visualizar', 'qualidade_criar', 'qualidade_editar',
          'fornecedores_visualizar',
        ];
      
      case Role.operador:
        return [
          'dashboard_visualizar',
          'producao_visualizar', 'producao_editar',
          'materiais_visualizar',
          'ligas_visualizar',
          'qualidade_visualizar', 'qualidade_criar',
        ];
      
      case Role.visualizador:
        return [
          'dashboard_visualizar',
          'producao_visualizar',
          'materiais_visualizar',
          'ligas_visualizar',
          'gestao_visualizar',
          'relatorios_visualizar',
          'qualidade_visualizar',
        ];
    }
  }
}

/// Modelo de Papel/Role
class RoleModel {
  final String id;
  final Role role;
  final List<String> permissoes;
  final bool ativo;

  RoleModel({
    required this.id,
    required this.role,
    required this.permissoes,
    this.ativo = true,
  });

  /// Verifica se tem uma permissão específica
  bool temPermissao(String chavePermissao) {
    return permissoes.contains(chavePermissao);
  }

  /// Verifica se pode acessar um módulo
  bool podeAcessarModulo(Modulo modulo) {
    return permissoes.any((p) => p.startsWith('${modulo.name}_'));
  }

  /// Verifica se pode executar uma ação em um módulo
  bool podeExecutar(Modulo modulo, Acao acao) {
    final chave = '${modulo.name}_${acao.name}';
    return permissoes.contains(chave);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role.name,
      'permissoes': permissoes,
      'ativo': ativo,
    };
  }

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      id: map['id'] as String,
      role: Role.values.firstWhere((r) => r.name == map['role']),
      permissoes: List<String>.from(map['permissoes'] as List),
      ativo: map['ativo'] as bool? ?? true,
    );
  }

  RoleModel copyWith({
    String? id,
    Role? role,
    List<String>? permissoes,
    bool? ativo,
  }) {
    return RoleModel(
      id: id ?? this.id,
      role: role ?? this.role,
      permissoes: permissoes ?? this.permissoes,
      ativo: ativo ?? this.ativo,
    );
  }
}
