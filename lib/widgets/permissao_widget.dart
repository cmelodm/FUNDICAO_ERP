import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../models/permissao_model.dart';
import '../services/data_service.dart';

/// Widget que controla visibilidade baseado em permissões
class PermissaoWidget extends StatelessWidget {
  final Widget child;
  final String? permissaoRequerida;
  final Modulo? modulo;
  final Acao? acao;
  final bool Function(UsuarioModel)? verificacaoCustomizada;
  final Widget? fallback;

  const PermissaoWidget({
    super.key,
    required this.child,
    this.permissaoRequerida,
    this.modulo,
    this.acao,
    this.verificacaoCustomizada,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final dataService = DataService();
    final usuario = dataService.authService.usuarioLogado;

    if (usuario == null) {
      return fallback ?? const SizedBox.shrink();
    }

    bool temPermissao = false;

    // Verificação customizada tem prioridade
    if (verificacaoCustomizada != null) {
      temPermissao = verificacaoCustomizada!(usuario);
    }
    // Verificação por chave de permissão
    else if (permissaoRequerida != null) {
      temPermissao = usuario.temPermissao(permissaoRequerida!);
    }
    // Verificação por módulo e ação
    else if (modulo != null && acao != null) {
      temPermissao = usuario.podeExecutar(modulo!, acao!);
    }
    // Se nenhuma verificação foi especificada, mostra o widget
    else {
      temPermissao = true;
    }

    return temPermissao ? child : (fallback ?? const SizedBox.shrink());
  }
}

/// Widget que desabilita ações baseado em permissões
class BotaoComPermissao extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? permissaoRequerida;
  final Modulo? modulo;
  final Acao? acao;
  final bool Function(UsuarioModel)? verificacaoCustomizada;
  final String? mensagemSemPermissao;
  final ButtonStyle? style;
  final bool showTooltip;

  const BotaoComPermissao({
    super.key,
    required this.onPressed,
    required this.child,
    this.permissaoRequerida,
    this.modulo,
    this.acao,
    this.verificacaoCustomizada,
    this.mensagemSemPermissao,
    this.style,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    final dataService = DataService();
    final usuario = dataService.authService.usuarioLogado;

    if (usuario == null) {
      return ElevatedButton(
        onPressed: null,
        style: style,
        child: child,
      );
    }

    bool temPermissao = false;

    if (verificacaoCustomizada != null) {
      temPermissao = verificacaoCustomizada!(usuario);
    } else if (permissaoRequerida != null) {
      temPermissao = usuario.temPermissao(permissaoRequerida!);
    } else if (modulo != null && acao != null) {
      temPermissao = usuario.podeExecutar(modulo!, acao!);
    } else {
      temPermissao = true;
    }

    final button = ElevatedButton(
      onPressed: temPermissao ? onPressed : null,
      style: style,
      child: child,
    );

    if (!temPermissao && showTooltip && mensagemSemPermissao != null) {
      return Tooltip(
        message: mensagemSemPermissao!,
        child: button,
      );
    }

    return button;
  }
}

/// Widget que mostra mensagem de acesso negado
class AcessoNegadoWidget extends StatelessWidget {
  final String? titulo;
  final String? mensagem;
  final IconData? icone;

  const AcessoNegadoWidget({
    super.key,
    this.titulo,
    this.mensagem,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icone ?? Icons.lock,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            titulo ?? 'Acesso Negado',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              mensagem ?? 'Você não tem permissão para acessar esta área',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar'),
          ),
        ],
      ),
    );
  }
}

/// Widget wrapper para proteger telas inteiras
class TelaProtegida extends StatelessWidget {
  final Widget child;
  final String? permissaoRequerida;
  final Modulo? modulo;
  final bool Function(UsuarioModel)? verificacaoCustomizada;
  final String? tituloAcessoNegado;
  final String? mensagemAcessoNegado;

  const TelaProtegida({
    super.key,
    required this.child,
    this.permissaoRequerida,
    this.modulo,
    this.verificacaoCustomizada,
    this.tituloAcessoNegado,
    this.mensagemAcessoNegado,
  });

  @override
  Widget build(BuildContext context) {
    final dataService = DataService();
    final usuario = dataService.authService.usuarioLogado;

    if (usuario == null) {
      return AcessoNegadoWidget(
        titulo: 'Não Autenticado',
        mensagem: 'Você precisa fazer login para acessar esta área',
      );
    }

    bool temPermissao = false;

    if (verificacaoCustomizada != null) {
      temPermissao = verificacaoCustomizada!(usuario);
    } else if (permissaoRequerida != null) {
      temPermissao = usuario.temPermissao(permissaoRequerida!);
    } else if (modulo != null) {
      temPermissao = usuario.podeAcessarModulo(modulo!);
    } else {
      temPermissao = true;
    }

    if (!temPermissao) {
      return AcessoNegadoWidget(
        titulo: tituloAcessoNegado,
        mensagem: mensagemAcessoNegado,
      );
    }

    return child;
  }
}

/// Badge que mostra o perfil do usuário
class PerfilBadge extends StatelessWidget {
  final UsuarioModel usuario;
  final bool showNome;
  final bool showRole;
  final double? size;

  const PerfilBadge({
    super.key,
    required this.usuario,
    this.showNome = true,
    this.showRole = true,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = size ?? 40;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: avatarSize / 2,
          backgroundColor: usuario.role.cor.withValues(alpha: 0.2),
          child: Text(
            usuario.nome.substring(0, 1).toUpperCase(),
            style: TextStyle(
              fontSize: avatarSize / 2,
              fontWeight: FontWeight.bold,
              color: usuario.role.cor,
            ),
          ),
        ),
        if (showNome || showRole) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showNome)
                Text(
                  usuario.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              if (showRole)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: usuario.role.cor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    usuario.role.nome,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: usuario.role.cor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
