# 🎮 Sistema de Salas Online - GameRooms

## 📋 Visão Geral

O sistema de salas online permite que usuários criem desafios no Studio e os compartilhem em salas para jogar com amigos de forma sincronizada e competitiva.

## 🏗️ Arquitetura

### **Modelo GameRoom**
- **Código único**: 6 caracteres alfanuméricos (ex: "ABC123")
- **Host**: Usuário que criou a sala e o challenge
- **Participantes**: Lista de usuários que entraram na sala
- **Status**: waiting → playing → finished
- **Expiração**: 24 horas automática

### **Fluxo de Funcionamento**
1. **Criação**: Host cria sala com um de seus challenges
2. **Entrada**: Participantes entram com código da sala
3. **Preparação**: Todos marcam como "prontos"
4. **Jogo**: Host inicia, todos jogam simultaneamente
5. **Resultados**: Ranking final com pontuações

## 🔗 Endpoints da API

### **POST /api/online/rooms**
Criar nova sala online
```json
{
  "challengeId": "ObjectId",
  "maxParticipants": 6,
  "gameSettings": {
    "timePerQuestion": 30,
    "allowSkip": true,
    "showExplanation": true,
    "randomizeQuestions": false
  }
}
```

### **GET /api/online/rooms/:roomCode**
Buscar informações da sala
```json
{
  "roomCode": "ABC123",
  "host": { "name": "João", "photo": "..." },
  "challenge": { "title": "Geografia Brasil", "questionsCount": 10 },
  "status": "waiting",
  "participants": [...],
  "gameSettings": {...}
}
```

### **POST /api/online/rooms/:roomCode/join**
Entrar na sala
```json
Response: {
  "participants": [...],
  "canStart": false
}
```

### **PUT /api/online/rooms/:roomCode/ready**
Marcar como pronto/não pronto
```json
{
  "isReady": true
}
```

### **POST /api/online/rooms/:roomCode/start**
Iniciar jogo (apenas host)
```json
Response: {
  "status": "playing",
  "startedAt": "2024-01-01T10:00:00Z",
  "currentQuestion": 0
}
```

### **POST /api/online/rooms/:roomCode/answer**
Enviar resposta durante o jogo
```json
{
  "questionIndex": 0,
  "selectedAnswer": 2,
  "timeSpent": 15
}
```

### **GET /api/online/rooms/:roomCode/results**
Obter resultados finais
```json
{
  "results": [
    {
      "name": "João",
      "finalScore": 850,
      "correctAnswers": 8,
      "totalQuestions": 10,
      "accuracy": 80,
      "position": 1
    }
  ]
}
```

### **GET /api/online/rooms/:roomCode/status**
Status atual da sala (para polling)
```json
{
  "status": "playing",
  "currentQuestion": 3,
  "participants": [...],
  "canStart": false
}
```

### **DELETE /api/online/rooms/:roomCode/leave**
Sair da sala
- Se for host e sala em waiting: deleta sala
- Se for participante: remove da lista
- Se sala ficar vazia: deleta automaticamente

## 🎯 Funcionalidades

### **Criação de Sala**
- ✅ Validação de ownership do challenge
- ✅ Verificação de sala ativa por usuário
- ✅ Geração automática de código único
- ✅ Configurações personalizáveis

### **Entrada de Participantes**
- ✅ Validação de código da sala
- ✅ Verificação de capacidade máxima
- ✅ Prevenção de duplicatas
- ✅ Expiração automática

### **Controle de Jogo**
- ✅ Sistema de "pronto" para todos
- ✅ Início apenas pelo host
- ✅ Validação de mínimo 2 participantes
- ✅ Sincronização de perguntas

### **Sistema de Respostas**
- ✅ Validação de índices
- ✅ Prevenção de respostas duplicadas
- ✅ Cálculo automático de pontuação
- ✅ Registro de tempo gasto

### **Resultados e Ranking**
- ✅ Cálculo de precisão
- ✅ Ordenação por pontuação
- ✅ Posicionamento automático
- ✅ Estatísticas completas

## 🔒 Segurança

### **Validações**
- ✅ Autenticação obrigatória
- ✅ Verificação de ownership
- ✅ Validação de dados de entrada
- ✅ Rate limiting aplicado

### **Limpeza Automática**
- ✅ Salas expiradas (24h)
- ✅ Salas vazias
- ✅ Índices para performance
- ✅ Middleware de limpeza

## 📱 Integração com Frontend

### **Fluxo do Host**
1. **Studio** → Criar/editar challenge
2. **Menu** → "Criar Sala Online"
3. **Seleção** → Escolher challenge
4. **Configuração** → Definir regras
5. **Compartilhamento** → Enviar código
6. **Controle** → Gerenciar participantes
7. **Início** → Iniciar quando todos prontos

### **Fluxo do Participante**
1. **Recebimento** → Código da sala
2. **Entrada** → Digitar código
3. **Aguardo** → Outros participantes
4. **Preparação** → Marcar como pronto
5. **Jogo** → Responder perguntas
6. **Resultados** → Ver ranking final

## 🚀 Próximos Passos

### **Tempo Real (WebSocket)**
- [ ] Implementar Socket.IO
- [ ] Sincronização automática
- [ ] Notificações push
- [ ] Chat opcional

### **Funcionalidades Extras**
- [ ] Salas privadas com convites
- [ ] Histórico de partidas
- [ ] Replay de jogos
- [ ] Torneios e campeonatos

### **Otimizações**
- [ ] Cache de salas ativas
- [ ] Compressão de dados
- [ ] Load balancing
- [ ] Monitoramento

## 📊 Monitoramento

### **Métricas Importantes**
- Salas ativas por minuto
- Participantes por sala
- Taxa de conclusão de jogos
- Tempo médio de partida
- Erros de sincronização

### **Logs Estruturados**
- Criação/entrada em salas
- Início/fim de jogos
- Respostas e pontuações
- Erros e exceções
- Performance de queries

---

**Sistema implementado e pronto para uso! 🎉**

O sistema de salas online está totalmente funcional e integrado à API existente, sem alterar nenhuma funcionalidade prévia.
