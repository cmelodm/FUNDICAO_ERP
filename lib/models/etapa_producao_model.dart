import 'package:flutter/material.dart';

/// Modelo para etapas hierárquicas de produção
class EtapaProducao {
  final String id;
  final String nome;
  final String descricao;
  final int ordem;
  final TipoEtapa tipo;
  final List<SubEtapa> subEtapas;
  final StatusEtapa status;
  final DateTime? dataInicio;
  final DateTime? dataConclusao;
  final String? responsavelId;
  final String? responsavelNome;
  final String? observacoes;
  
  EtapaProducao({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.ordem,
    required this.tipo,
    this.subEtapas = const [],
    this.status = StatusEtapa.pendente,
    this.dataInicio,
    this.dataConclusao,
    this.responsavelId,
    this.responsavelNome,
    this.observacoes,
  });
  
  /// Calcula progresso da etapa baseado nas subetapas
  double get progresso {
    if (subEtapas.isEmpty) {
      return status == StatusEtapa.concluida ? 100.0 : 0.0;
    }
    
    final concluidas = subEtapas.where((s) => s.status == StatusSubEtapa.concluida).length;
    return (concluidas / subEtapas.length) * 100;
  }
  
  /// Verifica se pode iniciar a etapa
  bool get podeIniciar => status == StatusEtapa.pendente;
  
  /// Verifica se pode pausar a etapa
  bool get podePausar => status == StatusEtapa.emAndamento;
  
  /// Verifica se pode concluir a etapa
  bool get podeConcluir {
    if (subEtapas.isEmpty) {
      return status == StatusEtapa.emAndamento;
    }
    return subEtapas.every((s) => s.status == StatusSubEtapa.concluida);
  }
  
  EtapaProducao copyWith({
    String? id,
    String? nome,
    String? descricao,
    int? ordem,
    TipoEtapa? tipo,
    List<SubEtapa>? subEtapas,
    StatusEtapa? status,
    DateTime? dataInicio,
    DateTime? dataConclusao,
    String? responsavelId,
    String? responsavelNome,
    String? observacoes,
  }) {
    return EtapaProducao(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      ordem: ordem ?? this.ordem,
      tipo: tipo ?? this.tipo,
      subEtapas: subEtapas ?? this.subEtapas,
      status: status ?? this.status,
      dataInicio: dataInicio ?? this.dataInicio,
      dataConclusao: dataConclusao ?? this.dataConclusao,
      responsavelId: responsavelId ?? this.responsavelId,
      responsavelNome: responsavelNome ?? this.responsavelNome,
      observacoes: observacoes ?? this.observacoes,
    );
  }
}

/// Sub-etapa de uma etapa de produção
class SubEtapa {
  final String id;
  final String nome;
  final String descricao;
  final int ordem;
  final StatusSubEtapa status;
  final DateTime? dataInicio;
  final DateTime? dataConclusao;
  final String? responsavelId;
  final String? responsavelNome;
  final bool obrigatoria;
  final String? checklist;
  
  SubEtapa({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.ordem,
    this.status = StatusSubEtapa.pendente,
    this.dataInicio,
    this.dataConclusao,
    this.responsavelId,
    this.responsavelNome,
    this.obrigatoria = true,
    this.checklist,
  });
  
  SubEtapa copyWith({
    String? id,
    String? nome,
    String? descricao,
    int? ordem,
    StatusSubEtapa? status,
    DateTime? dataInicio,
    DateTime? dataConclusao,
    String? responsavelId,
    String? responsavelNome,
    bool? obrigatoria,
    String? checklist,
  }) {
    return SubEtapa(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      ordem: ordem ?? this.ordem,
      status: status ?? this.status,
      dataInicio: dataInicio ?? this.dataInicio,
      dataConclusao: dataConclusao ?? this.dataConclusao,
      responsavelId: responsavelId ?? this.responsavelId,
      responsavelNome: responsavelNome ?? this.responsavelNome,
      obrigatoria: obrigatoria ?? this.obrigatoria,
      checklist: checklist ?? this.checklist,
    );
  }
}

/// Tipos de etapas de produção
enum TipoEtapa {
  preparacao,
  moldagem,
  fundicao,
  resfriamento,
  desmoldagem,
  acabamento,
  inspecao,
  expedicao,
}

extension TipoEtapaExtension on TipoEtapa {
  String get nome {
    switch (this) {
      case TipoEtapa.preparacao:
        return 'Preparação';
      case TipoEtapa.moldagem:
        return 'Moldagem';
      case TipoEtapa.fundicao:
        return 'Fundição';
      case TipoEtapa.resfriamento:
        return 'Resfriamento';
      case TipoEtapa.desmoldagem:
        return 'Desmoldagem';
      case TipoEtapa.acabamento:
        return 'Acabamento';
      case TipoEtapa.inspecao:
        return 'Inspeção';
      case TipoEtapa.expedicao:
        return 'Expedição';
    }
  }
  
  IconData get icone {
    switch (this) {
      case TipoEtapa.preparacao:
        return Icons.settings;
      case TipoEtapa.moldagem:
        return Icons.widgets;
      case TipoEtapa.fundicao:
        return Icons.local_fire_department;
      case TipoEtapa.resfriamento:
        return Icons.ac_unit;
      case TipoEtapa.desmoldagem:
        return Icons.open_in_full;
      case TipoEtapa.acabamento:
        return Icons.auto_fix_high;
      case TipoEtapa.inspecao:
        return Icons.search;
      case TipoEtapa.expedicao:
        return Icons.local_shipping;
    }
  }
}

/// Status de uma etapa
enum StatusEtapa {
  pendente,
  emAndamento,
  pausada,
  concluida,
  cancelada,
}

extension StatusEtapaExtension on StatusEtapa {
  String get nome {
    switch (this) {
      case StatusEtapa.pendente:
        return 'Pendente';
      case StatusEtapa.emAndamento:
        return 'Em Andamento';
      case StatusEtapa.pausada:
        return 'Pausada';
      case StatusEtapa.concluida:
        return 'Concluída';
      case StatusEtapa.cancelada:
        return 'Cancelada';
    }
  }
  
  Color get cor {
    switch (this) {
      case StatusEtapa.pendente:
        return Colors.grey;
      case StatusEtapa.emAndamento:
        return Colors.blue;
      case StatusEtapa.pausada:
        return Colors.orange;
      case StatusEtapa.concluida:
        return Colors.green;
      case StatusEtapa.cancelada:
        return Colors.red;
    }
  }
}

/// Status de uma sub-etapa
enum StatusSubEtapa {
  pendente,
  emAndamento,
  concluida,
  pulada,
}

extension StatusSubEtapaExtension on StatusSubEtapa {
  String get nome {
    switch (this) {
      case StatusSubEtapa.pendente:
        return 'Pendente';
      case StatusSubEtapa.emAndamento:
        return 'Em Andamento';
      case StatusSubEtapa.concluida:
        return 'Concluída';
      case StatusSubEtapa.pulada:
        return 'Pulada';
    }
  }
  
  Color get cor {
    switch (this) {
      case StatusSubEtapa.pendente:
        return Colors.grey;
      case StatusSubEtapa.emAndamento:
        return Colors.blue;
      case StatusSubEtapa.concluida:
        return Colors.green;
      case StatusSubEtapa.pulada:
        return Colors.orange;
    }
  }
}

/// Template padrão de etapas para processo de fundição
class EtapasProducaoTemplate {
  static List<EtapaProducao> getEtapasPadrao() {
    return [
      // 1. Preparação
      EtapaProducao(
        id: 'etapa_1',
        nome: 'Preparação',
        descricao: 'Preparação de materiais e equipamentos',
        ordem: 1,
        tipo: TipoEtapa.preparacao,
        subEtapas: [
          SubEtapa(
            id: 'sub_1_1',
            nome: 'Separar matéria-prima',
            descricao: 'Separar e pesar materiais necessários',
            ordem: 1,
          ),
          SubEtapa(
            id: 'sub_1_2',
            nome: 'Preparar ferramental',
            descricao: 'Verificar e preparar moldes e ferramentas',
            ordem: 2,
          ),
          SubEtapa(
            id: 'sub_1_3',
            nome: 'Aquecer forno',
            descricao: 'Pré-aquecer forno à temperatura especificada',
            ordem: 3,
          ),
        ],
      ),
      
      // 2. Moldagem
      EtapaProducao(
        id: 'etapa_2',
        nome: 'Moldagem',
        descricao: 'Preparação dos moldes',
        ordem: 2,
        tipo: TipoEtapa.moldagem,
        subEtapas: [
          SubEtapa(
            id: 'sub_2_1',
            nome: 'Aplicar desmoldante',
            descricao: 'Aplicar desmoldante nos moldes',
            ordem: 1,
          ),
          SubEtapa(
            id: 'sub_2_2',
            nome: 'Montar molde',
            descricao: 'Montar e fixar moldes',
            ordem: 2,
          ),
          SubEtapa(
            id: 'sub_2_3',
            nome: 'Verificar vedação',
            descricao: 'Verificar vedação e alinhamento',
            ordem: 3,
          ),
        ],
      ),
      
      // 3. Fundição
      EtapaProducao(
        id: 'etapa_3',
        nome: 'Fundição',
        descricao: 'Processo de fusão e vazamento',
        ordem: 3,
        tipo: TipoEtapa.fundicao,
        subEtapas: [
          SubEtapa(
            id: 'sub_3_1',
            nome: 'Carregar forno',
            descricao: 'Carregar material no forno',
            ordem: 1,
          ),
          SubEtapa(
            id: 'sub_3_2',
            nome: 'Análise espectrométrica',
            descricao: 'Realizar análise química da liga',
            ordem: 2,
          ),
          SubEtapa(
            id: 'sub_3_3',
            nome: 'Correção da liga',
            descricao: 'Corrigir composição química se necessário',
            ordem: 3,
            obrigatoria: false,
          ),
          SubEtapa(
            id: 'sub_3_4',
            nome: 'Vazamento',
            descricao: 'Vazar metal líquido nos moldes',
            ordem: 4,
          ),
        ],
      ),
      
      // 4. Resfriamento
      EtapaProducao(
        id: 'etapa_4',
        nome: 'Resfriamento',
        descricao: 'Aguardar solidificação',
        ordem: 4,
        tipo: TipoEtapa.resfriamento,
        subEtapas: [
          SubEtapa(
            id: 'sub_4_1',
            nome: 'Resfriamento inicial',
            descricao: 'Aguardar resfriamento inicial (30-60 min)',
            ordem: 1,
          ),
          SubEtapa(
            id: 'sub_4_2',
            nome: 'Monitoramento',
            descricao: 'Monitorar temperatura',
            ordem: 2,
          ),
        ],
      ),
      
      // 5. Desmoldagem
      EtapaProducao(
        id: 'etapa_5',
        nome: 'Desmoldagem',
        descricao: 'Remoção das peças dos moldes',
        ordem: 5,
        tipo: TipoEtapa.desmoldagem,
        subEtapas: [
          SubEtapa(
            id: 'sub_5_1',
            nome: 'Abrir moldes',
            descricao: 'Abrir e separar moldes',
            ordem: 1,
          ),
          SubEtapa(
            id: 'sub_5_2',
            nome: 'Extrair peças',
            descricao: 'Remover peças fundidas',
            ordem: 2,
          ),
        ],
      ),
      
      // 6. Acabamento
      EtapaProducao(
        id: 'etapa_6',
        nome: 'Acabamento',
        descricao: 'Limpeza e acabamento',
        ordem: 6,
        tipo: TipoEtapa.acabamento,
        subEtapas: [
          SubEtapa(
            id: 'sub_6_1',
            nome: 'Rebarbação',
            descricao: 'Remover rebarbas e canais',
            ordem: 1,
          ),
          SubEtapa(
            id: 'sub_6_2',
            nome: 'Lixamento',
            descricao: 'Lixar superfícies',
            ordem: 2,
          ),
          SubEtapa(
            id: 'sub_6_3',
            nome: 'Tratamento superficial',
            descricao: 'Aplicar tratamento (se especificado)',
            ordem: 3,
            obrigatoria: false,
          ),
        ],
      ),
      
      // 7. Inspeção
      EtapaProducao(
        id: 'etapa_7',
        nome: 'Inspeção',
        descricao: 'Controle de qualidade',
        ordem: 7,
        tipo: TipoEtapa.inspecao,
        subEtapas: [
          SubEtapa(
            id: 'sub_7_1',
            nome: 'Inspeção visual',
            descricao: 'Verificar defeitos visíveis',
            ordem: 1,
          ),
          SubEtapa(
            id: 'sub_7_2',
            nome: 'Inspeção dimensional',
            descricao: 'Verificar dimensões',
            ordem: 2,
          ),
          SubEtapa(
            id: 'sub_7_3',
            nome: 'Testes destrutivos',
            descricao: 'Realizar testes (se necessário)',
            ordem: 3,
            obrigatoria: false,
          ),
        ],
      ),
      
      // 8. Expedição
      EtapaProducao(
        id: 'etapa_8',
        nome: 'Expedição',
        descricao: 'Embalagem e envio',
        ordem: 8,
        tipo: TipoEtapa.expedicao,
        subEtapas: [
          SubEtapa(
            id: 'sub_8_1',
            nome: 'Embalar peças',
            descricao: 'Embalar conforme especificação',
            ordem: 1,
          ),
          SubEtapa(
            id: 'sub_8_2',
            nome: 'Emitir nota fiscal',
            descricao: 'Gerar documentação de envio',
            ordem: 2,
          ),
          SubEtapa(
            id: 'sub_8_3',
            nome: 'Expedir',
            descricao: 'Enviar para o cliente',
            ordem: 3,
          ),
        ],
      ),
    ];
  }
}
