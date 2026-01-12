import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foundry_erp/screens/dashboard_screen.dart';
import 'package:foundry_erp/screens/materiais_screen.dart';
import 'package:foundry_erp/screens/producao_screen.dart';
import 'package:foundry_erp/screens/ligas_screen.dart';
import 'package:foundry_erp/screens/gestao_screen.dart';
import 'package:foundry_erp/screens/login_screen.dart';
import 'package:foundry_erp/screens/correcao_avancada_screen.dart';
import 'package:foundry_erp/services/data_service.dart';
import 'package:foundry_erp/widgets/permissao_widget.dart';
import 'package:foundry_erp/models/usuario_model.dart';
import 'package:foundry_erp/models/permissao_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dataService = DataService();
  await dataService.inicializarDadosExemplo();
  runApp(FundicaoProApp(dataService: dataService));
}

class FundicaoProApp extends StatelessWidget {
  final DataService dataService;
  
  const FundicaoProApp({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: dataService,
      child: MaterialApp(
      title: 'FundiçãoPro ERP',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainNavigationScreen(),
        '/correcao-avancada': (context) => const CorrecaoAvancadaScreen(),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: false,
        ),
      ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProducaoScreen(),
    const MateriaisScreen(),
    const LigasScreen(),
    const GestaoScreen(),
  ];

  void _mostrarPerfilUsuario(BuildContext context, usuarioLogado, DataService dataService) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PerfilBadge(
              usuario: usuarioLogado,
              showNome: true,
              showRole: true,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              usuarioLogado.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (usuarioLogado.cargo != null) ...[
              const SizedBox(height: 4),
              Text(
                usuarioLogado.cargo!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade em desenvolvimento'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.orange),
              title: const Text('Alterar Senha'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _mostrarAlterarSenha(context, usuarioLogado, dataService);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: () {
                dataService.authService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarAlterarSenha(BuildContext context, usuarioLogado, DataService dataService) {
    final formKey = GlobalKey<FormState>();
    final senhaAtualController = TextEditingController();
    final novaSenhaController = TextEditingController();
    final confirmarSenhaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: senhaAtualController,
                decoration: const InputDecoration(
                  labelText: 'Senha Atual *',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Senha atual é obrigatória';
                  }
                  if (value != usuarioLogado.senha) {
                    return 'Senha atual incorreta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: novaSenhaController,
                decoration: const InputDecoration(
                  labelText: 'Nova Senha *',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nova senha é obrigatória';
                  }
                  if (value.length < 6) {
                    return 'Senha deve ter no mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmarSenhaController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Nova Senha *',
                  prefixIcon: Icon(Icons.lock_clock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirmação é obrigatória';
                  }
                  if (value != novaSenhaController.text) {
                    return 'Senhas não coincidem';
                  }
                  return null;
                },
              ),
            ],
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
                final sucesso = await dataService.alterarSenha(
                  usuarioLogado.id,
                  senhaAtualController.text,
                  novaSenhaController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        sucesso
                            ? '✅ Senha alterada com sucesso!'
                            : '❌ Erro ao alterar senha',
                      ),
                      backgroundColor: sucesso ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final usuarioLogado = dataService.authService.usuarioLogado;

    return Scaffold(
      appBar: usuarioLogado != null
          ? AppBar(
              title: const Text('Foundry ERP'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: InkWell(
                      onTap: () => _mostrarPerfilUsuario(context, usuarioLogado, dataService),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: usuarioLogado.nivelAcesso.toRole().cor.withValues(alpha: 0.2),
                              child: Text(
                                usuarioLogado.nome.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: usuarioLogado.nivelAcesso.toRole().cor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  usuarioLogado.nome.split(' ').first,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: usuarioLogado.nivelAcesso.toRole().cor.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    usuarioLogado.nivelAcessoTexto,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.factory_outlined),
            selectedIcon: Icon(Icons.factory),
            label: 'Produção',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Materiais',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: 'Ligas',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Gestão',
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Em Desenvolvimento',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta funcionalidade será implementada em breve',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
