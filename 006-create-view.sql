CREATE OR REPLACE VIEW v_turmas_curso AS
SELECT 
    t.turmaid, 
    t.nivel, 
    c.cursoid, 
    c.nome AS nome_curso, 
    p.professorid, 
    p.nome AS nome_professor
FROM turmas t
JOIN cursos c ON t.cursoid = c.cursoid
JOIN professores p ON t.professorid = p.professorid;

SELECT * FROM v_turmas_curso WHERE cursoid = <ID_DO_CURSO>;

CREATE OR REPLACE VIEW v_alunos_turma AS
SELECT 
    m.turmaid, 
    a.alunoid, 
    a.nome AS nome_aluno, 
    m.nota1,
    m.nota2, 
    m.notafinal
FROM matriculas m
JOIN alunos a ON m.alunoid = a.alunoid;

SELECT * 
FROM v_alunos_turma
WHERE turmaid = <ID_DA_TURMA>;

CREATE OR REPLACE VIEW v_auditoria_sistema AS
SELECT 
    auditid, 
    tabelaalterada, 
    acao, 
    datahora
FROM auditoria
ORDER BY datahora DESC;

SELECT * 
FROM v_auditoria_sistema;

CREATE OR REPLACE VIEW v_alunos_certificado AS
SELECT 
    a.alunoid, 
    a.nome AS nome_aluno, 
    c.cursoid, 
    c.nome AS nome_curso
FROM alunos a
JOIN matriculas m ON a.alunoid = m.alunoid
JOIN cursos c ON m.cursoid = c.cursoid
WHERE m.statusmatricula = 'Aprovado'
GROUP BY a.alunoid, c.cursoid, c.nome, a.nome
HAVING COUNT(DISTINCT m.nivel) = 3;

SELECT * 
FROM v_alunos_certificado;

CREATE OR REPLACE VIEW v_cursos_por_aluno AS
SELECT 
    a.alunoid, 
    a.nome AS nome_aluno, 
    c.cursoid, 
    c.nome AS nome_curso
FROM alunos a
JOIN matriculas m ON a.alunoid = m.alunoid
JOIN cursos c ON m.cursoid = c.cursoid;

SELECT * 
FROM v_cursos_por_aluno
WHERE alunoid = <ID_DO_ALUNO>;
