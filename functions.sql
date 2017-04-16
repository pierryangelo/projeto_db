﻿-- Créditos ao Lucas (@spallacety)
CREATE OR REPLACE FUNCTION INSERT(tabela TEXT, valores TEXT, hasPrimaryKey BOOLEAN) 
RETURNS VOID 
AS $$
	DECLARE
	    query TEXT := 'INSERT INTO ' || tabela || ' VALUES (' || valores || ');';
	BEGIN
        IF hasPrimaryKey = TRUE THEN
            query := 'INSERT INTO ' || tabela || ' VALUES (DEFAULT, ' || valores || ');';
        END IF;
        EXECUTE query;
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION DESCONTO_APLICADO(NOME VARCHAR(60), PORCENTAGEM DECIMAL(3,2))
RETURNS text
AS $$
BEGIN
    IF (PORCENTAGEM > 0.0) THEN
        RETURN format('Desconto de %1$s%% aplicado ao item %2$s', PORCENTAGEM * 100, NOME);
    ELSE
        RETURN format('O desconto no item %1$s foi retirado', NOME);
    END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION APLICAR_DESCONTO(TIPO VARCHAR(15), NOME VARCHAR(60), PORCENTAGEM DECIMAL(3,2))
RETURNS text
AS $$
DECLARE
    COD_PROD INT;
    COD_CAT INT;
    COD_MARC INT;
BEGIN
    IF (UPPER(TIPO) = 'PRODUTO') THEN
        SELECT COD_PRODUTO INTO COD_PROD FROM PRODUTO WHERE UPPER(NOME_PRODUTO) LIKE UPPER(NOME);
        IF COD_PROD IS NOT NULL THEN
            UPDATE PRODUTO SET TAXA_PRODUTO = PORCENTAGEM WHERE COD_PRODUTO = COD_PROD;
            RETURN DESCONTO_APLICADO(NOME, PORCENTAGEM);
        ELSE
            RETURN format('O produto %1$s não existe!', NOME);
        END IF;
    END IF;
    IF (UPPER(TIPO) = 'CATEGORIA') THEN
        SELECT COD_CATEGORIA INTO COD_CAT FROM CATEGORIA WHERE UPPER(NOME_CATEGORIA) LIKE UPPER(NOME);
        IF COD_CAT IS NOT NULL THEN
            UPDATE CATEGORIA SET TAXA_CATEGORIA = PORCENTAGEM WHERE COD_CATEGORIA = COD_CAT;
            RETURN DESCONTO_APLICADO(NOME, PORCENTAGEM);
        ELSE
            RETURN format('A categoria %1$s não existe!', NOME);
        END IF;
    END IF;
    IF (UPPER(TIPO) = 'MARCA') THEN
        SELECT COD_MARCA INTO COD_MARC FROM MARCA WHERE UPPER(NOME_MARCA) LIKE UPPER(NOME);
        IF COD_MARC IS NOT NULL THEN
            UPDATE MARCA SET TAXA_MARCA = PORCENTAGEM WHERE COD_MARCA = COD_MARC;
            RETURN DESCONTO_APLICADO(NOME, PORCENTAGEM);
        ELSE
            RETURN format('A marca %1$s não existe!', NOME);
        END IF;
    END IF;
    RETURN 'O tipo inserido é inválido! Selecione entre PRODUTO, CATEGORIA e MARCA!';
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION RESETAR_DESCONTO(TIPO VARCHAR(15), NOME VARCHAR(60))
RETURNS text
AS $$
BEGIN
    RETURN APLICAR_DESCONTO(TIPO, NOME, 0.0);
END;
$$ LANGUAGE 'plpgsql';

-- Função para obter o preço do produto com o seu desconto 
CREATE OR REPLACE FUNCTION OBTER_PRECO_DESCONTADO(COD_ITEM INT)
RETURNS DECIMAL(10,2)
AS $$
DECLARE
    VALOR_PRODUTO DECIMAL(10,2);
    DESCONTO_PRODUTO DECIMAL(10,2);
    DESCONTO_CATEGORIA DECIMAL(10,2);
    DESCONTO_MARCA DECIMAL(10,2);
BEGIN
    SELECT VALOR INTO VALOR_PRODUTO FROM PRODUTO WHERE COD_PRODUTO = COD_ITEM;
    SELECT TAXA_PRODUTO INTO DESCONTO_PRODUTO FROM CATALOGO WHERE COD_PRODUTO = COD_ITEM;
    SELECT TAXA_CATEGORIA INTO DESCONTO_CATEGORIA FROM CATALOGO WHERE COD_PRODUTO = COD_ITEM;
    SELECT TAXA_MARCA INTO DESCONTO_MARCA FROM CATALOGO WHERE COD_PRODUTO = COD_ITEM;
    IF (DESCONTO_PRODUTO > 0.0) THEN 
        RETURN VALOR_PRODUTO - (VALOR_PRODUTO * DESCONTO_PRODUTO); 
    END IF;
    IF (DESCONTO_CATEGORIA > 0.0) THEN
        RETURN VALOR_PRODUTO - (VALOR_PRODUTO * DESCONTO_CATEGORIA);
    END IF;
    IF (DESCONTO_MARCA > 0.0) THEN
        RETURN VALOR_PRODUTO - (VALOR_PRODUTO * DESCONTO_MARCA);
    END IF;
    RETURN VALOR_PRODUTO;
END;
$$ LANGUAGE 'plpgsql';

-- Função que verifica a compatibilidade dos itens no carrinho e avisa o usuário sobre
CREATE OR REPLACE FUNCTION VERIFICAR_COMPATIBILIDADE(COD_CART INT)
RETURNS text
AS $$
DECLARE
   COD_PLACA INT;
   COD_PROD INT;
   COUNTER INT := 0;
   PRODUTOS TEXT;
   LINHA RECORD;
   MESSAGE TEXT := 'mas há produtos incompatíveis no carrinho!';
BEGIN
    SELECT COD_PRODUTO INTO COD_PLACA FROM OBTER_CARRINHO(COD_CART) WHERE TIPO = 'Placa-mãe';
    PRODUTOS := format('(SELECT * FROM ITEM_CARRINHO NATURAL JOIN CATEGORIA WHERE COD_CARRINHO = %1$s);', COD_CART);
    IF COD_PLACA IS NOT NULL THEN
        FOR LINHA IN EXECUTE PRODUTOS LOOP
            IF (SELECT COUNT(*) FROM COMPATIBILIDADE WHERE COD_CATEGORIA_PRIMARIA = COD_PLACA AND COD_CATEGORIA_SECUNDARIA = LINHA.COD_CATEGORIA) = 0 THEN
                COUNTER := COUNTER + 1;
            END IF;
        END LOOP;
    END IF;
    IF COUNTER <= 0 THEN
        MESSAGE := NULL;
    END IF;
    RETURN MESSAGE;
END;
$$ LANGUAGE 'plpgsql';

SELECT VERIFICAR_COMPATIBILIDADE(1);

CREATE OR REPLACE FUNCTION ADICIONAR_ITEM(CPF_FUNCIONARIO VARCHAR(14), CPF_CLIENTE VARCHAR(14), NOME_ITEM VARCHAR(60), QUANTIDADE_ADICIONADA INT) 
RETURNS TEXT
AS $$
DECLARE
    COD_ITEM INT;
    COD_FUNC INT;
    COD_CART INT;
    COD_CLI INT;
    VALOR_UNITARIO DECIMAL(10,2);
    VALOR_TOTAL DECIMAL(10,2);
    MENSAGEM TEXT;
    COMPAT TEXT;
BEGIN
    -- Inicialização de variáveis
    SELECT PROCURAR_CLIENTE(CPF_CLIENTE) INTO COD_CLI;
    SELECT PROCURAR_FUNCIONARIO(CPF_FUNCIONARIO) INTO COD_FUNC;
    SELECT PROCURAR_ITEM(NOME_ITEM) INTO COD_ITEM;
    SELECT OBTER_PRECO_DESCONTADO(COD_ITEM) INTO VALOR_UNITARIO;
    SELECT OBTER_CARRINHO(COD_FUNC, COD_CLI) INTO COD_CART;

    IF (SELECT COUNT(*) FROM ITEM_CARRINHO WHERE COD_CARRINHO = COD_CART AND COD_PRODUTO = COD_ITEM) = 0 THEN
            INSERT INTO ITEM_CARRINHO VALUES(COD_ITEM, COD_CART, VALOR_UNITARIO * QUANTIDADE_ADICIONADA, QUANTIDADE_ADICIONADA);
            MENSAGEM := format('O produto %1$s foi adicionado ao carrinho (%2$s unidade(s)) com preço unitário de %3$s', NOME_ITEM, QUANTIDADE_ADICIONADA, VALOR_UNITARIO);
    ELSE -- Se já existe e o ITEM_CARRINHO também, apenas atualizar os valores
            UPDATE ITEM_CARRINHO SET QUANTIDADE = QUANTIDADE + QUANTIDADE_ADICIONADA WHERE COD_CARRINHO = COD_CART AND COD_PRODUTO = COD_ITEM;
            UPDATE ITEM_CARRINHO SET VALOR_TOTAL_ITEM = QUANTIDADE * VALOR_UNITARIO WHERE COD_CARRINHO = COD_CART AND COD_PRODUTO = COD_ITEM;
            SELECT QUANTIDADE INTO QUANTIDADE_ADICIONADA FROM ITEM_CARRINHO WHERE COD_CARRINHO = COD_CART AND COD_PRODUTO = COD_ITEM;
            MENSAGEM := format('O produto %1$s foi atualizado no carrinho (%2$s unidade(s)) com preço unitário de %3$s', NOME_ITEM, QUANTIDADE_ADICIONADA, VALOR_UNITARIO);
    END IF;

    SELECT ATUALIZAR_CARRINHO(COD_CART) INTO VALOR_TOTAL;
    SELECT VERIFICAR_COMPATIBILIDADE(COD_CART) INTO COMPAT;

    IF COMPAT IS NOT NULL THEN
        MENSAGEM := MENSAGEM || ' ' || COMPAT;
    END IF;

    RETURN MENSAGEM;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION REMOVER_ITEM(COD_CART INT, COD_ITEM INT, A_REMOVER INT)
RETURNS TEXT
AS $$
DECLARE
    QUANT_ATUAL INT;
    NOME_ITEM VARCHAR(60);
    VALOR_TOTAL DECIMAL(10,2);
    VALOR_UNITARIO DECIMAL(10,2);
BEGIN
    SELECT QUANTIDADE INTO QUANT_ATUAL FROM OBTER_CARRINHO(COD_CART) WHERE COD_PRODUTO = COD_ITEM;
    SELECT NOME INTO NOME_ITEM FROM OBTER_CARRINHO(COD_CART) WHERE COD_PRODUTO = COD_ITEM;
    SELECT VALOR INTO VALOR_UNITARIO FROM PRODUTO WHERE COD_PRODUTO = COD_ITEM;
    RAISE NOTICE 'Quantidade atual: % // A remover: % // Subtracao: %', QUANT_ATUAL, A_REMOVER, (QUANT_ATUAL - A_REMOVER);
    IF QUANT_ATUAL - A_REMOVER <= 0 THEN
        DELETE FROM ITEM_CARRINHO WHERE COD_CARRINHO = COD_CART AND COD_PRODUTO = COD_ITEM;
        SELECT ATUALIZAR_CARRINHO(COD_CART) INTO VALOR_TOTAL;
        RETURN format('O item %1$s foi removido do carrinho', NOME_ITEM, VALOR_TOTAL);
    ELSE
        UPDATE ITEM_CARRINHO SET QUANTIDADE = QUANTIDADE - A_REMOVER WHERE COD_CARRINHO = COD_CART AND COD_PRODUTO = COD_ITEM;
        UPDATE ITEM_CARRINHO SET VALOR_TOTAL_ITEM = (QUANTIDADE * VALOR_UNITARIO) WHERE COD_CARRINHO = COD_CART AND COD_PRODUTO = COD_ITEM;
        SELECT ATUALIZAR_CARRINHO(COD_CART) INTO VALOR_TOTAL;
        RETURN format('%1$s unidade(s) do item %2$s foi/foram removida(s) do carrinho, novo valor total: %3$s', A_REMOVER, NOME_ITEM, VALOR_TOTAL);
    END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION ATUALIZAR_CARRINHO(COD_CART INT)
RETURNS DECIMAL(10,2)
AS $$
DECLARE
    VALOR_TOTAL DECIMAL(10,2);
BEGIN
    SELECT SUM(VALOR_TOTAL_ITEM) INTO VALOR_TOTAL FROM ITEM_CARRINHO WHERE COD_CARRINHO = COD_CART;
    UPDATE CARRINHO SET VALOR_TOTAL_ITENS = VALOR_TOTAL WHERE COD_CARRINHO = COD_CART;
    RETURN VALOR_TOTAL;
END;
$$ LANGUAGE 'plpgsql';

SELECT ATUALIZAR_CARRINHO(1);

CREATE OR REPLACE FUNCTION OBTER_CARRINHO(COD_CART INT)
RETURNS TABLE(COD_PRODUTO INT, NOME VARCHAR(60), TIPO VARCHAR(60), VALOR DECIMAL(10,2), QUANTIDADE INT)
AS $$
BEGIN
    RETURN QUERY (SELECT CATALOGO.COD_PRODUTO, NOME_PRODUTO, DESCR_TIPO_PRODUTO, VALOR_TOTAL_ITEM, ITEM_CARRINHO.QUANTIDADE FROM ITEM_CARRINHO NATURAL JOIN CATALOGO INNER JOIN TIPO_PRODUTO ON CATALOGO.COD_TIPO_PRODUTO = TIPO_PRODUTO.COD_TIPO_PRODUTO WHERE COD_CARRINHO = COD_CART);
END;
$$ LANGUAGE 'plpgsql';

SELECT * FROM OBTER_CARRINHO(1)

CREATE OR REPLACE FUNCTION OBTER_CARRINHO(COD_FUNC INT, COD_CLI INT)
RETURNS INT
AS $$
DECLARE
   COD_CART INT;
BEGIN
    SELECT COD_CARRINHO INTO COD_CART FROM CARRINHO WHERE COD_CLIENTE = COD_CLI AND COD_FUNCIONARIO = COD_FUNC AND VENDA_FINALIZADA = FALSE;
    IF (COD_CART IS NULL) THEN
        INSERT INTO CARRINHO VALUES(DEFAULT, COD_CLI, COD_FUNC, NULL, 0.0, FALSE, CURRENT_DATE);
        SELECT COD_CARRINHO INTO COD_CART FROM CARRINHO WHERE COD_CLIENTE = COD_CLI AND COD_FUNCIONARIO = COD_FUNC AND VENDA_FINALIZADA = FALSE ORDER BY CURRENT_DATE DESC;
    END IF;
    RETURN COD_CART;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION PROCURAR_CLIENTE(CPF_CLIENTE VARCHAR(14))
RETURNS INT
AS $$
DECLARE
   COD_CLI INT;
BEGIN
    SELECT COD_CLIENTE INTO COD_CLI FROM CLIENTE NATURAL JOIN PESSOA WHERE CPF = CPF_CLIENTE;
    IF (COD_CLI IS NULL) THEN
        RAISE EXCEPTION 'O cliente não está cadastrado!';
    END IF;
    RETURN COD_CLI;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION PROCURAR_FUNCIONARIO(CPF_FUNCIONARIO VARCHAR(14))
RETURNS INT
AS $$
DECLARE
   COD_FUNC INT;
BEGIN
    SELECT COD_FUNCIONARIO INTO COD_FUNC FROM FUNCIONARIO NATURAL JOIN PESSOA WHERE CPF = CPF_FUNCIONARIO;
    IF (COD_FUNC IS NULL) THEN
        RAISE EXCEPTION 'O funcionário não está cadastrado!';
    END IF;
    RETURN COD_FUNC;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION PROCURAR_ITEM(NOME VARCHAR(60))
RETURNS INT
AS $$
DECLARE
   COD_ITEM INT;
BEGIN
    SELECT COD_PRODUTO INTO COD_ITEM FROM PRODUTO WHERE NOME_PRODUTO ILIKE NOME;
    IF (COD_ITEM IS NULL) THEN
        RAISE EXCEPTION 'O item desejado não está cadastrado!';
    END IF;
    RETURN COD_ITEM;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION OBTER_SALARIO_FUNCIONARIO(NOME VARCHAR(60))
RETURNS DECIMAL(10,2)
AS $$
DECLARE
    COD_FUNC INT;
    QUERY TEXT;
    LINE RECORD;
    SALARIO_FINAL DECIMAL(10,2);
    ACRESCIMO DECIMAL(10,2) := 0.0;
    TAXA_POR_VENDA DECIMAL(3,2) := 0.02;
BEGIN
    SELECT COD_FUNCIONARIO INTO COD_FUNC FROM FUNCIONARIO NATURAL JOIN PESSOA WHERE NOME_PESSOA ILIKE NOME;
    SELECT SALARIO INTO SALARIO_FINAL FROM FUNCIONARIO WHERE COD_FUNCIONARIO = COD_FUNC;
    QUERY := format('SELECT * FROM FUNCIONARIO NATURAL JOIN CARRINHO WHERE VENDA_FINALIZADA = TRUE AND COD_FUNCIONARIO = %1$s', COD_FUNC);
    FOR LINE IN EXECUTE QUERY LOOP
        ACRESCIMO := ACRESCIMO + (LINE.VALOR_TOTAL_ITENS * LINE.TAXA_POR_VENDA);
    END LOOP;
    RETURN SALARIO_FINAL + ACRESCIMO;
END;
$$ LANGUAGE 'plpgsql';

SELECT ADICIONAR_ITEM('444.444.444-44', '063.699.683-23', 'Ryzen 3 1100', 1);
SELECT * FROM OBTER_CARRINHO(OBTER_CARRINHO(PROCURAR_FUNCIONARIO('444.444.444-44'), PROCURAR_CLIENTE('063.699.683-23')));
SELECT REMOVER_ITEM(1, 9, 1);
--SELECT ADICIONAR_ITEM('Fulano da Silva', '063.699.683-23', 'GIGABYTE p/ Intel LGA 1151 mATX GA-H110M-H DDR4', 1);