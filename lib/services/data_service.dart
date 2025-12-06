import 'package:flutter/foundation.dart';
import 'package:foundry_erp/models/material_model.dart';
import 'package:foundry_erp/models/ordem_producao_model.dart';
import 'package:foundry_erp/models/fornecedor_model.dart';
import 'package:foundry_erp/models/inspecao_qualidade_model.dart';
import 'package:foundry_erp/models/liga_metalurgica_model.dart';
import 'package:foundry_erp/models/equipamento_model.dart';
import 'package:foundry_erp/models/funcionario_model.dart';
import 'package:foundry_erp/models/analise_espectrometrica.dart';
import 'package:foundry_erp/models/nota_fiscal_model.dart';
import 'package:foundry_erp/models/ordem_compra_model.dart';
import 'package:foundry_erp/models/ordem_venda_model.dart';
import 'package:foundry_erp/models/usuario_model.dart';

class DataService extends ChangeNotifier {
  // Singleton pattern
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Dados em memória (será substituído por Firebase futuramente)
  final List<MaterialModel> _materiais = [];
  final List<OrdemProducaoModel> _ordensProducao = [];
  final List<FornecedorModel> _fornecedores = [];
  final List<InspecaoQualidadeModel> _inspecoes = [];
  final List<LigaMetalurgicaModel> _ligas = [];
  final List<EquipamentoModel> _equipamentos = [];
  final List<FuncionarioModel> _funcionarios = [];
  final List<AnaliseEspectrometrica> _analises = [];
  final List<NotaFiscalModel> _notasFiscais = [];
  final List<OrdemCompraModel> _ordensCompra = [];
  final List<OrdemVendaModel> _ordensVenda = [];
  final List<UsuarioModel> _usuarios = [];
  
  // Auth service
  final AuthService authService = AuthService();

  // Inicializar dados de exemplo
  Future<void> inicializarDadosExemplo() async {
    if (_materiais.isNotEmpty) return; // Já inicializado

    // Materiais de exemplo
    _materiais.addAll([
      MaterialModel(
        id: '1',
        nome: 'Ferro Fundido Cinzento',
        codigo: 'FFC-001',
        tipo: 'Ferro',
        quantidadeEstoque: 1500.0,
        estoqueMinimo: 500.0,
        custoUnitario: 4.50,
        ncm: '72061000',
        icms: 18.0,
        ipi: 5.0,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      MaterialModel(
        id: '2',
        nome: 'Aço Carbono SAE 1020',
        codigo: 'AC-1020',
        tipo: 'Aço',
        quantidadeEstoque: 800.0,
        estoqueMinimo: 300.0,
        custoUnitario: 6.80,
        ncm: '72081000',
        icms: 18.0,
        ipi: 5.0,
        createdAt: DateTime.now().subtract(const Duration(days: 50)),
      ),
      MaterialModel(
        id: '3',
        nome: 'Alumínio Liga 356',
        codigo: 'AL-356',
        tipo: 'Alumínio',
        quantidadeEstoque: 250.0,
        estoqueMinimo: 200.0,
        custoUnitario: 15.20,
        ncm: '76061200',
        icms: 18.0,
        ipi: 5.0,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      MaterialModel(
        id: '4',
        nome: 'Bronze SAE 660',
        codigo: 'BR-660',
        tipo: 'Bronze',
        quantidadeEstoque: 120.0,
        estoqueMinimo: 150.0,
        custoUnitario: 28.50,
        ncm: '74072900',
        icms: 18.0,
        ipi: 5.0,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      MaterialModel(
        id: '5',
        nome: 'Areia de Moldagem',
        codigo: 'AM-001',
        tipo: 'Insumo',
        quantidadeEstoque: 0.0,
        estoqueMinimo: 1000.0,
        custoUnitario: 0.85,
        ncm: '25051000',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      // Elementos de Liga Puros
      MaterialModel(
        id: '6',
        nome: 'Silício Metálico (Si)',
        codigo: 'SI-99',
        tipo: 'Elemento',
        quantidadeEstoque: 500.0,
        estoqueMinimo: 100.0,
        custoUnitario: 12.50,
        ncm: '28046900',
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
      MaterialModel(
        id: '7',
        nome: 'Cobre Eletrolítico (Cu)',
        codigo: 'CU-99',
        tipo: 'Elemento',
        quantidadeEstoque: 300.0,
        estoqueMinimo: 80.0,
        custoUnitario: 42.80,
        ncm: '74031100',
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
      MaterialModel(
        id: '8',
        nome: 'Magnésio Puro (Mg)',
        codigo: 'MG-99',
        tipo: 'Elemento',
        quantidadeEstoque: 150.0,
        estoqueMinimo: 50.0,
        custoUnitario: 38.20,
        ncm: '81043000',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      MaterialModel(
        id: '9',
        nome: 'Zinco Lingote (Zn)',
        codigo: 'ZN-99',
        tipo: 'Elemento',
        quantidadeEstoque: 600.0,
        estoqueMinimo: 150.0,
        custoUnitario: 18.50,
        ncm: '79011200',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      MaterialModel(
        id: '10',
        nome: 'Manganês (Mn)',
        codigo: 'MN-99',
        tipo: 'Elemento',
        quantidadeEstoque: 80.0,
        estoqueMinimo: 30.0,
        custoUnitario: 25.00,
        ncm: '81110010',
        createdAt: DateTime.now().subtract(const Duration(days: 28)),
      ),
      MaterialModel(
        id: '11',
        nome: 'Ferro Puro (Fe)',
        codigo: 'FE-99',
        tipo: 'Elemento',
        quantidadeEstoque: 400.0,
        estoqueMinimo: 100.0,
        custoUnitario: 8.50,
        ncm: '72011000',
        createdAt: DateTime.now().subtract(const Duration(days: 50)),
      ),
      MaterialModel(
        id: '12',
        nome: 'Titânio (Ti)',
        codigo: 'TI-99',
        tipo: 'Elemento',
        quantidadeEstoque: 40.0,
        estoqueMinimo: 15.0,
        custoUnitario: 85.00,
        ncm: '81082000',
        createdAt: DateTime.now().subtract(const Duration(days: 22)),
      ),
      MaterialModel(
        id: '13',
        nome: 'Alumínio Primário Puro (Al)',
        codigo: 'AL-P99',
        tipo: 'Elemento',
        quantidadeEstoque: 2000.0,
        estoqueMinimo: 500.0,
        custoUnitario: 14.80,
        ncm: '76011000',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ]);

    // Fornecedores de exemplo
    _fornecedores.addAll([
      FornecedorModel(
        id: '1',
        nome: 'Siderúrgica Nacional LTDA',
        cnpj: '12.345.678/0001-90',
        email: 'contato@siderurgica.com.br',
        telefone: '(11) 3456-7890',
        endereco: 'Av. Industrial, 1000',
        cidade: 'São Paulo',
        estado: 'SP',
        avaliacaoQualidade: 4.5,
        avaliacaoPreco: 4.0,
        avaliacaoPrazo: 4.8,
        avaliacaoAtendimento: 4.2,
        historico: [
          AvaliacaoFornecedor(
            data: DateTime.now().subtract(const Duration(days: 15)),
            qualidade: 5.0,
            preco: 4.0,
            prazo: 5.0,
            atendimento: 4.5,
            observacao: 'Entrega pontual e material de excelente qualidade',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      FornecedorModel(
        id: '2',
        nome: 'Alumínio Master SA',
        cnpj: '98.765.432/0001-10',
        email: 'vendas@alumaster.com.br',
        telefone: '(11) 2345-6789',
        endereco: 'Rua das Indústrias, 500',
        cidade: 'Guarulhos',
        estado: 'SP',
        avaliacaoQualidade: 4.8,
        avaliacaoPreco: 3.5,
        avaliacaoPrazo: 4.0,
        avaliacaoAtendimento: 4.5,
        historico: [],
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      ),
    ]);

    // Ordens de Compra de exemplo
    _ordensCompra.addAll([
      OrdemCompraModel(
        id: '1',
        numero: 'OC-2024-001',
        fornecedorId: '1',
        fornecedorNome: 'Siderúrgica Nacional LTDA',
        items: [
          ItemOrdemCompra(
            materialId: '1',
            materialNome: 'Ferro Fundido Cinzento',
            unidade: 'kg',
            quantidade: 1000.0,
            quantidadeRecebida: 1000.0,
            precoUnitario: 4.50,
            valorTotal: 4500.0,
          ),
          ItemOrdemCompra(
            materialId: '2',
            materialNome: 'Aço Carbono SAE 1020',
            unidade: 'kg',
            quantidade: 500.0,
            quantidadeRecebida: 500.0,
            precoUnitario: 6.80,
            valorTotal: 3400.0,
          ),
        ],
        status: StatusOrdemCompra.recebida,
        dataEmissao: DateTime.now().subtract(const Duration(days: 30)),
        dataPrevisaoEntrega: DateTime.now().subtract(const Duration(days: 20)),
        dataRecebimento: DateTime.now().subtract(const Duration(days: 18)),
        subtotal: 7900.0,
        valorFrete: 150.0,
        valorDesconto: 50.0,
        valorTotal: 8000.0,
        condicaoPagamento: '30 dias',
        observacoes: 'Material de alta qualidade, conforme especificação',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 18)),
      ),
      OrdemCompraModel(
        id: '2',
        numero: 'OC-2024-002',
        fornecedorId: '2',
        fornecedorNome: 'Alumínio Master SA',
        items: [
          ItemOrdemCompra(
            materialId: '3',
            materialNome: 'Alumínio Liga 356',
            unidade: 'kg',
            quantidade: 300.0,
            quantidadeRecebida: 0.0,
            precoUnitario: 15.20,
            valorTotal: 4560.0,
          ),
        ],
        status: StatusOrdemCompra.confirmada,
        dataEmissao: DateTime.now().subtract(const Duration(days: 5)),
        dataPrevisaoEntrega: DateTime.now().add(const Duration(days: 10)),
        subtotal: 4560.0,
        valorFrete: 80.0,
        valorDesconto: 0.0,
        valorTotal: 4640.0,
        condicaoPagamento: '15 dias',
        observacoes: 'Aguardando confirmação de entrega',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);

    // Ordens de Venda de exemplo
    _ordensVenda.addAll([
      OrdemVendaModel(
        id: '1',
        numero: 'OV-2024-001',
        clienteNome: 'Indústria Metalúrgica Brasil S/A',
        clienteCnpj: '11.222.333/0001-44',
        clienteEmail: 'compras@imb.com.br',
        clienteTelefone: '(11) 3333-4444',
        clienteEndereco: 'Av. Paulista, 1500 - São Paulo/SP',
        items: [
          ItemOrdemVenda(
            produtoId: '3',
            produtoNome: 'Alumínio Liga 356',
            unidade: 'kg',
            quantidade: 200.0,
            precoUnitario: 22.50,
            valorTotal: 4500.0,
          ),
        ],
        status: StatusOrdemVenda.faturada,
        dataEmissao: DateTime.now().subtract(const Duration(days: 15)),
        dataPrevisaoEntrega: DateTime.now().subtract(const Duration(days: 5)),
        dataFaturamento: DateTime.now().subtract(const Duration(days: 8)),
        subtotal: 4500.0,
        valorFrete: 120.0,
        valorDesconto: 100.0,
        valorTotal: 4520.0,
        condicaoPagamento: '30/60 dias',
        observacoes: 'Cliente prioritário - entrega expressa',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      OrdemVendaModel(
        id: '2',
        numero: 'OV-2024-002',
        clienteNome: 'Fundição Paraná Ltda',
        clienteCnpj: '22.333.444/0001-55',
        clienteEmail: 'vendas@fundicaopr.com.br',
        clienteTelefone: '(41) 2222-3333',
        items: [
          ItemOrdemVenda(
            produtoId: '1',
            produtoNome: 'Ferro Fundido Cinzento',
            unidade: 'kg',
            quantidade: 500.0,
            precoUnitario: 8.50,
            valorTotal: 4250.0,
          ),
          ItemOrdemVenda(
            produtoId: '4',
            produtoNome: 'Bronze SAE 660',
            unidade: 'kg',
            quantidade: 50.0,
            precoUnitario: 32.00,
            valorTotal: 1600.0,
          ),
        ],
        status: StatusOrdemVenda.emProducao,
        dataEmissao: DateTime.now().subtract(const Duration(days: 3)),
        dataPrevisaoEntrega: DateTime.now().add(const Duration(days: 12)),
        subtotal: 5850.0,
        valorFrete: 200.0,
        valorDesconto: 50.0,
        valorTotal: 6000.0,
        condicaoPagamento: '45 dias',
        ordemProducaoId: '3',
        observacoes: 'Liga especial conforme especificação técnica do cliente',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);

    // Ordens de Produção de exemplo
    _ordensProducao.addAll([
      OrdemProducaoModel(
        id: '1',
        numero: 'OP-2024-001',
        produto: 'Bloco Motor V8',
        cliente: 'Montadora XYZ',
        status: 'em_producao',
        prioridade: 'alta',
        materiaisUtilizados: [
          MaterialUtilizado(
            materialId: '1',
            materialNome: 'Ferro Fundido Cinzento',
            quantidade: 150.0,
            custoUnitario: 4.50,
          ),
        ],
        etapas: [
          EtapaProducao(
            id: 'e1',
            nome: 'Moldagem',
            status: 'concluida',
            operador: 'João Silva',
            maquina: 'Moldadora ML-500',
            dataInicio: DateTime.now().subtract(const Duration(days: 2)),
            dataConclusao: DateTime.now().subtract(const Duration(days: 1)),
            tempoEstimadoMinutos: 480,
            tempoRealMinutos: 450,
          ),
          EtapaProducao(
            id: 'e2',
            nome: 'Fundição',
            status: 'em_andamento',
            operador: 'Carlos Santos',
            maquina: 'Forno F-1200',
            dataInicio: DateTime.now().subtract(const Duration(hours: 4)),
            tempoEstimadoMinutos: 360,
          ),
          EtapaProducao(
            id: 'e3',
            nome: 'Usinagem',
            status: 'aguardando',
            tempoEstimadoMinutos: 720,
          ),
        ],
        custoEstimado: 3250.00,
        custoReal: 2850.00,
        dataCriacao: DateTime.now().subtract(const Duration(days: 3)),
        dataInicio: DateTime.now().subtract(const Duration(days: 2)),
      ),
      OrdemProducaoModel(
        id: '2',
        numero: 'OP-2024-002',
        produto: 'Cabeçote 4 Cilindros',
        cliente: 'Retífica ABC',
        status: 'aguardando',
        prioridade: 'media',
        materiaisUtilizados: [
          MaterialUtilizado(
            materialId: '2',
            materialNome: 'Aço Carbono SAE 1020',
            quantidade: 80.0,
            custoUnitario: 6.80,
          ),
        ],
        etapas: [
          EtapaProducao(
            id: 'e4',
            nome: 'Moldagem',
            status: 'aguardando',
            tempoEstimadoMinutos: 360,
          ),
          EtapaProducao(
            id: 'e5',
            nome: 'Fundição',
            status: 'aguardando',
            tempoEstimadoMinutos: 240,
          ),
        ],
        custoEstimado: 1850.00,
        custoReal: 0.0,
        dataCriacao: DateTime.now().subtract(const Duration(days: 1)),
      ),
      OrdemProducaoModel(
        id: '3',
        numero: 'OP-2024-003',
        produto: 'Pistão Alumínio',
        cliente: 'Auto Peças Sul',
        status: 'concluida',
        prioridade: 'baixa',
        materiaisUtilizados: [
          MaterialUtilizado(
            materialId: '3',
            materialNome: 'Alumínio Liga 356',
            quantidade: 25.0,
            custoUnitario: 15.20,
          ),
        ],
        etapas: [
          EtapaProducao(
            id: 'e6',
            nome: 'Fundição',
            status: 'concluida',
            operador: 'Maria Oliveira',
            dataInicio: DateTime.now().subtract(const Duration(days: 5)),
            dataConclusao: DateTime.now().subtract(const Duration(days: 4)),
            tempoEstimadoMinutos: 180,
            tempoRealMinutos: 170,
          ),
          EtapaProducao(
            id: 'e7',
            nome: 'Acabamento',
            status: 'concluida',
            operador: 'Pedro Costa',
            dataInicio: DateTime.now().subtract(const Duration(days: 4)),
            dataConclusao: DateTime.now().subtract(const Duration(days: 3)),
            tempoEstimadoMinutos: 120,
            tempoRealMinutos: 130,
          ),
        ],
        custoEstimado: 950.00,
        custoReal: 920.00,
        dataCriacao: DateTime.now().subtract(const Duration(days: 7)),
        dataInicio: DateTime.now().subtract(const Duration(days: 5)),
        dataConclusao: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);

    // Inspeções de Qualidade de exemplo
    _inspecoes.addAll([
      InspecaoQualidadeModel(
        id: '1',
        ordemProducaoId: '3',
        ordemProducaoNumero: 'OP-2024-003',
        produto: 'Pistão Alumínio',
        tipoTeste: 'dimensional',
        resultado: 'aprovado',
        naoConformidades: [],
        inspetor: 'Ana Martins',
        dataInspecao: DateTime.now().subtract(const Duration(days: 3)),
        observacoes: 'Todas as medidas dentro das tolerâncias especificadas',
      ),
      InspecaoQualidadeModel(
        id: '2',
        ordemProducaoId: '1',
        ordemProducaoNumero: 'OP-2024-001',
        produto: 'Bloco Motor V8',
        tipoTeste: 'ultrassom',
        resultado: 'aprovado_com_ressalvas',
        naoConformidades: [
          NaoConformidade(
            descricao: 'Pequena inclusão detectada na parede lateral',
            gravidade: 'baixa',
            acaoCorretiva: 'Monitorar nas próximas produções',
          ),
        ],
        inspetor: 'Roberto Lima',
        dataInspecao: DateTime.now().subtract(const Duration(hours: 2)),
        observacoes: 'Aprovado para uso com acompanhamento',
      ),
    ]);

    // Usuários de exemplo (senhas: admin123, gerente123, operador123, viewer123)
    _usuarios.addAll([
      UsuarioModel(
        id: '1',
        nome: 'Admin Sistema',
        email: 'admin@fundicaopro.com.br',
        senha: 'admin123', // Em produção, usar hash
        nivelAcesso: NivelAcesso.admin,
        telefone: '(11) 99999-0001',
        cargo: 'Administrador do Sistema',
        setor: 'TI',
        ativo: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      UsuarioModel(
        id: '2',
        nome: 'Carlos Gerente',
        email: 'gerente@fundicaopro.com.br',
        senha: 'gerente123',
        nivelAcesso: NivelAcesso.gerente,
        telefone: '(11) 99999-0002',
        cargo: 'Gerente de Produção',
        setor: 'Produção',
        ativo: true,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        lastLogin: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      UsuarioModel(
        id: '3',
        nome: 'João Operador',
        email: 'operador@fundicaopro.com.br',
        senha: 'operador123',
        nivelAcesso: NivelAcesso.operador,
        telefone: '(11) 99999-0003',
        cargo: 'Operador de Produção',
        setor: 'Produção',
        ativo: true,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      UsuarioModel(
        id: '4',
        nome: 'Maria Visualizadora',
        email: 'viewer@fundicaopro.com.br',
        senha: 'viewer123',
        nivelAcesso: NivelAcesso.visualizador,
        telefone: '(11) 99999-0004',
        cargo: 'Assistente Administrativo',
        setor: 'Administrativo',
        ativo: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
      ),
      UsuarioModel(
        id: '5',
        nome: 'Pedro Inativo',
        email: 'inativo@fundicaopro.com.br',
        senha: 'inativo123',
        nivelAcesso: NivelAcesso.operador,
        cargo: 'Ex-Operador',
        setor: 'Produção',
        ativo: false,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
    ]);
  }

  // Getters
  List<MaterialModel> get materiais => List.unmodifiable(_materiais);
  List<OrdemProducaoModel> get ordensProducao =>
      List.unmodifiable(_ordensProducao);
  List<FornecedorModel> get fornecedores => List.unmodifiable(_fornecedores);
  List<InspecaoQualidadeModel> get inspecoes =>
      List.unmodifiable(_inspecoes);
  List<LigaMetalurgicaModel> get ligas => List.unmodifiable(_ligas);
  List<EquipamentoModel> get equipamentos => List.unmodifiable(_equipamentos);
  List<FuncionarioModel> get funcionarios => List.unmodifiable(_funcionarios);
  List<AnaliseEspectrometrica> get analises => List.unmodifiable(_analises);
  List<NotaFiscalModel> get notasFiscais => List.unmodifiable(_notasFiscais);

  // Métodos CRUD para Materiais
  Future<void> adicionarMaterial(MaterialModel material) async {
    _materiais.add(material);
    notifyListeners();
  }

  Future<void> atualizarMaterial(MaterialModel material) async {
    final index = _materiais.indexWhere((m) => m.id == material.id);
    if (index != -1) {
      _materiais[index] = material;
      notifyListeners();
    }
  }

  Future<void> removerMaterial(String id) async {
    _materiais.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  MaterialModel? buscarMaterialPorId(String id) {
    try {
      return _materiais.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // Métodos CRUD para Ordens de Produção
  Future<void> adicionarOrdemProducao(OrdemProducaoModel ordem) async {
    _ordensProducao.add(ordem);
  }

  Future<void> atualizarOrdemProducao(OrdemProducaoModel ordem) async {
    final index = _ordensProducao.indexWhere((o) => o.id == ordem.id);
    if (index != -1) {
      _ordensProducao[index] = ordem;
    }
  }

  Future<void> removerOrdemProducao(String id) async {
    _ordensProducao.removeWhere((o) => o.id == id);
  }

  // Métodos CRUD para Fornecedores
  Future<void> adicionarFornecedor(FornecedorModel fornecedor) async {
    _fornecedores.add(fornecedor);
  }

  Future<void> atualizarFornecedor(FornecedorModel fornecedor) async {
    final index = _fornecedores.indexWhere((f) => f.id == fornecedor.id);
    if (index != -1) {
      _fornecedores[index] = fornecedor;
    }
  }

  Future<void> removerFornecedor(String id) async {
    _fornecedores.removeWhere((f) => f.id == id);
  }

  // Métodos CRUD para Inspeções
  Future<void> adicionarInspecao(InspecaoQualidadeModel inspecao) async {
    _inspecoes.add(inspecao);
  }

  // Métodos CRUD para Ligas Metalúrgicas
  Future<void> adicionarLiga(LigaMetalurgicaModel liga) async {
    _ligas.add(liga);
  }

  Future<void> atualizarLiga(LigaMetalurgicaModel liga) async {
    final index = _ligas.indexWhere((l) => l.id == liga.id);
    if (index != -1) {
      _ligas[index] = liga;
    }
  }

  Future<void> removerLiga(String id) async {
    _ligas.removeWhere((l) => l.id == id);
  }

  // Buscar material por símbolo de elemento
  MaterialModel? buscarMaterialPorSimbolo(String simbolo) {
    try {
      return _materiais.firstWhere(
        (m) => m.codigo.toLowerCase().contains(simbolo.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  // Verificar disponibilidade de elementos para liga
  Map<String, bool> verificarDisponibilidadeLiga(
      LigaMetalurgicaModel liga) {
    final disponibilidade = <String, bool>{};
    
    for (final elemento in liga.elementos) {
      final qtdNecessaria =
          elemento.calcularQuantidadeNecessaria(liga.pesoTotal);
      final material = buscarMaterialPorSimbolo(elemento.simbolo);
      
      disponibilidade[elemento.simbolo] =
          material != null && material.quantidadeEstoque >= qtdNecessaria;
    }
    
    return disponibilidade;
  }

  // Métodos CRUD para Equipamentos
  Future<void> adicionarEquipamento(EquipamentoModel equipamento) async {
    _equipamentos.add(equipamento);
  }

  Future<void> atualizarEquipamento(EquipamentoModel equipamento) async {
    final index = _equipamentos.indexWhere((e) => e.id == equipamento.id);
    if (index != -1) {
      _equipamentos[index] = equipamento;
    }
  }

  Future<void> removerEquipamento(String id) async {
    _equipamentos.removeWhere((e) => e.id == id);
  }

  // Métodos CRUD para Funcionários
  Future<void> adicionarFuncionario(FuncionarioModel funcionario) async {
    _funcionarios.add(funcionario);
  }

  Future<void> atualizarFuncionario(FuncionarioModel funcionario) async {
    final index = _funcionarios.indexWhere((f) => f.id == funcionario.id);
    if (index != -1) {
      _funcionarios[index] = funcionario;
    }
  }

  Future<void> removerFuncionario(String id) async {
    _funcionarios.removeWhere((f) => f.id == id);
  }

  // Métodos para Análises Espectrométricas
  Future<void> adicionarAnalise(AnaliseEspectrometrica analise) async {
    _analises.add(analise);
  }

  Future<void> atualizarAnalise(AnaliseEspectrometrica analise) async {
    final index = _analises.indexWhere((a) => a.id == analise.id);
    if (index != -1) {
      _analises[index] = analise;
    }
  }

  AnaliseEspectrometrica? buscarAnalisePorId(String id) {
    try {
      return _analises.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  List<AnaliseEspectrometrica> buscarAnalisesPorOrdem(String ordemId) {
    return _analises.where((a) => a.ordemProducaoId == ordemId).toList();
  }

  // Métodos CRUD para Notas Fiscais
  Future<void> adicionarNotaFiscal(NotaFiscalModel nota) async {
    _notasFiscais.add(nota);
    notifyListeners();
  }

  Future<void> atualizarNotaFiscal(NotaFiscalModel nota) async {
    final index = _notasFiscais.indexWhere((n) => n.id == nota.id);
    if (index != -1) {
      _notasFiscais[index] = nota;
      notifyListeners();
    }
  }

  Future<void> removerNotaFiscal(String id) async {
    _notasFiscais.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  NotaFiscalModel? buscarNotaFiscalPorId(String id) {
    try {
      return _notasFiscais.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  // Métodos CRUD para Ordens de Compra
  List<OrdemCompraModel> get ordensCompra => List.unmodifiable(_ordensCompra);

  Future<void> adicionarOrdemCompra(OrdemCompraModel ordem) async {
    _ordensCompra.add(ordem);
    notifyListeners();
  }

  Future<void> atualizarOrdemCompra(OrdemCompraModel ordem) async {
    final index = _ordensCompra.indexWhere((o) => o.id == ordem.id);
    if (index != -1) {
      _ordensCompra[index] = ordem;
      notifyListeners();
    }
  }

  Future<void> removerOrdemCompra(String id) async {
    _ordensCompra.removeWhere((o) => o.id == id);
    notifyListeners();
  }

  OrdemCompraModel? buscarOrdemCompraPorId(String id) {
    try {
      return _ordensCompra.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  List<OrdemCompraModel> buscarOrdensCompraPorFornecedor(String fornecedorId) {
    return _ordensCompra.where((o) => o.fornecedorId == fornecedorId).toList();
  }

  // Método para receber materiais de uma Ordem de Compra (atualiza estoque)
  Future<void> receberOrdemCompra(String ordemId, Map<String, double> quantidadesRecebidas) async {
    final ordem = buscarOrdemCompraPorId(ordemId);
    if (ordem == null) return;

    // Atualizar quantidades recebidas nos items
    final itemsAtualizados = ordem.items.map((item) {
      final qtdRecebida = quantidadesRecebidas[item.materialId] ?? 0.0;
      return item.copyWith(quantidadeRecebida: item.quantidadeRecebida + qtdRecebida);
    }).toList();

    // Atualizar estoque dos materiais
    for (var entry in quantidadesRecebidas.entries) {
      final material = buscarMaterialPorId(entry.key);
      if (material != null) {
        await atualizarMaterial(material.copyWith(
          quantidadeEstoque: material.quantidadeEstoque + entry.value,
        ));
      }
    }

    // Verificar se a ordem foi totalmente recebida
    final totalRecebida = itemsAtualizados.every(
      (item) => item.quantidadeRecebida >= item.quantidade,
    );

    final novoStatus = totalRecebida
        ? StatusOrdemCompra.recebida
        : StatusOrdemCompra.parcialmenteRecebida;

    await atualizarOrdemCompra(ordem.copyWith(
      items: itemsAtualizados,
      status: novoStatus,
      dataRecebimento: totalRecebida ? DateTime.now() : null,
    ));
  }

  // Métodos CRUD para Ordens de Venda
  List<OrdemVendaModel> get ordensVenda => List.unmodifiable(_ordensVenda);

  Future<void> adicionarOrdemVenda(OrdemVendaModel ordem) async {
    _ordensVenda.add(ordem);
    notifyListeners();
  }

  Future<void> atualizarOrdemVenda(OrdemVendaModel ordem) async {
    final index = _ordensVenda.indexWhere((o) => o.id == ordem.id);
    if (index != -1) {
      _ordensVenda[index] = ordem;
      notifyListeners();
    }
  }

  Future<void> removerOrdemVenda(String id) async {
    _ordensVenda.removeWhere((o) => o.id == id);
    notifyListeners();
  }

  OrdemVendaModel? buscarOrdemVendaPorId(String id) {
    try {
      return _ordensVenda.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  // Método para faturar Ordem de Venda (emitir NF e baixar estoque)
  Future<bool> faturarOrdemVenda(String ordemId) async {
    final ordem = buscarOrdemVendaPorId(ordemId);
    if (ordem == null) return false;

    // Verificar estoque disponível antes de faturar
    for (var item in ordem.items) {
      final material = buscarMaterialPorId(item.produtoId);
      if (material == null || material.quantidadeEstoque < item.quantidade) {
        return false; // Estoque insuficiente
      }
    }

    // Baixar estoque
    for (var item in ordem.items) {
      final material = buscarMaterialPorId(item.produtoId);
      if (material != null) {
        await atualizarMaterial(material.copyWith(
          quantidadeEstoque: material.quantidadeEstoque - item.quantidade,
        ));
      }
    }

    // Atualizar status da ordem para faturada
    await atualizarOrdemVenda(ordem.copyWith(
      status: StatusOrdemVenda.faturada,
      dataFaturamento: DateTime.now(),
    ));

    return true;
  }

  // Métodos CRUD para Usuários
  List<UsuarioModel> get usuarios => List.unmodifiable(_usuarios);
  
  Future<void> adicionarUsuario(UsuarioModel usuario) async {
    _usuarios.add(usuario);
    notifyListeners();
  }

  Future<void> atualizarUsuario(UsuarioModel usuario) async {
    final index = _usuarios.indexWhere((u) => u.id == usuario.id);
    if (index != -1) {
      _usuarios[index] = usuario;
      notifyListeners();
    }
  }

  Future<void> removerUsuario(String id) async {
    _usuarios.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  UsuarioModel? buscarUsuarioPorId(String id) {
    try {
      return _usuarios.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  UsuarioModel? buscarUsuarioPorEmail(String email) {
    try {
      return _usuarios.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<bool> alterarSenha(String usuarioId, String senhaAtual, String novaSenha) async {
    final usuario = buscarUsuarioPorId(usuarioId);
    if (usuario == null || usuario.senha != senhaAtual) {
      return false;
    }
    
    await atualizarUsuario(usuario.copyWith(senha: novaSenha));
    return true;
  }

  // Estatísticas para Dashboard
  Map<String, dynamic> getEstatisticas() {
    final ordensAtivas = _ordensProducao
        .where((o) => o.status != 'concluida' && o.status != 'cancelada')
        .length;
    final inspecoesAprovadas =
        _inspecoes.where((i) => i.resultado == 'aprovado').length;
    final materiaisEstoqueBaixo =
        _materiais.where((m) => m.statusEstoque == 'baixo').length;
    final materiaisEsgotados =
        _materiais.where((m) => m.statusEstoque == 'esgotado').length;

    return {
      'ordensAtivas': ordensAtivas,
      'totalOrdens': _ordensProducao.length,
      'inspecoesAprovadas': inspecoesAprovadas,
      'totalInspecoes': _inspecoes.length,
      'materiaisEstoqueBaixo': materiaisEstoqueBaixo,
      'materiaisEsgotados': materiaisEsgotados,
      'totalMateriais': _materiais.length,
      'totalFornecedores': _fornecedores.length,
      'totalEquipamentos': _equipamentos.length,
      'totalFuncionarios': _funcionarios.length,
      'totalAnalises': _analises.length,
      'totalNotasFiscais': _notasFiscais.length,
      'totalOrdensCompra': _ordensCompra.length,
      'totalOrdensVenda': _ordensVenda.length,
      'totalUsuarios': _usuarios.length,
      'usuariosAtivos': _usuarios.where((u) => u.ativo).length,
    };
  }
}
