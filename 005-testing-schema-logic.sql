-- 1. Aluno
--  a. Não permitir cadastrar / atualizar alunos com cpf iguais

-- Deve funcionar
INSERT INTO alunos (nome, email, cpf, telefone, endereco) 
VALUES ('Aluno Teste', 'aluno1@test.com', '12345678901', '11999999999', 'Rua A, 123');

-- Deve falhar
INSERT INTO alunos (nome, email, cpf, telefone, endereco) 
VALUES ('Outro Aluno', 'aluno2@test.com', '12345678901', '11988888888', 'Rua B, 456');

-- Verificar registros
SELECT * FROM alunos;

-- 2. Professores
--  a. Não permitir cadastrar / atualizar professores com cpf iguais

-- Deve funcionar
INSERT INTO professores (nome, email, cpf, telefone) 
VALUES ('Professor Teste', 'professor1@test.com', '98765432100', '11977777777');

-- Deve falhar
INSERT INTO professores (nome, email, cpf, telefone) 
VALUES ('Outro Professor', 'professor2@test.com', '98765432100', '11966666666');

-- Verificar registros
SELECT * FROM professores;

-- 3. Curso
--  a. Não permitir cadastrar curso com nomes iguais (pode levar em consideração o case sensitive)

-- Deve funcionar
INSERT INTO cursos (nome, descricao, duracao) 
VALUES ('Matemática', 'Curso de Matemática', 8);

-- Deve falhar (nome duplicado)
INSERT INTO cursos (nome, descricao, duracao) 
VALUES ('Matemática', 'Outro curso de Matemática', 10);

-- Verificar registros
SELECT * FROM cursos;

-- 4. Matrícula de Aluno
-- Criar curso, professor e turma com 1 vaga
INSERT INTO cursos (nome, descricao, duracao) VALUES ('História', 'Curso de História', 6);
INSERT INTO professores (nome, email, cpf, telefone) VALUES ('Prof. História', 'profhistoria@test.com', '98765432101', '11955555555');
INSERT INTO turmas (nome, cursoid, professorid, nivel, status, vagas) 
VALUES ('Turma História', 1, 1, 'Básico', 'Aberta', 1);

-- Criar alunos
INSERT INTO alunos (nome, email, cpf, telefone, endereco) 
VALUES ('Aluno 1', 'aluno1@teste.com', '12345678902', '11944444444', 'Rua C, 789');

INSERT INTO alunos (nome, email, cpf, telefone, endereco) 
VALUES ('Aluno 2', 'aluno2@teste.com', '12345678903', '11933333333', 'Rua D, 456');

-- a. Não permitir que o aluno seja matriculado em uma turma que não tenha vagas;

-- Matricular primeiro aluno (deve funcionar)
INSERT INTO matriculas (alunoid, turmaid) VALUES (5, 1);

-- Matricular segundo aluno (deve falhar por falta de vagas)
INSERT INTO matriculas (alunoid, turmaid) VALUES (3, 1);

SELECT * FROM matriculas;

-- b. Não permitir que o aluno seja matriculado em um curso / nível que ele já tenha sido aprovado

-- Atualizar matrícula do Aluno 1 como Aprovado
UPDATE matriculas SET notafinal = 8.0, statusmatricula = 'Aprovado' WHERE matriculaid = 8;

SELECT * FROM turmas;

-- Matricular novamente no mesmo curso/nível (deve falhar)
INSERT INTO matriculas (alunoid, turmaid) VALUES (8, 1);

-- c. Ao matricular o aluno em turma atualizar a quantidade de vagas disponíveis

-- d. Não permitir matricular aluno em turma fechada

-- Fechar turma
UPDATE turmas SET status = 'Fechada' WHERE turmaid = 1;

-- Matricular aluno (deve falhar)
INSERT INTO matriculas (alunoid, turmaid) VALUES (8, 1);

-- e. Não permitir matricular o aluno se ele não foi aprovado em nível anterior

-- Criar turma intermediária
INSERT INTO turmas (nome, cursoid, professorid, nivel, status, vagas) 
VALUES ('Turma História Intermediário', 1, 1, 'Intermediário', 'Aberta', 30);

-- Tentar matricular aluno no nível intermediário sem aprovação no básico (deve falhar)
INSERT INTO matriculas (alunoid, turmaid) VALUES (10, 2);

-- 5. Desmatricular Aluno
-- a. Atualizar quantidade de vagas da turma
-- b. Remover registro de matrícula de aluno na turma

-- Reabrir turma
UPDATE turmas SET status = 'Aberta' WHERE turmaid = 1;

-- Desmatricular aluno
DELETE FROM matriculas WHERE matriculaid = 8;

-- Verificar se as vagas foram atualizadas corretamente
SELECT vagas FROM turmas WHERE turmaid = 1; -- Deve ser 1

-- c. Não permitir desmatricular aluno em turma fechada

-- Tentar desmatricular aluno em turma fechada (deve falhar)

-- 6. Calcular Média do aluno
-- a. Ao alterar uma das notas do aluno, calcular a média das notas
-- b. Não permitir alterar notas com valores maiores que 10 e menores que zero

-- Inserir notas válidas e calcular média (deve funcionar)
UPDATE matriculas SET nota1 = 8.0, nota2 = 9.0 WHERE matriculaid = 1;
SELECT notafinal FROM matriculas WHERE matriculaid = 1; -- Deve ser 8.5

-- Inserir notas inválidas (deve falhar)
UPDATE matriculas SET nota1 = 12.0 WHERE matriculaid = 1; -- Falha
UPDATE matriculas SET nota2 = -1.0 WHERE matriculaid = 1; -- Falha

-- 7. Fechar turma
-- a. Ao fechar a turma atualizar o status de cada aluno baseado na média
-- i. >= 7 : Aprovado
-- ii. <7 : Reprovado
-- b. Atualizar o status da turma para fechado

-- Fechar turma e verificar mudanças
CALL fechar_turma(1);

-- Verificar status da turma (deve ser 'Fechada')
SELECT status FROM turmas WHERE turmaid = 1;

-- Verificar status dos alunos
SELECT alunoid, statusmatricula FROM matriculas WHERE turmaid = 1;

-- 8. Auditoria
-- a. Registrar mudanças baseadas ações no banco de dados

-- Verificar se as mudanças acima foram realizadas
SELECT * FROM auditoria;
