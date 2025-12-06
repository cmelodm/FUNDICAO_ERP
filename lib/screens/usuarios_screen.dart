import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foundry_erp/services/data_service.dart';
import 'package:foundry_erp/models/usuario_model.dart';
import 'package:intl/intl.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  String _filtro = 'Todos';

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final usuarios = dataService.usuarios;

    // Filtrar usuários
    final usuariosFiltrados = _filtro == 'Todos'
        ? usuarios
        : _filtro == 'Ativos'
            ? usuarios.where((u) => u.ativo).toList()
            : usuarios.where((u) => !u.ativo).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Usuários'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtros e estatísticas
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        usuarios.length.toString(),
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Ativos',
                        usuarios.where((u) => u.ativo).length.toString(),
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Inativos',
                        usuarios.where((u) => !u.ativo).length.toString(),
                        Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip('Todos'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Ativos'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Inativos'),
                  ],
                ),
              ],
            ),
          ),
          // Lista de usuários
          Expanded(
            child: usuariosFiltrados.isEmpty
                ? const Center(
                    child: Text('Nenhum usuário encontrado'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: usuariosFiltrados.length,
                    itemBuilder: (context, index) {
                      final usuario = usuariosFiltrados[index];
                      return _buildUsuarioCard(context, usuario, dataService);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogNovoUsuario(context, dataService),
        icon: const Icon(Icons.person_add),
        label: const Text('Novo Usuário'),
        backgroundColor: Colors.purple.shade700,
      ),
    );
  }

  Widget _buildStatCard(String label, String valor, Color cor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filtro == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filtro = label;
        });
      },
    );
  }

  Widget _buildUsuarioCard(
      BuildContext context, UsuarioModel usuario, DataService dataService) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: usuario.ativo
              ? _getCorNivelAcesso(usuario.nivelAcesso)
              : Colors.grey,
          foregroundColor: Colors.white,
          child: Text(
            usuario.nome.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                usuario.nome,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: usuario.ativo ? null : Colors.grey,
                ),
              ),
            ),
            if (!usuario.ativo)
              const Chip(
                label: Text('Inativo', style: TextStyle(fontSize: 10)),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                visualDensity: VisualDensity.compact,
                backgroundColor: Colors.grey,
                labelStyle: TextStyle(color: Colors.white),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usuario.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCorNivelAcesso(usuario.nivelAcesso)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    usuario.nivelAcessoTexto,
                    style: TextStyle(
                      fontSize: 11,
                      color: _getCorNivelAcesso(usuario.nivelAcesso),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (usuario.cargo != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    usuario.cargo!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ],
            ),
            if (usuario.lastLogin != null) ...[
              const SizedBox(height: 4),
              Text(
                'Último acesso: ${DateFormat('dd/MM/yyyy HH:mm').format(usuario.lastLogin!)}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'senha',
              child: Row(
                children: [
                  Icon(Icons.lock, size: 18),
                  SizedBox(width: 8),
                  Text('Alterar Senha'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'ativar',
              child: Row(
                children: [
                  Icon(usuario.ativo ? Icons.block : Icons.check_circle,
                      size: 18),
                  const SizedBox(width: 8),
                  Text(usuario.ativo ? 'Desativar' : 'Ativar'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'editar') {
              _mostrarDialogEditarUsuario(context, usuario, dataService);
            } else if (value == 'senha') {
              _mostrarDialogAlterarSenha(context, usuario, dataService);
            } else if (value == 'ativar') {
              dataService.atualizarUsuario(
                usuario.copyWith(ativo: !usuario.ativo),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    usuario.ativo
                        ? 'Usuário desativado'
                        : 'Usuário ativado',
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Color _getCorNivelAcesso(NivelAcesso nivel) {
    switch (nivel) {
      case NivelAcesso.admin:
        return Colors.red;
      case NivelAcesso.gerente:
        return Colors.blue;
      case NivelAcesso.operador:
        return Colors.green;
      case NivelAcesso.visualizador:
        return Colors.orange;
    }
  }

  void _mostrarDialogNovoUsuario(
      BuildContext context, DataService dataService) {
    final nomeController = TextEditingController();
    final emailController = TextEditingController();
    final senhaController = TextEditingController();
    final telefoneController = TextEditingController();
    final cargoController = TextEditingController();
    final setorController = TextEditingController();
    NivelAcesso nivelSelecionado = NivelAcesso.operador;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Novo Usuário'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: senhaController,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: telefoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefone (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cargoController,
                    decoration: const InputDecoration(
                      labelText: 'Cargo (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: setorController,
                    decoration: const InputDecoration(
                      labelText: 'Setor (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<NivelAcesso>(
                    value: nivelSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Nível de Acesso',
                      border: OutlineInputBorder(),
                    ),
                    items: NivelAcesso.values.map((nivel) {
                      return DropdownMenuItem(
                        value: nivel,
                        child: Text(_getNivelTexto(nivel)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        nivelSelecionado = value!;
                      });
                    },
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
              onPressed: () {
                if (nomeController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    senhaController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha os campos obrigatórios'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final novoUsuario = UsuarioModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  nome: nomeController.text,
                  email: emailController.text,
                  senha: senhaController.text,
                  nivelAcesso: nivelSelecionado,
                  telefone: telefoneController.text.isNotEmpty
                      ? telefoneController.text
                      : null,
                  cargo: cargoController.text.isNotEmpty
                      ? cargoController.text
                      : null,
                  setor: setorController.text.isNotEmpty
                      ? setorController.text
                      : null,
                  ativo: true,
                  createdAt: DateTime.now(),
                );

                dataService.adicionarUsuario(novoUsuario);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuário criado com sucesso!')),
                );
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogEditarUsuario(
      BuildContext context, UsuarioModel usuario, DataService dataService) {
    final nomeController = TextEditingController(text: usuario.nome);
    final emailController = TextEditingController(text: usuario.email);
    final telefoneController = TextEditingController(text: usuario.telefone);
    final cargoController = TextEditingController(text: usuario.cargo);
    final setorController = TextEditingController(text: usuario.setor);
    NivelAcesso nivelSelecionado = usuario.nivelAcesso;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Usuário'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: telefoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cargoController,
                    decoration: const InputDecoration(
                      labelText: 'Cargo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: setorController,
                    decoration: const InputDecoration(
                      labelText: 'Setor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<NivelAcesso>(
                    value: nivelSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Nível de Acesso',
                      border: OutlineInputBorder(),
                    ),
                    items: NivelAcesso.values.map((nivel) {
                      return DropdownMenuItem(
                        value: nivel,
                        child: Text(_getNivelTexto(nivel)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        nivelSelecionado = value!;
                      });
                    },
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
              onPressed: () {
                final usuarioAtualizado = usuario.copyWith(
                  nome: nomeController.text,
                  email: emailController.text,
                  telefone: telefoneController.text.isNotEmpty
                      ? telefoneController.text
                      : null,
                  cargo: cargoController.text.isNotEmpty
                      ? cargoController.text
                      : null,
                  setor: setorController.text.isNotEmpty
                      ? setorController.text
                      : null,
                  nivelAcesso: nivelSelecionado,
                );

                dataService.atualizarUsuario(usuarioAtualizado);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Usuário atualizado com sucesso!')),
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogAlterarSenha(
      BuildContext context, UsuarioModel usuario, DataService dataService) {
    final senhaAtualController = TextEditingController();
    final novaSenhaController = TextEditingController();
    final confirmarSenhaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: senhaAtualController,
              decoration: const InputDecoration(
                labelText: 'Senha Atual',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: novaSenhaController,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmarSenhaController,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (novaSenhaController.text != confirmarSenhaController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('As senhas não conferem'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final sucesso = await dataService.alterarSenha(
                usuario.id,
                senhaAtualController.text,
                novaSenhaController.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      sucesso
                          ? 'Senha alterada com sucesso!'
                          : 'Senha atual incorreta',
                    ),
                    backgroundColor: sucesso ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
  }

  String _getNivelTexto(NivelAcesso nivel) {
    switch (nivel) {
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
