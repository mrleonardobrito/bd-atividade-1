CREATE OR REPLACE FUNCTION registrar_auditoria()
RETURNS TRIGGER AS $$
DECLARE
    acao_mapeada AcaoAuditoria;
BEGIN
    IF TG_OP = 'INSERT' THEN
        acao_mapeada := 'INSERIR';
    ELSIF TG_OP = 'UPDATE' THEN
        acao_mapeada := 'ATUALIZAR';
    ELSIF TG_OP = 'DELETE' THEN
        acao_mapeada := 'EXCLUIR';
    ELSE
        RAISE EXCEPTION 'Operação desconhecida: %', TG_OP;
    END IF;

    INSERT INTO auditoria (tablealterada, acao, datahora)
    VALUES (TG_TABLE_NAME, acao_mapeada, CURRENT_TIMESTAMP);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria
AFTER INSERT OR UPDATE OR DELETE ON cursos
FOR EACH ROW EXECUTE FUNCTION registrar_auditoria();

CREATE TRIGGER trg_auditoria_professores
AFTER INSERT OR UPDATE OR DELETE ON professores
FOR EACH ROW EXECUTE FUNCTION registrar_auditoria();

CREATE TRIGGER trg_auditoria
AFTER INSERT OR UPDATE OR DELETE ON alunos
FOR EACH ROW EXECUTE FUNCTION registrar_auditoria();

CREATE TRIGGER trg_auditoria_professores
AFTER INSERT OR UPDATE OR DELETE ON turmas
FOR EACH ROW EXECUTE FUNCTION registrar_auditoria();

CREATE TRIGGER trg_auditoria_professores
AFTER INSERT OR UPDATE OR DELETE ON matriculas
FOR EACH ROW EXECUTE FUNCTION registrar_auditoria();
