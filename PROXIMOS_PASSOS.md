# 📋 Próximos Passos - Gestorfy Cliente

## ✅ Concluído

- [x] Estrutura do projeto criada
- [x] Modelos de dados implementados
- [x] Widgets criados (loading, headers, cards)
- [x] Página de visualização básica
- [x] Dados de teste configurados
- [x] Firebase configurado
- [x] Design responsivo implementado

## 🚀 Próximos Passos

### 1. Implementar Extração de Parâmetros da URL

**Arquivo**: `lib/main.dart`

Instalar o pacote `flutter_web_plugins` ou usar `html` para extrair os parâmetros `u` e `o` da URL.

```dart
import 'dart:html' as html;

String? getUserIdFromUrl() {
  final uri = Uri.parse(html.window.location.href);
  return uri.queryParameters['u'];
}

String? getOrcamentoIdFromUrl() {
  final uri = Uri.parse(html.window.location.href);
  return uri.queryParameters['o'];
}
```

### 2. Conectar com Firestore Real

**Arquivo**: `lib/pages/visualizar_orcamento_page.dart`

Substituir os dados de teste pela chamada real ao Firestore:

```dart
Future<void> _loadData() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    if (widget.userId == null || widget.orcamentoId == null) {
      throw Exception('Parâmetros inválidos');
    }

    final firestoreService = FirestoreService();
    
    final businessInfo = await firestoreService.getBusinessInfo(widget.userId!);
    final orcamento = await firestoreService.getOrcamento(
      widget.userId!,
      widget.orcamentoId!,
    );

    setState(() {
      _businessInfo = businessInfo;
      _orcamento = orcamento;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}
```

### 3. Implementar Galeria de Fotos

Adicionar um novo widget para exibir fotos dos orçamentos:

```dart
// lib/widgets/photo_gallery.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoGallery extends StatelessWidget {
  final List<String> photos;
  
  const PhotoGallery({super.key, required this.photos});
  
  @override
  Widget build(BuildContext context) {
    // Implementar grid de fotos com zoom
  }
}
```

### 4. Adicionar Compartilhamento

```dart
import 'package:share_plus/share_plus.dart';

void compartilharOrcamento() {
  Share.share(
    'Confira o orçamento: ${html.window.location.href}',
    subject: 'Orçamento #${orcamento.numero}',
  );
}
```

### 5. Implementar Download PDF

Instalar o pacote `pdf` e criar um gerador de PDF:

```yaml
dependencies:
  pdf: ^3.10.4
```

### 6. Página de Erro Personalizada

**Arquivo**: `lib/pages/erro_page.dart`

Criar página de erro mais amigável com diferentes mensagens:
- Orçamento não encontrado
- Orçamento não disponível
- Erro de conexão

### 7. Melhorias de UX

- [ ] Adicionar animações de transição
- [ ] Implementar skeleton loading
- [ ] Adicionar botão de voltar ao topo
- [ ] Implementar modo escuro
- [ ] Adicionar feedback visual ao copiar informações

### 8. Testes

Criar testes para:
- [ ] Modelos de dados
- [ ] Serviços do Firestore
- [ ] Widgets
- [ ] Formatadores

### 9. Analytics (Opcional)

```yaml
dependencies:
  firebase_analytics: ^10.7.4
```

Rastrear:
- Visualizações de orçamento
- Tempo de visualização
- Dispositivos usados

### 10. Deploy

```bash
# Build
flutter build web --release

# Deploy Firebase Hosting
firebase deploy --only hosting

# Ou usar GitHub Actions para CI/CD
```

## 📝 Observações Importantes

1. **Segurança**: Verificar Firebase Security Rules antes do deploy
2. **Performance**: Otimizar carregamento de imagens
3. **SEO**: Adicionar meta tags apropriadas
4. **Acessibilidade**: Testar com screen readers
5. **Browser Support**: Testar em diferentes navegadores

## 🐛 Bugs Conhecidos

- Nenhum até o momento

## 📚 Documentação

- [Especificações Completas](../GESTORFY_CLIENT_SPECS.md)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)

---

**Última Atualização**: 08/11/2025
