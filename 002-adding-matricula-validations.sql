CREATE OR REPLACE FUNCTION validar_matricula()
RETURNS TRIGGER AS $$
DECLARE
    vagas_disponiveis INT;
    nivel_anterior NivelTurmaEnum;
    aprovado BOOLEAN;
BEGIN
    SELECT vagas INTO vagas_disponiveis 
    FROM turmas 
    WHERE turmaid = NEW.turmaid;

    IF vagas_disponiveis <= 0 THEN
        RAISE EXCEPTION 'Não há vagas disponíveis nesta turma.';
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM matriculas m
        JOIN turmas t ON t.turmaid = m.turmaid
        WHERE m.alunoid = NEW.alunoid 
          AND t.cursoid = (SELECT cursoid FROM turmas WHERE turmaid = NEW.turmaid) 
          AND m.statusmatricula = 'Aprovado'
    ) THEN
        RAISE EXCEPTION 'Aluno já aprovado neste curso/nível.';
    END IF;

    IF (SELECT status FROM turmas WHERE turmaid = NEW.turmaid) = 'Fechada'::StatusTurmaEnum THEN
        RAISE EXCEPTION 'Não é possível matricular alunos em turmas fechadas.';
    END IF;

    SELECT nivel INTO nivel_anterior 
    FROM turmas 
    WHERE turmaid = NEW.turmaid;

    SELECT EXISTS (
        SELECT 1 
        FROM matriculas m
        JOIN turmas t ON t.turmaid = m.turmaid
        WHERE m.alunoid = NEW.alunoid 
          AND t.nivel = 
              CASE nivel_anterior
                  WHEN 'Intermediário' THEN 'Básico'::NivelTurmaEnum
                  WHEN 'Avançado' THEN 'Intermediário'::NivelTurmaEnum
              END
          AND m.statusmatricula = 'Aprovado'
    ) INTO aprovado;

    IF nivel_anterior IN ('Intermediário', 'Avançado') AND NOT aprovado THEN
        RAISE EXCEPTION 'Aluno não foi aprovado no nível anterior.';
    END IF;

    IF TG_OP = 'INSERT' THEN
        UPDATE turmas SET vagas = vagas - 1 WHERE turmaid = NEW.turmaid;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_matricula
BEFORE INSERT ON matriculas
FOR EACH ROW EXECUTE FUNCTION validar_matricula();

CREATE OR REPLACE FUNCTION desmatricular_aluno()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT status FROM turmas WHERE turmaid = OLD.turmaid) = 'Fechada' THEN
        RAISE EXCEPTION 'Não é possível desmatricular alunos de turmas fechadas.';
    END IF;

    UPDATE turmas SET vagas = vagas + 1 WHERE turmaid = OLD.turmaid;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_desmatricular_aluno
BEFORE DELETE ON matriculas
FOR EACH ROW EXECUTE FUNCTION desmatricular_aluno();

CREATE OR REPLACE FUNCTION calcular_media()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.nota1 IS NOT NULL AND (NEW.nota1 < 0 OR NEW.nota1 > 10) THEN
        RAISE EXCEPTION 'Nota 1 inválida.';
    END IF;

    IF NEW.nota2 IS NOT NULL AND (NEW.nota2 < 0 OR NEW.nota2 > 10) THEN
        RAISE EXCEPTION 'Nota 2 inválida.';
    END IF;

    IF NEW.nota1 IS NOT NULL AND NEW.nota2 IS NOT NULL THEN
        NEW.notafinal = (NEW.nota1 + NEW.nota2) / 2;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calcular_media
BEFORE INSERT OR UPDATE OF nota1, nota2 ON matriculas
FOR EACH ROW EXECUTE FUNCTION calcular_media();




