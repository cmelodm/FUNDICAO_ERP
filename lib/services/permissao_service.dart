import '../models/permissao_model.dart';
import '../models/usuario_model.dart';

/// Serviço para gerenciamento de permissões
class PermissaoService {
  /// Cria um RoleModel baseado em um Role
  static RoleModel criarRoleModel(Role role) {
    return RoleModel(
      id: role.name,
      role: role,
      permissoes: role.permissoesPadrao,
      ativo: true,
    );
  }

  /// Cria um usuário padrão com role específico
  static UsuarioModel criarUsuarioPadrao({
    required String id,
    required String nome,
    required String email,
    required String senha,
    required NivelAcesso nivelAcesso,
    String? cargo,
    String? setor,
  }) {
    return UsuarioModel(
      id: id,
      nome: nome,
      email: email,
      senha: senha, // Em produção, usar hash
      nivelAcesso: nivelAcesso,
      cargo: cargo,
      setor: setor,
      ativo: true,
      createdAt: DateTime.now(),
    );
  }

  /// Verifica se um usuário pode modificar outro usuário
  static bool podeModificarUsuario(UsuarioModel usuarioLogado, UsuarioModel usuarioAlvo) {
    // Administrador pode modificar qualquer um
    if (usuarioLogado.isAdmin) return true;
    
    // Não pode modificar usuários de nível superior ou igual
    if (usuarioAlvo.role.nivel >= usuarioLogado.role.nivel) return false;
    
    // Gerente pode modificar supervisor, operador e visualizador
    if (usuarioLogado.isGerente && 
        usuarioAlvo.role.nivel < Role.gerente.nivel) {
      return true;
    }
    
    return false;
  }

  /// Retorna a lista de roles que um usuário pode atribuir
  static List<Role> rolesDisponiveis(UsuarioModel usuarioLogado) {
    if (usuarioLogado.isAdmin) {
      // Administrador pode atribuir qualquer role
      return Role.values;
    }
    
    if (usuarioLogado.role == Role.gerente) {
      // Gerente pode atribuir roles inferiores
      return [Role.supervisor, Role.operador, Role.visualizador];
    }
    
    // Outros não podem criar usuários
    return [];
  }

  /// Verifica se ação requer confirmação adicional
  static bool requerConfirmacao(Modulo modulo, Acao acao) {
    // Ações de exclusão sempre requerem confirmação
    if (acao == Acao.excluir) return true;
    
    // Módulos críticos requerem confirmação para ações importantes
    final modulosCriticos = [Modulo.usuarios, Modulo.financeiro, Modulo.producao];
    if (modulosCriticos.contains(modulo) && 
        (acao == Acao.editar || acao == Acao.aprovar)) {
      return true;
    }
    
    return false;
  }

  /// Obtém descrição de uma permissão
  static String descricaoPermissao(String chavePermissao) {
    final partes = chavePermissao.split('_');
    if (partes.length != 2) return chavePermissao;
    
    try {
      final modulo = Modulo.values.firstWhere((m) => m.name == partes[0]);
      final acao = Acao.values.firstWhere((a) => a.name == partes[1]);
      return '${acao.nome} ${modulo.nome}';
    } catch (e) {
      return chavePermissao;
    }
  }

  /// Agrupa permissões por módulo
  static Map<Modulo, List<String>> agruparPermissoesPorModulo(List<String> permissoes) {
    final Map<Modulo, List<String>> grupos = {};
    
    for (final permissao in permissoes) {
      final partes = permissao.split('_');
      if (partes.length != 2) continue;
      
      try {
        final modulo = Modulo.values.firstWhere((m) => m.name == partes[0]);
        grupos[modulo] = grupos[modulo] ?? [];
        grupos[modulo]!.add(permissao);
      } catch (e) {
        // Ignora permissões inválidas
      }
    }
    
    return grupos;
  }

  /// Valida se conjunto de permissões é válido
  static bool validarPermissoes(List<String> permissoes) {
    for (final permissao in permissoes) {
      final partes = permissao.split('_');
      if (partes.length != 2) return false;
      
      try {
        Modulo.values.firstWhere((m) => m.name == partes[0]);
        Acao.values.firstWhere((a) => a.name == partes[1]);
      } catch (e) {
        return false;
      }
    }
    
    return true;
  }

  /// Gera log de auditoria para ação
  static String gerarLogAuditoria({
    required UsuarioModel usuario,
    required String acao,
    required String recurso,
    String? detalhes,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    return '[$timestamp] ${usuario.nome} (${usuario.email}) - $acao: $recurso${detalhes != null ? ' - $detalhes' : ''}';
  }
}
