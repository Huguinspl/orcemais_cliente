# Guia: Enviar Cores Personalizadas no Link Web

## ✅ Sistema Atualizado!

O sistema `gestorfy_cliente` (https://gestorfy-cliente.web.app) agora suporta **cores personalizadas** vindas dos parâmetros do Deep Link!

---

## 📤 Como Enviar as Cores do Gestorfy

### 1. No arquivo onde você cria o Deep Link, adicione os parâmetros de cores:

```dart
import 'package:deep_link/services/link_service.dart';

// Obter cores do BusinessProvider (formato ARGB int)
final businessProvider = context.read<BusinessProvider>();
final theme = businessProvider.pdfTheme;

// Extrair valores ARGB como int
final corPrimaria = theme?['primary'] as int?;
final corSecundaria = theme?['secondaryContainer'] as int?;
final corTerciaria = theme?['tertiaryContainer'] as int?;
final corTextoSecundario = theme?['onSecondaryContainer'] as int?;
final corTextoTerciario = theme?['onTertiaryContainer'] as int?;

// Criar Deep Link com TODAS as cores
final link = await DeepLink.createLink(
  parametrosPersonalizados: {
    // Parâmetros obrigatórios
    'userId': userId,
    'documentoId': orcamentoId,
    'tipoDocumento': 'orcamento',
    
    // CORES PERSONALIZADAS (formato ARGB como string)
    'corPrimaria': corPrimaria?.toString() ?? '',
    'corSecundaria': corSecundaria?.toString() ?? '',
    'corTerciaria': corTerciaria?.toString() ?? '',
    'corTextoSecundario': corTextoSecundario?.toString() ?? '',
    'corTextoTerciario': corTextoTerciario?.toString() ?? '',
  },
  dominioPersonalizado: 'https://gestorfy-cliente.web.app',
);
```

---

## 🎨 Formato das Cores

### Formato Esperado: **ARGB como Int**

Exemplo de cor azul (`Colors.blue.shade600`):
```dart
Color azul = Color(0xFF1E88E5);  // Hexadecimal
int argb = 4280391909;           // Decimal (ARGB)

// No Deep Link, enviar como string:
'corPrimaria': '4280391909'
```

### Conversão Color → ARGB Int:

```dart
// Se você tem um Color:
Color minhaCor = Colors.blue.shade600;

// Obter valor ARGB:
int argbValue = minhaCor.value;

// Converter para string:
String corParaEnviar = argbValue.toString();
```

### Tabela de Conversão (Referência):

| Cor Flutter | Hexadecimal | ARGB Int (Decimal) |
|-------------|-------------|-------------------|
| `Colors.blue.shade600` | `0xFF1E88E5` | `4280391909` |
| `Colors.blue.shade50` | `0xFFE3F2FD` | `4293718525` |
| `Colors.blue.shade100` | `0xFFBBDEFB` | `4289774331` |
| `Colors.blue.shade900` | `0xFF0D47A1` | `4278216609` |
| `Colors.green.shade600` | `0xFF43A047` | `4282933319` |
| `Colors.red.shade600` | `0xFFE53935` | `4293380405` |

---

## 📋 Parâmetros de Cores no Deep Link

### Parâmetros Aceitos:

| Parâmetro | Descrição | Exemplo | Onde é Aplicado |
|-----------|-----------|---------|----------------|
| `corPrimaria` | Cor principal | `4280391909` | AppBar, totais, destaques |
| `corSecundaria` | Fundo secundário | `4293718525` | Card de resumo financeiro |
| `corTerciaria` | Fundo terciário | `4289774331` | Labels de seção |
| `corTextoSecundario` | Texto sobre fundo secundário | `4278216609` | Texto em labels |
| `corTextoTerciario` | Texto sobre fundo terciário | `4278216609` | Texto em cards |

### ⚠️ Importante:
- Todas as cores são **opcionais**
- Se não enviadas, o sistema usa cores padrão azul
- Enviar como **string** (ex: `'4280391909'`)
- Formato: **ARGB Int** (não hexadecimal)

---

## 🔄 Fluxo Completo

### 1. **No Gestorfy (app principal):**

```dart
// EtapaLinkWebPage ou onde você cria o link

Future<void> _criarLinkWeb() async {
  final businessProvider = context.read<BusinessProvider>();
  final theme = businessProvider.pdfTheme;
  
  // Extrair cores (se existirem)
  final Map<String, String> parametros = {
    'userId': userId,
    'documentoId': orcamentoId,
    'tipoDocumento': 'orcamento',
  };
  
  // Adicionar cores se disponíveis
  if (theme != null) {
    if (theme['primary'] != null) {
      parametros['corPrimaria'] = theme['primary'].toString();
    }
    if (theme['secondaryContainer'] != null) {
      parametros['corSecundaria'] = theme['secondaryContainer'].toString();
    }
    if (theme['tertiaryContainer'] != null) {
      parametros['corTerciaria'] = theme['tertiaryContainer'].toString();
    }
    if (theme['onSecondaryContainer'] != null) {
      parametros['corTextoSecundario'] = theme['onSecondaryContainer'].toString();
    }
    if (theme['onTertiaryContainer'] != null) {
      parametros['corTextoTerciario'] = theme['onTertiaryContainer'].toString();
    }
  }
  
  // Criar link
  final link = await DeepLink.createLink(
    parametrosPersonalizados: parametros,
    dominioPersonalizado: 'https://gestorfy-cliente.web.app',
  );
  
  print('✅ Link criado: ${link.shortUrl}');
}
```

### 2. **O Deep Link Hub armazena os parâmetros:**

```
Link: https://link.deeplinkhub.com/abc123
Parâmetros armazenados:
{
  "userId": "abc123xyz",
  "documentoId": "orcamento456",
  "tipoDocumento": "orcamento",
  "corPrimaria": "4280391909",
  "corSecundaria": "4293718525",
  "corTerciaria": "4289774331",
  "corTextoSecundario": "4278216609",
  "corTextoTerciario": "4278216609"
}
```

### 3. **Cliente clica no link:**
- Redireciona para: `https://gestorfy-cliente.web.app/?idLink=abc123`

### 4. **O gestorfy_cliente:**
- Busca parâmetros do Deep Link Hub
- Converte ARGB strings para `Color` objects
- Cria `CustomTheme` com as cores
- Aplica no AppBar, cards, labels, etc.

---

## 🎨 Onde as Cores São Aplicadas

### No Orçamento:

1. **AppBar:** `corPrimaria`
2. **Card de Resumo Financeiro:** 
   - Fundo: `corSecundaria`
   - Valor Total: `corPrimaria`
3. **Labels de Seção ("Itens do Orçamento", etc.):**
   - Fundo: `corTerciaria`
   - Texto: `corTextoTerciario`

### No Recibo:

1. **AppBar:** Verde (padrão) ou `corPrimaria` se enviada
2. **Card de Resumo:** Verde claro ou `corSecundaria`
3. **Labels:** Verde escuro ou cores personalizadas

---

## 🧪 Teste Rápido

### Exemplo de Link Completo:

```dart
final link = await DeepLink.createLink(
  parametrosPersonalizados: {
    'userId': 'tdB0QRkOfiMfRQAMykXjasZbIXq2',
    'documentoId': '9uaQfBGgae5TcuPjqgts',
    'tipoDocumento': 'orcamento',
    'corPrimaria': '4280391909',      // Azul 600
    'corSecundaria': '4293718525',    // Azul 50
    'corTerciaria': '4289774331',     // Azul 100
    'corTextoSecundario': '4278216609', // Azul 900
    'corTextoTerciario': '4278216609',  // Azul 900
  },
  dominioPersonalizado: 'https://gestorfy-cliente.web.app',
);
```

---

## ✅ Checklist de Implementação

### No Gestorfy (você precisa fazer):
- [ ] Importar `package:deep_link/services/link_service.dart`
- [ ] Obter cores do `BusinessProvider.pdfTheme`
- [ ] Converter `Color.value` (int) para String
- [ ] Adicionar cores nos `parametrosPersonalizados`
- [ ] Criar Deep Link com todos os parâmetros
- [ ] Testar com cores personalizadas

### No gestorfy_cliente (já está pronto! ✅):
- [x] Modelo `CustomTheme` criado
- [x] Conversão ARGB string → Color
- [x] Extração de cores dos parâmetros
- [x] Aplicação de cores no AppBar
- [x] Aplicação de cores nos cards
- [x] Aplicação de cores nas labels
- [x] Cores padrão como fallback
- [x] Deploy realizado

---

## 🚀 Próximos Passos

1. **No Gestorfy:** Adicione as cores ao criar o Deep Link (código acima)
2. **Teste:** Crie um orçamento e gere o link
3. **Abra:** O link no navegador
4. **Verifique:** Se as cores personalizadas foram aplicadas

Se as cores não aparecerem, verifique no console do navegador se os parâmetros estão chegando corretamente:
```
🎨 Tema personalizado: CustomTheme(primary: Color(0xff1e88e5), ...)
```

---

## 📝 Observações

- ✅ Sistema 100% compatível com cores padrão (azul) se não enviadas
- ✅ Conversão automática ARGB → Color
- ✅ Funciona tanto para orçamentos quanto recibos
- ✅ Deploy já realizado em produção
- ⚠️ Cores devem ser enviadas no formato ARGB Int como string
- ⚠️ Não enviar formato hexadecimal (0xFFRRGGBB)
