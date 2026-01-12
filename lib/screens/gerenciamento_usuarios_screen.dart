import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/usuario_model.dart';
import '../models/permissao_model.dart';
import '../services/data_service.dart';
import '../services/permissao_service.dart';

class GerenciamentoUsuariosScreen extends StatefulWidget {
  const GerenciamentoUsuariosScreen({super.key});

  @override
  State<GerenciamentoUsuariosScreen> createState() => _GerenciamentoUsuariosScreenState();
}

class _GerenciamentoUsuariosScreenState extends State<GerenciamentoUsuariosScreen> {
  final DataService _dataService = DataService();
  String _filtroStatus = 'todos';
  NivelAcesso? _filtroNivel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UsuarioModel> get _usuariosFiltrados {
    var usuarios = _dataService.usuarios;

    // Filtro por status
    if (_filtroStatus == 'ativos') {
      usuarios = usuarios.where((u) => u.ativo).toList();
    } else if (_filtroStatus == 'inativos') {
      usuarios = usuarios.where((u) => !u.ativo).toList();
    }

    // Filtro por nível
    if (_filtroNivel != null) {
      usuarios = usuarios.where((u) => u.nivelAcesso == _filtroNivel).toList();
    }

    // Filtro por busca
    if (_searchController.text.isNotEmpty) {
      final busca = _searchController.text.toLowerCase();
      usuarios = usuarios.where((u) =>
        u.nome.toLowerCase().contains(busca) ||
        u.email.toLowerCase().contains(busca) ||
        (u.cargo?.toLowerCase().contains(busca) ?? false)
      ).toList();
    }

    return usuarios;
  }

  @override
  Widget build(BuildContext context) {
    final usuarioLogado = _dataService.authService.usuarioLogado;

    if (usuarioLogado == null || !usuarioLogado.podeVisualizarUsuarios) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Gerenciamento de Usuários'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Acesso Negado',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Você não tem permissão para acessar esta área',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Usuários'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de filtros e busca
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Campo de busca
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome, email ou cargo...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Filtros
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filtroStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'todos', child: Text('Todos')),
                          DropdownMenuItem(value: 'ativos', child: Text('Ativos')),
                          DropdownMenuItem(value: 'inativos', child: Text('Inativos')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filtroStatus = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<NivelAcesso?>(
                        value: _filtroNivel,
                        decoration: const InputDecoration(
                          labelText: 'Perfil',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos os perfis')),
                          ...NivelAcesso.values.map((nivel) => DropdownMenuItem(
                            value: nivel,
                            child: Row(
                              children: [
                                Icon(nivel.toRole().icone, size: 16, color: nivel.toRole().cor),
                                const SizedBox(width: 8),
                                Text(nivel.texto),
                              ],
                            ),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filtroNivel = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Estatísticas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _dataService.usuarios.length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Ativos',
                    _dataService.usuarios.where((u) => u.ativo).length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Inativos',
                    _dataService.usuarios.where((u) => !u.ativo).length.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Lista de usuários
          Expanded(
            child: _usuariosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum usuário encontrado',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _usuariosFiltrados.length,
                    itemBuilder: (context, index) {
                      return _buildUsuarioCard(_usuariosFiltrados[index], usuarioLogado);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: usuarioLogado.podeCriarUsuarios
          ? FloatingActionButton.extended(
              onPressed: () => _showNovoUsuarioDialog(usuarioLogado),
              icon: const Icon(Icons.person_add),
              label: const Text('Novo Usuário'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsuarioCard(UsuarioModel usuario, UsuarioModel usuarioLogado) {
    final podeModificar = PermissaoService.podeModificarUsuario(usuarioLogado, usuario);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: usuario.ativo ? usuario.role.cor.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showDetalhesUsuario(usuario, usuarioLogado),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: usuario.role.cor.withValues(alpha: 0.2),
                    child: Text(
                      usuario.nome.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: usuario.role.cor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Informações principais
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                usuario.nome,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!usuario.ativo)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'INATIVO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.email, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                usuario.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (usuario.cargo != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.work, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                usuario.cargo!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Role e ações
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: usuario.role.cor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(usuario.role.icone, size: 16, color: usuario.role.cor),
                          const SizedBox(width: 8),
                          Text(
                            usuario.role.nome,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: usuario.role.cor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (podeModificar) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditarUsuarioDialog(usuario, usuarioLogado),
                      tooltip: 'Editar',
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: Icon(
                        usuario.ativo ? Icons.block : Icons.check_circle,
                        size: 20,
                      ),
                      onPressed: () => _toggleUsuarioStatus(usuario),
                      tooltip: usuario.ativo ? 'Desativar' : 'Ativar',
                      color: usuario.ativo ? Colors.red : Colors.green,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetalhesUsuario(UsuarioModel usuario, UsuarioModel usuarioLogado) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Avatar e nome
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: usuario.role.cor.withValues(alpha: 0.2),
                      child: Text(
                        usuario.nome.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: usuario.role.cor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      usuario.nome,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: usuario.role.cor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(usuario.role.icone, size: 18, color: usuario.role.cor),
                          const SizedBox(width: 8),
                          Text(
                            usuario.role.nome,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: usuario.role.cor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              // Informações
              _buildInfoRow(Icons.email, 'Email', usuario.email),
              if (usuario.cargo != null)
                _buildInfoRow(Icons.work, 'Cargo', usuario.cargo!),
              if (usuario.setor != null)
                _buildInfoRow(Icons.business, 'Setor', usuario.setor!),
              if (usuario.telefone != null)
                _buildInfoRow(Icons.phone, 'Telefone', usuario.telefone!),
              _buildInfoRow(
                Icons.calendar_today,
                'Data de Criação',
                DateFormat('dd/MM/yyyy HH:mm').format(usuario.createdAt),
              ),
              if (usuario.lastLogin != null)
                _buildInfoRow(
                  Icons.login,
                  'Último Acesso',
                  DateFormat('dd/MM/yyyy HH:mm').format(usuario.lastLogin!),
                ),
              _buildInfoRow(
                usuario.ativo ? Icons.check_circle : Icons.cancel,
                'Status',
                usuario.ativo ? 'Ativo' : 'Inativo',
              ),
              const SizedBox(height: 24),
              const Text(
                'Permissões',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                usuario.role.descricao,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              // Módulos acessíveis
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Modulo.values.where((m) => usuario.podeAcessarModulo(m)).map((modulo) {
                  return Chip(
                    avatar: Icon(modulo.icone, size: 16),
                    label: Text(modulo.nome),
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNovoUsuarioDialog(UsuarioModel usuarioLogado) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();
    final emailController = TextEditingController();
    final senhaController = TextEditingController();
    final cargoController = TextEditingController();
    final setorController = TextEditingController();
    final telefoneController = TextEditingController();
    NivelAcesso nivelSelecionado = NivelAcesso.operador;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Usuário'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email é obrigatório';
                    }
                    if (!value.contains('@')) {
                      return 'Email inválido';
                    }
                    // Verificar se email já existe
                    if (_dataService.usuarios.any((u) => u.email == value)) {
                      return 'Email já cadastrado';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: senhaController,
                  decoration: const InputDecoration(
                    labelText: 'Senha *',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Senha é obrigatória';
                    }
                    if (value.length < 6) {
                      return 'Senha deve ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<NivelAcesso>(
                  value: nivelSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Perfil de Acesso *',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  items: NivelAcesso.values.map((nivel) => DropdownMenuItem(
                    value: nivel,
                    child: Row(
                      children: [
                        Icon(nivel.toRole().icone, size: 16, color: nivel.toRole().cor),
                        const SizedBox(width: 8),
                        Text(nivel.texto),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      nivelSelecionado = value;
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cargoController,
                  decoration: const InputDecoration(
                    labelText: 'Cargo',
                    prefixIcon: Icon(Icons.work),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: setorController,
                  decoration: const InputDecoration(
                    labelText: 'Setor',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telefoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final novoUsuario = UsuarioModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  nome: nomeController.text,
                  email: emailController.text,
                  senha: senhaController.text,
                  nivelAcesso: nivelSelecionado,
                  cargo: cargoController.text.isEmpty ? null : cargoController.text,
                  setor: setorController.text.isEmpty ? null : setorController.text,
                  telefone: telefoneController.text.isEmpty ? null : telefoneController.text,
                  ativo: true,
                  createdAt: DateTime.now(),
                );

                await _dataService.adicionarUsuario(novoUsuario);
                
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Usuário criado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showEditarUsuarioDialog(UsuarioModel usuario, UsuarioModel usuarioLogado) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: usuario.nome);
    final emailController = TextEditingController(text: usuario.email);
    final cargoController = TextEditingController(text: usuario.cargo);
    final setorController = TextEditingController(text: usuario.setor);
    final telefoneController = TextEditingController(text: usuario.telefone);
    NivelAcesso nivelSelecionado = usuario.nivelAcesso;
    bool alterarSenha = false;
    final senhaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Editar Usuário: ${usuario.nome}'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo *',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email é obrigatório';
                      }
                      if (!value.contains('@')) {
                        return 'Email inválido';
                      }
                      // Verificar se email já existe (exceto o atual)
                      if (value != usuario.email && _dataService.usuarios.any((u) => u.email == value)) {
                        return 'Email já cadastrado';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<NivelAcesso>(
                    value: nivelSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Perfil de Acesso *',
                      prefixIcon: Icon(Icons.badge),
                    ),
                    items: NivelAcesso.values.map((nivel) => DropdownMenuItem(
                      value: nivel,
                      child: Row(
                        children: [
                          Icon(nivel.toRole().icone, size: 16, color: nivel.toRole().cor),
                          const SizedBox(width: 8),
                          Text(nivel.texto),
                        ],
                      ),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          nivelSelecionado = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cargoController,
                    decoration: const InputDecoration(
                      labelText: 'Cargo',
                      prefixIcon: Icon(Icons.work),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: setorController,
                    decoration: const InputDecoration(
                      labelText: 'Setor',
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: telefoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: alterarSenha,
                    onChanged: (value) {
                      setDialogState(() {
                        alterarSenha = value ?? false;
                      });
                    },
                    title: const Text('Alterar senha'),
                    subtitle: const Text('Marque para definir nova senha'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (alterarSenha) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: senhaController,
                      decoration: const InputDecoration(
                        labelText: 'Nova Senha *',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (alterarSenha && (value == null || value.isEmpty)) {
                          return 'Nova senha é obrigatória';
                        }
                        if (alterarSenha && value!.length < 6) {
                          return 'Senha deve ter no mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final usuarioAtualizado = usuario.copyWith(
                    nome: nomeController.text,
                    email: emailController.text,
                    nivelAcesso: nivelSelecionado,
                    cargo: cargoController.text.isEmpty ? null : cargoController.text,
                    setor: setorController.text.isEmpty ? null : setorController.text,
                    telefone: telefoneController.text.isEmpty ? null : telefoneController.text,
                    senha: alterarSenha ? senhaController.text : usuario.senha,
                  );

                  await _dataService.atualizarUsuario(usuarioAtualizado);
                  
                  if (mounted) {
                    Navigator.pop(context);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Usuário atualizado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleUsuarioStatus(UsuarioModel usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(usuario.ativo ? 'Desativar Usuário' : 'Ativar Usuário'),
        content: Text(
          usuario.ativo
              ? 'Tem certeza que deseja desativar o usuário ${usuario.nome}? Ele não poderá mais acessar o sistema.'
              : 'Tem certeza que deseja ativar o usuário ${usuario.nome}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Atualizar status no DataService
                final index = _dataService.usuarios.indexWhere((u) => u.id == usuario.id);
                if (index != -1) {
                  _dataService.usuarios[index] = usuario.copyWith(ativo: !usuario.ativo);
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    usuario.ativo
                        ? 'Usuário desativado com sucesso!'
                        : 'Usuário ativado com sucesso!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: usuario.ativo ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(usuario.ativo ? 'Desativar' : 'Ativar'),
          ),
        ],
      ),
    );
  }
}
