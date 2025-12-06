import 'package:foundry_erp/models/liga_metalurgica_model.dart';

class LigaTemplatesService {
  // Singleton
  static final LigaTemplatesService _instance =
      LigaTemplatesService._internal();
  factory LigaTemplatesService() => _instance;
  LigaTemplatesService._internal();

  // Biblioteca de ligas padrão
  List<LigaTemplate> get ligasTemplates => [
        // ============ NORMA SAE ============
        _createSAE_303(), // Nova
        _createSAE_305(), // Nova
        _createSAE306(),
        _createSAE308(),
        _createSAE_309(), // Nova
        _createSAE319(),
        _createSAE_323(), // Nova
        _createSAE_329(), // Nova

        // ============ NORMA ASTM ============
        _createASTM_A356(),
        _createASTM_A357(),
        _createASTM_380(),
        _createASTM_383(),
        _createASTM_413(),

        // ============ NORMA DIN / EN 1706 ============
        _createDIN_AlSi7Mg(),
        _createDIN_AlSi9Cu3(),
        _createDIN_AlSi10Mg(),
        _createDIN_AlSi12(),

        // ============ NORMA AA (Aluminum Association) ============
        _createAA_356(),
        _createAA_319(),
        _createAA_443(),
      ];

  // Buscar liga por código
  LigaTemplate? buscarPorCodigo(String codigo) {
    try {
      return ligasTemplates.firstWhere(
        (liga) => liga.codigo.toLowerCase() == codigo.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Filtrar por norma
  List<LigaTemplate> filtrarPorNorma(String norma) {
    return ligasTemplates
        .where((liga) => liga.norma.toLowerCase() == norma.toLowerCase())
        .toList();
  }

  // ============ DEFINIÇÕES DAS LIGAS ============

  // SAE 306 - Alumínio-Silício-Cobre Hipoeutética
  LigaTemplate _createSAE306() {
    return LigaTemplate(
      codigo: 'SAE 306',
      nome: 'Liga SAE 306 (Al-Si-Cu)',
      norma: 'SAE',
      tipo: 'Alumínio',
      descricao:
          'Liga de alumínio-silício-cobre hipoeutética com excelente fundibilidade',
      aplicacao: 'Blocos de motor, cabeçotes, peças automotivas',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 7.5,
          percentualMaximo: 9.5,
          percentualNominal: 8.5,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 3.0,
          percentualMaximo: 4.0,
          percentualNominal: 3.5,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 1.0,
          percentualMaximo: 1.3,
          percentualNominal: 1.15,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Mg',
          nome: 'Magnésio',
          percentualMinimo: 0.0,
          percentualMaximo: 0.1,
          percentualNominal: 0.05,
          rendimentoForno: 90.0,
        ),
        ElementoLiga(
          simbolo: 'Mn',
          nome: 'Manganês',
          percentualMinimo: 0.0,
          percentualMaximo: 0.5,
          percentualNominal: 0.25,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Zn',
          nome: 'Zinco',
          percentualMinimo: 0.0,
          percentualMaximo: 3.0,
          percentualNominal: 1.5,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }

  // SAE 308 - Alumínio-Silício
  LigaTemplate _createSAE308() {
    return LigaTemplate(
      codigo: 'SAE 308',
      nome: 'Liga SAE 308 (Al-Si)',
      norma: 'SAE',
      tipo: 'Alumínio',
      descricao: 'Liga Al-Si com boa resistência à corrosão',
      aplicacao: 'Peças estruturais, componentes marítimos',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 5.0,
          percentualMaximo: 6.0,
          percentualNominal: 5.5,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 4.0,
          percentualMaximo: 5.0,
          percentualNominal: 4.5,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 1.0,
          percentualNominal: 0.5,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Mg',
          nome: 'Magnésio',
          percentualMinimo: 0.0,
          percentualMaximo: 0.1,
          percentualNominal: 0.05,
          rendimentoForno: 90.0,
        ),
      ],
    );
  }

  // SAE 319 (A319) - Alumínio-Silício-Cobre
  LigaTemplate _createSAE319() {
    return LigaTemplate(
      codigo: 'SAE 319',
      nome: 'Liga SAE 319 (Al-Si-Cu)',
      norma: 'SAE',
      tipo: 'Alumínio',
      descricao: 'Liga versátil com bom equilíbrio de propriedades',
      aplicacao: 'Cabeçotes, cárteres, peças automotivas gerais',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 5.5,
          percentualMaximo: 6.5,
          percentualNominal: 6.0,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 3.0,
          percentualMaximo: 4.0,
          percentualNominal: 3.5,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 1.0,
          percentualNominal: 0.5,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Mg',
          nome: 'Magnésio',
          percentualMinimo: 0.0,
          percentualMaximo: 0.1,
          percentualNominal: 0.05,
          rendimentoForno: 90.0,
        ),
        ElementoLiga(
          simbolo: 'Zn',
          nome: 'Zinco',
          percentualMinimo: 0.0,
          percentualMaximo: 3.0,
          percentualNominal: 1.0,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }

  // ASTM A356 (AA 356) - Alumínio-Silício-Magnésio
  LigaTemplate _createASTM_A356() {
    return LigaTemplate(
      codigo: 'A356',
      nome: 'Liga A356 (Al-Si-Mg)',
      norma: 'ASTM',
      tipo: 'Alumínio',
      descricao:
          'Liga de alta resistência após tratamento térmico T6, excelente para fundição',
      aplicacao:
          'Rodas automotivas, componentes aeroespaciais, peças críticas',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 6.5,
          percentualMaximo: 7.5,
          percentualNominal: 7.0,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Mg',
          nome: 'Magnésio',
          percentualMinimo: 0.25,
          percentualMaximo: 0.45,
          percentualNominal: 0.35,
          rendimentoForno: 90.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 0.2,
          percentualNominal: 0.1,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 0.0,
          percentualMaximo: 0.2,
          percentualNominal: 0.1,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Ti',
          nome: 'Titânio',
          percentualMinimo: 0.0,
          percentualMaximo: 0.2,
          percentualNominal: 0.1,
          rendimentoForno: 92.0,
        ),
      ],
    );
  }

  // ASTM A357 - Alumínio-Silício-Magnésio Premium
  LigaTemplate _createASTM_A357() {
    return LigaTemplate(
      codigo: 'A357',
      nome: 'Liga A357 (Al-Si-Mg Premium)',
      norma: 'ASTM',
      tipo: 'Alumínio',
      descricao:
          'Versão premium da A356 com controle mais rigoroso de impurezas',
      aplicacao:
          'Componentes aeroespaciais críticos, rodas de alta performance',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 6.5,
          percentualMaximo: 7.5,
          percentualNominal: 7.0,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Mg',
          nome: 'Magnésio',
          percentualMinimo: 0.40,
          percentualMaximo: 0.70,
          percentualNominal: 0.55,
          rendimentoForno: 90.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 0.12,
          percentualNominal: 0.06,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 0.0,
          percentualMaximo: 0.05,
          percentualNominal: 0.025,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Ti',
          nome: 'Titânio',
          percentualMinimo: 0.10,
          percentualMaximo: 0.20,
          percentualNominal: 0.15,
          rendimentoForno: 92.0,
        ),
      ],
    );
  }

  // ASTM 380 - Liga de injeção sob pressão
  LigaTemplate _createASTM_380() {
    return LigaTemplate(
      codigo: 'ASTM 380',
      nome: 'Liga 380 (Al-Si die cast)',
      norma: 'ASTM',
      tipo: 'Alumínio',
      descricao:
          'Liga mais popular para injeção sob pressão, excelente fundibilidade',
      aplicacao: 'Carcaças eletrônicas, peças automotivas injetadas',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 7.5,
          percentualMaximo: 9.5,
          percentualNominal: 8.5,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 3.0,
          percentualMaximo: 4.0,
          percentualNominal: 3.5,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 1.3,
          percentualNominal: 0.8,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Zn',
          nome: 'Zinco',
          percentualMinimo: 0.0,
          percentualMaximo: 3.0,
          percentualNominal: 1.0,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }

  // ASTM 383 - Excelente usinabilidade
  LigaTemplate _createASTM_383() {
    return LigaTemplate(
      codigo: 'ASTM 383',
      nome: 'Liga 383 (Al-Si die cast)',
      norma: 'ASTM',
      tipo: 'Alumínio',
      descricao: 'Versão da 380 com melhor usinabilidade e estabilidade',
      aplicacao: 'Peças que requerem usinagem posterior',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 9.5,
          percentualMaximo: 11.5,
          percentualNominal: 10.5,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 2.0,
          percentualMaximo: 3.0,
          percentualNominal: 2.5,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 1.3,
          percentualNominal: 0.8,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Zn',
          nome: 'Zinco',
          percentualMinimo: 0.0,
          percentualMaximo: 3.0,
          percentualNominal: 1.0,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }

  // ASTM 413 - Máxima fluidez
  LigaTemplate _createASTM_413() {
    return LigaTemplate(
      codigo: 'ASTM 413',
      nome: 'Liga 413 (Al-Si eutectic)',
      norma: 'ASTM',
      tipo: 'Alumínio',
      descricao:
          'Liga eutética com máxima fluidez e estanqueidade à pressão',
      aplicacao: 'Peças complexas de parede fina, componentes herméticos',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 11.0,
          percentualMaximo: 13.0,
          percentualNominal: 12.0,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 1.3,
          percentualNominal: 0.6,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 0.0,
          percentualMaximo: 1.0,
          percentualNominal: 0.3,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Mn',
          nome: 'Manganês',
          percentualMinimo: 0.0,
          percentualMaximo: 0.35,
          percentualNominal: 0.15,
          rendimentoForno: 95.0,
        ),
      ],
    );
  }

  // DIN AlSi7Mg (EN AC-42100)
  LigaTemplate _createDIN_AlSi7Mg() {
    return LigaTemplate(
      codigo: 'AlSi7Mg',
      nome: 'DIN AlSi7Mg (EN AC-42100)',
      norma: 'DIN',
      tipo: 'Alumínio',
      descricao: 'Liga europeia equivalente à A356, alta resistência',
      aplicacao: 'Componentes automotivos, peças estruturais',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 6.5,
          percentualMaximo: 7.5,
          percentualNominal: 7.0,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Mg',
          nome: 'Magnésio',
          percentualMinimo: 0.25,
          percentualMaximo: 0.45,
          percentualNominal: 0.35,
          rendimentoForno: 90.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 0.19,
          percentualNominal: 0.1,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }

  // DIN AlSi9Cu3 (EN AC-46000)
  LigaTemplate _createDIN_AlSi9Cu3() {
    return LigaTemplate(
      codigo: 'AlSi9Cu3',
      nome: 'DIN AlSi9Cu3 (EN AC-46000)',
      norma: 'DIN',
      tipo: 'Alumínio',
      descricao:
          'Liga europeia para injeção sob pressão, excelente fundibilidade',
      aplicacao: 'Carcaças, componentes injetados sob pressão',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 8.0,
          percentualMaximo: 11.0,
          percentualNominal: 9.5,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 2.0,
          percentualMaximo: 4.0,
          percentualNominal: 3.0,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 1.3,
          percentualNominal: 0.8,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Zn',
          nome: 'Zinco',
          percentualMinimo: 0.0,
          percentualMaximo: 1.2,
          percentualNominal: 0.5,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }

  // DIN AlSi10Mg (EN AC-43000)
  LigaTemplate _createDIN_AlSi10Mg() {
    return LigaTemplate(
      codigo: 'AlSi10Mg',
      nome: 'DIN AlSi10Mg (EN AC-43000)',
      norma: 'DIN',
      tipo: 'Alumínio',
      descricao: 'Liga versátil com boa fundibilidade e propriedades mecânicas',
      aplicacao: 'Peças fundidas gerais, componentes mecânicos',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 9.0,
          percentualMaximo: 11.0,
          percentualNominal: 10.0,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Mg',
          nome: 'Magnésio',
          percentualMinimo: 0.20,
          percentualMaximo: 0.45,
          percentualNominal: 0.32,
          rendimentoForno: 90.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 0.55,
          percentualNominal: 0.3,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }

  // DIN AlSi12 (EN AC-44000)
  LigaTemplate _createDIN_AlSi12() {
    return LigaTemplate(
      codigo: 'AlSi12',
      nome: 'DIN AlSi12 (EN AC-44000)',
      norma: 'DIN',
      tipo: 'Alumínio',
      descricao: 'Liga com alto silício, excelente fluidez',
      aplicacao: 'Peças complexas de parede fina',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 10.5,
          percentualMaximo: 13.5,
          percentualNominal: 12.0,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 0.55,
          percentualNominal: 0.3,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 0.0,
          percentualMaximo: 0.10,
          percentualNominal: 0.05,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }

  // AA 356.0 - Aluminum Association
  LigaTemplate _createAA_356() {
    return LigaTemplate(
      codigo: 'AA 356.0',
      nome: 'AA 356.0 (Al-Si-Mg)',
      norma: 'AA',
      tipo: 'Alumínio',
      descricao: 'Padrão Aluminum Association para liga Al-Si-Mg',
      aplicacao: 'Padrão industrial para fundição de precisão',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 6.5,
          percentualMaximo: 7.5,
          percentualNominal: 7.0,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Mg',
          nome: 'Magnésio',
          percentualMinimo: 0.25,
          percentualMaximo: 0.45,
          percentualNominal: 0.35,
          rendimentoForno: 90.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 0.6,
          percentualNominal: 0.3,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 0.0,
          percentualMaximo: 0.25,
          percentualNominal: 0.12,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }

  // AA 319.0
  LigaTemplate _createAA_319() {
    return LigaTemplate(
      codigo: 'AA 319.0',
      nome: 'AA 319.0 (Al-Si-Cu)',
      norma: 'AA',
      tipo: 'Alumínio',
      descricao: 'Padrão AA para liga Al-Si-Cu',
      aplicacao: 'Cabeçotes, blocos de motor',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 5.5,
          percentualMaximo: 6.5,
          percentualNominal: 6.0,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 3.0,
          percentualMaximo: 4.0,
          percentualNominal: 3.5,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 1.0,
          percentualNominal: 0.5,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }

  // AA 443.0
  LigaTemplate _createAA_443() {
    return LigaTemplate(
      codigo: 'AA 443.0',
      nome: 'AA 443.0 (Al-Si)',
      norma: 'AA',
      tipo: 'Alumínio',
      descricao: 'Liga de alta pureza com excelente resistência à corrosão',
      aplicacao: 'Equipamentos químicos, trocadores de calor',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 4.5,
          percentualMaximo: 6.0,
          percentualNominal: 5.25,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 0.6,
          percentualNominal: 0.3,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 0.0,
          percentualMaximo: 0.3,
          percentualNominal: 0.15,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }

  // SAE 303 - Alumínio-Silício (Alta Fluidez)
  LigaTemplate _createSAE_303() {
    return LigaTemplate(
      codigo: 'SAE 303',
      nome: 'Liga SAE 303 (Al-Si)',
      norma: 'SAE',
      tipo: 'Alumínio',
      descricao:
          'Liga Al-Si eutética com excelente fluidez, ideal para peças complexas',
      aplicacao:
          'Carcaças complexas, peças ornamentais, componentes com geometria intrincada',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 11.0,
          percentualMaximo: 13.0,
          percentualNominal: 12.0,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 0.0,
          percentualMaximo: 1.0,
          percentualNominal: 0.5,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 1.3,
          percentualNominal: 0.6,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Mn',
          nome: 'Manganês',
          percentualMinimo: 0.0,
          percentualMaximo: 0.5,
          percentualNominal: 0.25,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Mg',
          nome: 'Magnésio',
          percentualMinimo: 0.0,
          percentualMaximo: 0.3,
          percentualNominal: 0.1,
          rendimentoForno: 90.0,
        ),
        ElementoLiga(
          simbolo: 'Zn',
          nome: 'Zinco',
          percentualMinimo: 0.0,
          percentualMaximo: 1.0,
          percentualNominal: 0.5,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }

  // SAE 305 - Alumínio-Silício-Cobre (Uso Geral)
  LigaTemplate _createSAE_305() {
    return LigaTemplate(
      codigo: 'SAE 305',
      nome: 'Liga SAE 305 (Al-Si-Cu)',
      norma: 'SAE',
      tipo: 'Alumínio',
      descricao:
          'Liga Al-Si-Cu de uso geral, boa fundibilidade e usinabilidade',
      aplicacao:
          'Blocos de motor, carcaças de transmissão, componentes automotivos gerais',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 4.5,
          percentualMaximo: 6.0,
          percentualNominal: 5.0,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 1.0,
          percentualMaximo: 1.5,
          percentualNominal: 1.25,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 1.3,
          percentualNominal: 0.6,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Mn',
          nome: 'Manganês',
          percentualMinimo: 0.0,
          percentualMaximo: 0.5,
          percentualNominal: 0.25,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Mg',
          nome: 'Magnésio',
          percentualMinimo: 0.0,
          percentualMaximo: 0.3,
          percentualNominal: 0.1,
          rendimentoForno: 90.0,
        ),
        ElementoLiga(
          simbolo: 'Zn',
          nome: 'Zinco',
          percentualMinimo: 0.0,
          percentualMaximo: 1.0,
          percentualNominal: 0.5,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }

  // SAE 309 - Alumínio-Silício-Cobre-Magnésio (Média Resistência)
  LigaTemplate _createSAE_309() {
    return LigaTemplate(
      codigo: 'SAE 309',
      nome: 'Liga SAE 309 (Al-Si-Cu-Mg)',
      norma: 'SAE',
      tipo: 'Alumínio',
      descricao:
          'Liga Al-Si-Cu-Mg com média resistência mecânica, boa fundibilidade',
      aplicacao:
          'Cabeçotes, blocos de cilindros, carters, peças automotivas médias',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 7.5,
          percentualMaximo: 9.5,
          percentualNominal: 8.5,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 3.0,
          percentualMaximo: 4.0,
          percentualNominal: 3.5,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 1.3,
          percentualNominal: 0.6,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Mn',
          nome: 'Manganês',
          percentualMinimo: 0.0,
          percentualMaximo: 0.5,
          percentualNominal: 0.25,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Mg',
          nome: 'Magnésio',
          percentualMinimo: 0.0,
          percentualMaximo: 0.3,
          percentualNominal: 0.1,
          rendimentoForno: 90.0,
        ),
        ElementoLiga(
          simbolo: 'Zn',
          nome: 'Zinco',
          percentualMinimo: 0.0,
          percentualMaximo: 3.0,
          percentualNominal: 1.0,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Ni',
          nome: 'Níquel',
          percentualMinimo: 0.0,
          percentualMaximo: 0.5,
          percentualNominal: 0.2,
          rendimentoForno: 97.0,
        ),
      ],
    );
  }

  // SAE 323 - Alumínio-Silício-Cobre (Equivalente A356)
  LigaTemplate _createSAE_323() {
    return LigaTemplate(
      codigo: 'SAE 323',
      nome: 'Liga SAE 323 (Al-Si-Mg)',
      norma: 'SAE',
      tipo: 'Alumínio',
      descricao:
          'Liga Al-Si-Mg de alta resistência, equivalente à A356, tratável termicamente',
      aplicacao:
          'Rodas automotivas, componentes estruturais, peças de alta responsabilidade',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 6.5,
          percentualMaximo: 7.5,
          percentualNominal: 7.0,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Mg',
          nome: 'Magnésio',
          percentualMinimo: 0.25,
          percentualMaximo: 0.45,
          percentualNominal: 0.35,
          rendimentoForno: 90.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 0.0,
          percentualMaximo: 0.2,
          percentualNominal: 0.1,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 0.2,
          percentualNominal: 0.1,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Mn',
          nome: 'Manganês',
          percentualMinimo: 0.0,
          percentualMaximo: 0.1,
          percentualNominal: 0.05,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Ti',
          nome: 'Titânio',
          percentualMinimo: 0.0,
          percentualMaximo: 0.2,
          percentualNominal: 0.1,
          rendimentoForno: 92.0,
        ),
      ],
    );
  }

  // SAE 329 - Alumínio-Silício-Magnésio (Alta Resistência)
  LigaTemplate _createSAE_329() {
    return LigaTemplate(
      codigo: 'SAE 329',
      nome: 'Liga SAE 329 (Al-Si-Mg Premium)',
      norma: 'SAE',
      tipo: 'Alumínio',
      descricao:
          'Liga Al-Si-Mg premium com excelente resistência mecânica após T6',
      aplicacao:
          'Componentes aeroespaciais, peças críticas de segurança, rodas de alta performance',
      elementos: [
        ElementoLiga(
          simbolo: 'Si',
          nome: 'Silício',
          percentualMinimo: 6.5,
          percentualMaximo: 7.5,
          percentualNominal: 7.0,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Mg',
          nome: 'Magnésio',
          percentualMinimo: 0.50,
          percentualMaximo: 0.70,
          percentualNominal: 0.60,
          rendimentoForno: 90.0,
        ),
        ElementoLiga(
          simbolo: 'Cu',
          nome: 'Cobre',
          percentualMinimo: 0.0,
          percentualMaximo: 0.1,
          percentualNominal: 0.05,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Fe',
          nome: 'Ferro',
          percentualMinimo: 0.0,
          percentualMaximo: 0.12,
          percentualNominal: 0.06,
          rendimentoForno: 98.0,
        ),
        ElementoLiga(
          simbolo: 'Mn',
          nome: 'Manganês',
          percentualMinimo: 0.0,
          percentualMaximo: 0.05,
          percentualNominal: 0.02,
          rendimentoForno: 95.0,
        ),
        ElementoLiga(
          simbolo: 'Ti',
          nome: 'Titânio',
          percentualMinimo: 0.04,
          percentualMaximo: 0.20,
          percentualNominal: 0.12,
          rendimentoForno: 92.0,
        ),
        ElementoLiga(
          simbolo: 'Zn',
          nome: 'Zinco',
          percentualMinimo: 0.0,
          percentualMaximo: 0.10,
          percentualNominal: 0.05,
          rendimentoForno: 98.0,
        ),
      ],
    );
  }
}
