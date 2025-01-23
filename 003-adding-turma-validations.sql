CREATE OR REPLACE FUNCTION fechar_turma()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE matriculas
    SET statusmatricula = CASE 
        WHEN notafinal >= 7 THEN 'Aprovado'::StatusMatriculaEnum
        ELSE 'Reprovado'::StatusMatriculaEnum
    END
    WHERE turmaid = OLD.turmaid;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_fechar_turma
BEFORE DELETE OR UPDATE ON turmas
FOR EACH ROW EXECUTE FUNCTION fechar_turma();
