// Script de inicialização do MongoDB
// Este script é executado automaticamente quando o container MongoDB é criado

// Conectar ao banco de dados lumo
db = db.getSiblingDB('lumo');

// Criar usuário para a aplicação no banco lumo
db.createUser({
  user: 'admin',
  pwd: 'admin123',
  roles: [
    {
      role: 'readWrite',
      db: 'lumo'
    }
  ]
});

// Criar coleção slides
db.createCollection('slides');

// Criar índices para melhor performance
db.slides.createIndex({ "data.question.category": 1 });
db.slides.createIndex({ "createdAt": -1 });

print('✅ Banco de dados lumo inicializado com sucesso!');
print('📊 Coleção criada: slides');
print('🔍 Índices criados para otimização de consultas');
print('👤 Usuário da aplicação criado: admin');
