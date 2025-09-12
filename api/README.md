# API do Jogo de Quiz Educativo

API REST desenvolvida em TypeScript com Express e MongoDB para o jogo de quiz educativo.

## 🚀 Tecnologias

- **Node.js** - Runtime JavaScript
- **TypeScript** - Linguagem tipada
- **Express** - Framework web
- **MongoDB** - Banco de dados NoSQL
- **Mongoose** - ODM para MongoDB

## 📋 Pré-requisitos

- Node.js (v18 ou superior)
- MongoDB (v5 ou superior)
- npm ou yarn

## 🛠️ Instalação

1. **Instalar dependências:**
```bash
npm install
```

2. **Configurar variáveis de ambiente:**
```bash
cp env.example .env
```

3. **Configurar o arquivo .env:**
```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/meu_jogo
CORS_ORIGIN=http://localhost:3000
```

4. **Popular o banco com dados iniciais:**
```bash
npm run seed
```

## 🏃‍♂️ Executando

**Desenvolvimento:**
```bash
npm run dev
```

**Produção:**
```bash
npm run build
npm start
```

## 📚 Endpoints da API

### Slides
- `GET /api/slides` - Buscar todos os slides
- `GET /api/slides/random` - Buscar slides aleatórios
- `GET /api/slides/categoria/:categoria` - Buscar por categoria
- `POST /api/slides` - Criar novo slide

### Jogo
- `GET /api/game/configs` - Configurações iniciais do jogo
- `POST /api/game/session` - Criar sessão de jogo
- `PUT /api/game/session/:id` - Atualizar sessão
- `GET /api/game/session/:id` - Buscar sessão
- `POST /api/game/save-progress` - Salvar progresso

### Perguntas
- `GET /api/perguntas` - Buscar perguntas
- `GET /api/perguntas/random` - Perguntas aleatórias
- `GET /api/perguntas/categorias` - Listar categorias
- `GET /api/perguntas/:id` - Buscar pergunta específica
- `POST /api/perguntas` - Criar pergunta
- `PUT /api/perguntas/:id` - Atualizar pergunta
- `DELETE /api/perguntas/:id` - Deletar pergunta

### Health Check
- `GET /health` - Status da API
- `GET /` - Informações da API

## 🗄️ Estrutura do Banco

### Pergunta
```typescript
{
  pergunta: string;
  opcoes: string[];
  respostaCorreta: number;
  explicacao: string;
  categoria: Categoria;
  imagemPath?: string;
}
```

### SlideData
```typescript
{
  fundoTela: string;
  corFundo: string;
  pergunta: ObjectId;
}
```

### GameSession
```typescript
{
  userId?: string;
  configs: GameConfigs;
  slides: ObjectId[];
  status: 'iniciado' | 'em_andamento' | 'finalizado';
}
```

## 🔧 Scripts Disponíveis

- `npm run dev` - Executar em modo desenvolvimento
- `npm run build` - Compilar TypeScript
- `npm start` - Executar versão compilada
- `npm run seed` - Popular banco com dados iniciais
- `npm test` - Executar testes

## 🛡️ Segurança

- **Helmet** - Headers de segurança
- **CORS** - Controle de origem
- **Rate Limiting** - Limite de requisições
- **Validação** - Validação de dados com Mongoose

## 📊 Monitoramento

- **Morgan** - Logs de requisições
- **Health Check** - Endpoint de status
- **Error Handling** - Tratamento de erros

## 🌐 CORS

A API está configurada para aceitar requisições do Flutter app. Certifique-se de que a URL do app está configurada no `CORS_ORIGIN`.

## 📝 Logs

Os logs são exibidos no console com informações sobre:
- Requisições HTTP
- Conexões com MongoDB
- Erros e exceções
- Status do servidor
