SET TIMEZONE = 'America/Sao_Paulo';

CREATE TABLE IF NOT EXISTS cursos (
    cursoid SERIAL NOT NULL,
    nome TEXT NOT NULL UNIQUE,
    descricao VARCHAR(256) NOT NULL,
    duracao INT NOT NULL, -- Em semestres
    CONSTRAINT cursos_pk PRIMARY KEY (cursoid)
);

CREATE TABLE IF NOT EXISTS professores (
    professorid SERIAL NOT NULL,
    nome TEXT NOT NULL, 
    email VARCHAR(256) NOT NULL UNIQUE,
    cpf VARCHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(11) NOT NULL,
    CONSTRAINT professores_pk PRIMARY KEY (professorid)
);

CREATE TABLE IF NOT EXISTS alunos (
    alunoid SERIAL NOT NULL,
    nome TEXT NOT NULL,
    email VARCHAR(256) NOT NULL UNIQUE,
    cpf VARCHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(11) NOT NULL,
    endereco TEXT NOT NULL,
    CONSTRAINT aluno_pk PRIMARY KEY (alunoid)
);

CREATE TYPE NivelTurmaEnum AS ENUM ('Básico', 'Intermediário', 'Avançado');
CREATE TYPE StatusTurmaEnum AS ENUM ('Aberta', 'Fechada');

CREATE TABLE IF NOT EXISTS turmas (
    turmaid SERIAL NOT NULL,
    nome TEXT NOT NULL,
    cursoid INT NOT NULL,
    professorid INT NOT NULL,
    nivel NivelTurmaEnum NOT NULL,
    status StatusTurmaEnum NOT NULL, 
    vagas INT NOT NULL DEFAULT 30,
    CONSTRAINT turma_pk PRIMARY KEY (turmaid),
    CONSTRAINT turmas_cursos_fk FOREIGN KEY (cursoid) REFERENCES cursos(cursoid),
    CONSTRAINT turmas_professores_fk FOREIGN KEY (professorid) REFERENCES professores(professorid)
);

CREATE TYPE StatusMatriculaEnum AS ENUM ('Pendente', 'Aprovado', 'Reprovado');

CREATE TABLE IF NOT EXISTS matriculas (
    matriculaid SERIAL NOT NULL,
    alunoid INT NOT NULL,
    turmaid INT NOT NULL,
    datamatricula DATE NOT NULL DEFAULT CURRENT_DATE,
    nota1 FLOAT NULL,
    nota2 FLOAT NULL,
    notafinal FLOAT NULL,
    statusmatricula StatusMatriculaEnum NOT NULL DEFAULT 'Pendente',
    CONSTRAINT matricula_pk PRIMARY KEY (matriculaid),
    CONSTRAINT matriculas_alunos_fk FOREIGN KEY (alunoid) REFERENCES alunos(alunoid),
    CONSTRAINT matriculas_turmas_fk FOREIGN KEY (turmaid) REFERENCES turmas(turmaid)
);

CREATE TYPE AcaoAuditoria AS ENUM('INSERIR', 'ATUALIZAR', 'EXCLUIR', 'FECHAR_TURMA');

CREATE TABLE IF NOT EXISTS auditoria (
    auditid SERIAL NOT NULL,
    tablealterada VARCHAR(50),
    acao AcaoAuditoria NOT NULL, 
    datahora TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);