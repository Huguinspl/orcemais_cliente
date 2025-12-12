import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/orcamento.dart';
import '../models/recibo.dart';
import '../models/business_info.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //  NOVO: Busca documento compartilhado (snapshot completo - carregamento rápido)
  // Retorna orçamento + businessInfo em UMA única leitura
  Future<Map<String, dynamic>?> getSharedDocument(String documentId) async {
    try {
      print(' Buscando documento compartilhado: shared_documents/$documentId');

      DocumentSnapshot doc = await _db
          .collection('shared_documents')
          .doc(documentId)
          .get();

      if (!doc.exists) {
        print(' Snapshot não encontrado, usando fallback');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      print(' Snapshot encontrado! Carregamento rápido ativado');
      return data;
    } catch (e) {
      print(' Erro ao buscar snapshot: $e');
      return null;
    }
  }

  // Busca orçamento específico (fallback caso não exista snapshot)
  Future<Orcamento?> getOrcamento(String userId, String orcamentoId) async {
    try {
      print(' Buscando orçamento: users/$userId/orcamentos/$orcamentoId');

      DocumentSnapshot doc = await _db
          .collection('business')
          .doc(userId)
          .collection('orcamentos')
          .doc(orcamentoId)
          .get();

      if (!doc.exists) {
        print(' Orçamento não encontrado');
        return null;
      }

      Orcamento orcamento = Orcamento.fromFirestore(doc);

      print(' Orçamento encontrado com status: ${orcamento.status}');
      return orcamento;
    } catch (e) {
      print(' Erro ao buscar orçamento: $e');
      rethrow;
    }
  }

  // Busca recibo específico
  Future<Recibo?> getRecibo(String userId, String reciboId) async {
    try {
      print(' Buscando recibo: business/$userId/recibos/$reciboId');

      DocumentSnapshot doc = await _db
          .collection('business')
          .doc(userId)
          .collection('recibos')
          .doc(reciboId)
          .get();

      if (!doc.exists) {
        print(' Recibo não encontrado');
        return null;
      }

      Recibo recibo = Recibo.fromFirestore(doc);

      print(' Recibo encontrado com status: ${recibo.status}');
      return recibo;
    } catch (e) {
      print(' Erro ao buscar recibo: $e');
      rethrow;
    }
  }

  // Busca informações do negócio (fallback caso não exista snapshot)
  Future<BusinessInfo?> getBusinessInfo(String userId) async {
    try {
      print(' Buscando dados do negócio: users/$userId/business/info');

      DocumentSnapshot doc = await _db.collection('business').doc(userId).get();

      if (!doc.exists) {
        print(' Dados do negócio não encontrados');
        return null;
      }

      final businessInfo = BusinessInfo.fromDoc(doc);
      print(' Negócio encontrado: ${businessInfo.nomeEmpresa}');
      return businessInfo;
    } catch (e) {
      print(' Erro ao buscar dados do negócio: $e');
      rethrow;
    }
  }

  // Atualiza o status do orçamento (no documento original E no snapshot)
  Future<void> updateOrcamentoStatus(
    String userId,
    String orcamentoId,
    String novoStatus,
  ) async {
    try {
      print(' Atualizando status do orçamento para: $novoStatus');

      // Atualiza no documento original
      await _db
          .collection('business')
          .doc(userId)
          .collection('orcamentos')
          .doc(orcamentoId)
          .update({'status': novoStatus});

      // Atualiza também no snapshot compartilhado (se existir)
      try {
        await _db.collection('shared_documents').doc(orcamentoId).update({
          'orcamento.status': novoStatus,
        });
      } catch (e) {
        // Ignora se o snapshot não existir
        print(' Snapshot não atualizado (pode não existir): $e');
      }

      print(' Status atualizado com sucesso');
    } catch (e) {
      print(' Erro ao atualizar status: $e');
      rethrow;
    }
  }
}
