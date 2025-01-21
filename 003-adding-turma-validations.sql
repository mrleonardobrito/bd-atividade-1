CREATE OR REPLACE PROCEDURE fechar_turma(p_turmaid INT)
AS $$
BEGIN
    UPDATE matriculas
    SET statusmatricula = CASE 
        WHEN notafinal >= 7 THEN 'Aprovado'::StatusMatriculaEnum
        ELSE 'Reprovado'::StatusMatriculaEnum
    END
    WHERE turmaid = p_turmaid;

    UPDATE turmas SET status = 'Fechada'::StatusTurmaEnum WHERE turmaid = p_turmaid;
END;
$$ LANGUAGE plpgsql;
