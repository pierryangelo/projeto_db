﻿-- Clientes devem ter no mínimo 13 anos
CREATE OR REPLACE FUNCTION CLIENTE_RESTRICAO_DATA()
RETURNS TRIGGER
AS $$
BEGIN
    IF (SELECT EXTRACT(YEAR FROM AGE(DT_NASC_PESSOA, CURRENT_DATE)) FROM PESSOA NATURAL JOIN CLIENTE WHERE COD_PESSOA = NEW.COD_PESSOA) < 13 THEN
        RAISE EXCEPTION 'O cliente deve ter no mínimo 13 anos de idade!'
    END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TRIGGER_CLIENTE_RESTRICAO_DATA BEFORE INSERT OR UPDATE ON CLIENTE FOR EACH ROW EXECUTE PROCEDURE CLIENTE_RESTRICAO_DATA();

-- E-mails devem ser válidos com o seguinte padrão: [\w\d]+@[\w\d]+(\.\w{1,}){1,}
CREATE OR REPLACE FUNCTION PESSOA_RESTRICAO_EMAIL()
RETURNS TRIGGER
AS $$
BEGIN
    IF NEW.EMAIL_PESSOA NOT SIMILAR TO '[\w\d]+@[\w\d]+(\.\w{1,}){1,}' THEN
        RAISE EXCEPTION 'O e-mail inserido é inválido!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TRIGGER_PESSOA_RESTRICAO_EMAIL BEFORE INSERT OR UPDATE ON PESSOA FOR EACH ROW EXECUTE PROCEDURE PESSOA_RESTRICAO_EMAIL();

-- Funcionários devem ter no mínimo 16 anos
CREATE OR REPLACE FUNCTION FUNCIONARIO_RESTRICAO_DATA()
RETURNS TRIGGER
AS $$
BEGIN
    IF (SELECT EXTRACT(YEAR FROM AGE(DT_NASC_PESSOA, CURRENT_DATE)) FROM PESSOA NATURAL JOIN FUNCIONARIO WHERE COD_PESSOA = NEW.COD_PESSOA) < 16 THEN
        RAISE EXCEPTION 'O funcionário deve ter no mínimo 16 anos de idade!'
    END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TRIGGER_FUNCIONARIO_RESTRICAO_DATA BEFORE INSERT OR UPDATE ON FUNCIONARIO FOR EACH ROW EXECUTE PROCEDURE FUNCIONARIO_RESTRICAO_DATA();

-- O cupom deve ter ao menos um dia de duração
CREATE OR REPLACE FUNCTION CUPOM_RESTRICAO_TEMPO()
RETURNS TRIGGER 
AS $$
BEGIN
    IF NEW.DATA_EXPIRACAO - CURRENT_DATE = 0 THEN
        RAISE EXCEPTION 'O cupom deve ter ao menos um dia de duração!';
    END IF;
    IF NEW.DATA_EXPIRACAO - CURRENT_DATE < 0 THEN
        RAISE EXCEPTION 'O cupom não deve expirar no passado, utilize uma expiração de ao menos um dia!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TRIGGER_CUPOM_RESTRICAO_TEMPO BEFORE INSERT OR UPDATE ON CUPOM FOR EACH ROW EXECUTE PROCEDURE CUPOM_RESTRICAO_TEMPO();

-- O cupom deve ter no mínimo 10 utilizações disponíveis ao ser criado
CREATE OR REPLACE FUNCTION CUPOM_RESTRICAO_USO()
RETURNS TRIGGER 
AS $$
BEGIN
    IF NEW.USOS_DISPONIVEIS < 10 THEN
        RAISE EXCEPTION 'O cupom deve ter no mínimo 10 utilizações!';
    END IF;
    IF NEW.USOS_DISPONIVEIS < 0 THEN
        RAISE EXCEPTION 'Use apenas valores positivos paa a quantidade de usos disponíveis!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TRIGGER_CUPOM_RESTRICAO_USO BEFORE INSERT ON CUPOM FOR EACH ROW EXECUTE PROCEDURE CUPOM_RESTRICAO_USO();

-- O desconto deve ser de no máximo 90% para os cupons e taxas de Marca, Categoria e Produto
CREATE OR REPLACE FUNCTION CUPOM_RESTRICAO_DESCONTO()
RETURNS TRIGGER 
AS $$
BEGIN
    IF NEW.DESCONTO > 0.90 THEN
        RAISE EXCEPTION 'O valor máximo de desconto é 90%%!';
    END IF;
    IF NEW.DESCONTO < 0.0 THEN
        RAISE EXCEPTION 'O desconto não pode ser negativo!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TRIGGER_CUPOM_RESTRICAO_DESCONTO BEFORE INSERT OR UPDATE ON CUPOM FOR EACH ROW EXECUTE PROCEDURE CUPOM_RESTRICAO_DESCONTO();

-- Marca
CREATE OR REPLACE FUNCTION MARCA_RESTRICAO_DESCONTO()
RETURNS TRIGGER 
AS $$
BEGIN
    IF NEW.TAXA_MARCA > 0.90 THEN
        RAISE EXCEPTION 'O valor máximo de desconto é 90%%!';
    END IF;
    IF NEW.TAXA_MARCA < 0.0 THEN
        RAISE EXCEPTION 'A taxa de desconto não pode ser negativa!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TRIGGER_MARCA_RESTRICAO_DESCONTO BEFORE INSERT OR UPDATE ON MARCA FOR EACH ROW EXECUTE PROCEDURE MARCA_RESTRICAO_DESCONTO();

-- Categoria
CREATE OR REPLACE FUNCTION CATEGORIA_RESTRICAO_DESCONTO()
RETURNS TRIGGER 
AS $$
BEGIN
    IF NEW.TAXA_CATEGORIA > 0.90 THEN
        RAISE EXCEPTION 'O valor máximo de desconto é 90%%!';
    END IF;
    IF NEW.TAXA_CATEGORIA < 0.0 THEN
        RAISE EXCEPTION 'A taxa de desconto não pode ser negativa!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TRIGGER_CATEGORIA_RESTRICAO_DESCONTO BEFORE INSERT OR UPDATE ON CATEGORIA FOR EACH ROW EXECUTE PROCEDURE CATEGORIA_RESTRICAO_DESCONTO();

-- Produto
CREATE OR REPLACE FUNCTION PRODUTO_RESTRICAO_DESCONTO()
RETURNS TRIGGER 
AS $$
BEGIN
    IF NEW.TAXA_PRODUTO > 0.90 THEN
        RAISE EXCEPTION 'O valor máximo de desconto é 90%%!';
    END IF;
    IF NEW.TAXA_PRODUTO < 0.0 THEN
        RAISE EXCEPTION 'A taxa de desconto não pode ser negativa!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TRIGGER_PRODUTO_RESTRICAO_DESCONTO BEFORE INSERT OR UPDATE ON PRODUTO FOR EACH ROW EXECUTE PROCEDURE PRODUTO_RESTRICAO_DESCONTO();

-- Restrições em PRODUTO
CREATE OR REPLACE FUNCTION PRODUTO_RESTRICOES()
RETURNS TRIGGER 
AS $$
BEGIN
    IF NEW.VALOR <= 1.0 THEN
        RAISE EXCEPTION 'O valor do produto está inválido!';
    END IF;
    IF TG_OP = 'UPDATE' THEN
        IF NEW.QUANT_ESTOQUE = 0 THEN
            RAISE NOTICE format('O estoque do produto %s acabou!', NEW.NOME_PRODUTO);
	END IF;
	IF NEW.QUANT_ESTOQUE < 0 THEN
            RAISE NOTICE format('O estoque do produto %s acabou, não é possível realizar operações sobre ele!', NEW.NOME_PRODUTO);
	END IF;
    END IF;
    IF TG_OP = 'INSERT' THEN
	IF NEW.QUANT_ESTOQUE <= 0 THEN
            RAISE EXCEPTION 'A quantidade de estoque inserida é inválida!';
	END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TRIGGER_PRODUTO_RESTRICOES BEFORE INSERT OR UPDATE ON PRODUTO FOR EACH ROW EXECUTE PROCEDURE PRODUTO_RESTRICOES();

-- Restrições em ITEM_VENDA
CREATE OR REPLACE FUNCTION ITEM_VENDA_RESTRICOES()
RETURNS TRIGGER 
AS $$
BEGIN
    IF NEW.VALOR_PRODUTO <= 1.0 THEN
        RAISE EXCEPTION 'O valor do produto está inválido!';
    END IF;
    IF NEW.QUANTIDADE < 1 THEN
        RAISE EXCEPTION 'A venda do produto deve conter ao menos 1 unidade!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TRIGGER_ITEM_VENDA_RESTRICOES BEFORE INSERT OR UPDATE ON ITEM_VENDA FOR EACH ROW EXECUTE PROCEDURE ITEM_VENDA_RESTRICOES();

-- Restrições em FORMA_PAGAMENTO
CREATE OR REPLACE FUNCTION FORMA_PAGAMENTO_RESTRICOES()
RETURNS TRIGGER 
AS $$
BEGIN
    IF NEW.VALOR_PAGO <= 1.0 THEN
        RAISE EXCEPTION 'O valor pago está inválido!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TRIGGER_FORMA_PAGAMENTO_RESTRICOES BEFORE INSERT OR UPDATE ON FORMA_PAGAMENTO FOR EACH ROW EXECUTE PROCEDURE FORMA_PAGAMENTO_RESTRICOES();



