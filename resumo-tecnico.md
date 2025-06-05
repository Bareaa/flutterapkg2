# Tarologia Mística App

## Visão Geral
O **Tarologia Mística** é um aplicativo Flutter para leituras de tarô místico, oferecendo interpretações personalizadas através de inteligência artificial. O app permite aos usuários realizar consultas espirituais selecionando cartas e recebendo orientações baseadas em suas perguntas.

## Arquitetura do Projeto

### Estrutura de Pastas
\`\`\`
lib/
├── app.dart                    # Configuração principal do app
├── config/                     # Configurações gerais
│   ├── routes.dart            # Sistema de rotas
│   └── themes/                # Temas e cores
├── constants/                  # Dados estáticos
├── core/                      # Utilitários centrais
├── data/                      # Camada de dados
│   ├── models/               # Modelos de dados
│   ├── repositories/         # Repositórios
│   └── services/             # Serviços externos
├── domain/                    # Lógica de negócio
├── presentation/              # Interface do usuário
│   ├── pages/               # Telas do app
│   └── widgets/             # Componentes reutilizáveis
└── widgets/                   # Widgets compartilhados
\`\`\`

## Funcionalidades Principais

### 1. **Sistema de Consultas**
- Coleta de dados pessoais (nome, data de nascimento, pergunta)
- Validação de formulários
- Armazenamento local das informações

### 2. **Seleção de Cartas**
- 36 cartas místicas organizadas por elementos (Ar, Fire, Water, Earth)
- Interface interativa com animações 3D de flip
- Seleção limitada a 5 cartas por consulta
- Embaralhamento automático das cartas

### 3. **Interpretação por IA**
- Integração com Google Gemini API
- Prompts personalizados baseados nas cartas selecionadas
- Fallback offline para casos sem internet
- Interpretações contextualizadas com a pergunta do usuário

### 4. **Histórico de Consultas**
- Armazenamento local persistente
- Visualização de consultas anteriores
- Detalhes completos incluindo cartas e interpretações

## Stack Tecnológico

### **Framework e Linguagem**
- **Flutter** (SDK Dart)
- **Material Design 3**

### **Dependências Principais**
\`\`\`yaml
dependencies:
  flutter: sdk
  google_fonts: ^4.0.4      # Tipografia personalizada
  shared_preferences: ^2.2.0 # Armazenamento local
  http: ^1.1.0              # Requisições HTTP
  intl: ^0.18.1             # Internacionalização
  share_plus: ^7.0.2        # Compartilhamento
\`\`\`

### **Gerenciamento de Estado**
- **StatefulWidget** com **AnimationController**
- Padrão Repository para acesso a dados
- Managers para lógica de negócio específica

## Modelos de Dados

### **TarotCard**
\`\`\`dart
class TarotCard {
  final int number;           // Número da carta (1-36)
  final String name;          // Nome completo
  final String description;   // Descrição detalhada
  final String element;       // Elemento (Ar, Fire, Water, Earth)
  final String representation; // Representação simbólica
}
\`\`\`

### **ConsultationData**
\`\`\`dart
class ConsultationData {
  final String name;         // Nome do consulente
  final String birthDate;    // Data de nascimento (ISO)
  final String question;     // Pergunta da consulta
}
\`\`\`

### **ConsultationHistory**
\`\`\`dart
class ConsultationHistory {
  final String id;                    // ID único
  final String name;                  // Nome do consulente
  final String birthDate;             // Data de nascimento
  final String question;              // Pergunta
  final List<int> selectedCards;      // Cartas selecionadas
  final String interpretation;        // Interpretação da IA
  final DateTime consultationDate;    // Data da consulta
}
\`\`\`

## Serviços e APIs

### **ApiService**
- **Endpoint**: Google Gemini API (`gemini-2.0-flash`)
- **Autenticação**: API Key configurável
- **Fallback**: Interpretação offline básica
- **Configuração**:
  \`\`\`dart
  'generationConfig': {
    'temperature': 0.7,
    'topP': 0.95,
    'maxOutputTokens': 1024,
  }
  \`\`\`

### **StorageService**
- **SharedPreferences** para persistência local
- Armazenamento de:
  - Dados de consulta atual
  - Cartas selecionadas
  - Histórico completo
  - Chave da API

## Interface e UX

### **Design System**
- **Tema**: Místico com gradientes roxo/índigo
- **Cores principais**:
  - Primary: `#F59E0B` (Âmbar)
  - Secondary: `#6D28D9` (Roxo)
  - Background: `#1E1B4B` (Índigo escuro)
  - Accent: `#FCD34D` (Dourado)

### **Animações**
- **Flip 3D** nas cartas
- **Parallax** no background estrelado
- **Loading effects** personalizados
- **Transições** suaves entre telas

### **Componentes Principais**
- `StarryBackground`: Fundo animado com estrelas
- `CardWidget`: Carta interativa com flip
- `LoadingEffect`: Efeito de carregamento místico
- `CardDetailWidget`: Visualização detalhada da carta

## Fluxo de Navegação

\`\`\`
Home → Consultation Form → Card Selection → Result/Interpretation
  ↓                                              ↓
Settings                                     History
\`\`\`

### **Rotas Configuradas**
- `/` - HomePage (inicial)
- `/consultation` - Formulário de consulta
- `/card-selection` - Seleção de cartas
- `/result` - Resultado e interpretação
- `/history` - Histórico de consultas
- `/settings` - Configurações da API

## Recursos Técnicos Avançados

### **Gerenciamento de Cartas**
- **CardSelectionManager**: Controla seleção com limite de 5 cartas
- **CardsRepository**: Acesso aos dados das 36 cartas
- **CardUtils**: Utilitários para cores por elemento

### **Tratamento de Erros**
- Fallback offline para API indisponível
- Validação de formulários
- Estados de loading e erro
- Mensagens de feedback ao usuário

### **Performance**
- Carregamento assíncrono de imagens
- Animações otimizadas com `SingleTickerProviderStateMixin`
- Cache local para consultas
- Lazy loading de componentes

## Configuração e Deploy

### **Requisitos**
- Flutter SDK >=2.17.0
- Dart >=2.17.0
- Google Gemini API Key

### **Instalação**
\`\`\`bash
# Clone o repositório
git clone <repository-url>

# Instale as dependências
flutter pub get

# Execute o app
flutter run
\`\`\`

### **Configuração da API**
1. Acesse [Google AI Studio](https://ai.google.dev)
2. Crie uma conta e gere uma API Key
3. No app, vá em Settings e configure a chave

### **Assets**
\`\`\`yaml
assets:
  - assets/images/           # Imagens gerais
  - assets/images/cards/     # Imagens das cartas
\`\`\`

### **Orientação**
- **Suportada**: Portrait (vertical)
- **Bloqueada**: Landscape (horizontal)

## Segurança e Privacidade

### **Dados Locais**
- Armazenamento apenas no dispositivo
- Sem sincronização em nuvem
- API Key criptografada localmente

### **API**
- Chave configurável pelo usuário
- Requisições HTTPS
- Timeout e retry automático

## Estrutura das Cartas

O app contém **36 cartas místicas** organizadas por elementos:

### **Ar (Cartas 1-9)**
- Representam clareza mental, comunicação e sabedoria
- Exemplos: Cristal, Lápis, Luva, Vela, Moedas

### **Fire (Cartas 10-18)**
- Simbolizam paixão, transformação e energia
- Exemplos: Corda com Nó, Menorah, Punhal, Taça

### **Water (Cartas 19-27)**
- Relacionadas a emoções, intuição e relacionamentos
- Exemplos: Cigarro Aceso, Luz Vermelha, Véu da Noiva

### **Earth (Cartas 28-36)**
- Focadas em questões práticas, materiais e estabilidade
- Exemplos: Cão, Estrela de Davi, Ferradura, Caminhos Abertos

## Possíveis Melhorias Futuras

1. **Autenticação de usuário**
2. **Sincronização em nuvem**
3. **Mais tipos de leitura** (3 cartas, Cruz Celta, etc.)
4. **Notificações push** para leituras diárias
5. **Compartilhamento social** aprimorado
6. **Modo offline** completo
7. **Suporte a múltiplos idiomas**
8. **Analytics** de uso

## Contribuição

Para contribuir com o projeto:

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## Licença

Este projeto é proprietário e todos os direitos são reservados.

---

**Versão**: 1.0.0+1  
**Plataforma**: Flutter (iOS/Android)  
**Desenvolvido com**: ❤️ e ✨ magia
