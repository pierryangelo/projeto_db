﻿-- Créditos ao Lucas (@spallacety)
CREATE OR REPLACE FUNCTION INSERT(table TEXT, value TEXT, hasPrimaryKey BOOLEAN) 
RETURNS VOID 
AS $$
	DECLARE
	    query TEXT := 'INSERT INTO ' || table || ' VALUES (' || value || ');';
	BEGIN
        IF hasPrimaryKey = TRUE THEN
            query := 'INSERT INTO ' || table || ' VALUES (DEFAULT, ' || value || ');';
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
RETURNS void
AS $$
DECLARE
   COD_PLACA INT;
   COD_PROD INT;
   COUNTER INT := 0;
   PRODUTOS TEXT;
   LINHA RECORD;
BEGIN
    SELECT COD_CATEGORIA INTO COD_PLACA FROM ITEM_CARRINHO NATURAL JOIN TIPO_PRODUTO NATURAL JOIN CATEGORIA WHERE COD_CARRINHO = COD_CART AND DESCR_TIPO_PRODUTO = 'Placa-mãe';
    PRODUTOS := format('(SELECT * FROM ITEM_CARRINHO NATURAL JOIN CATEGORIA WHERE COD_CARRINHO = %1$s);', COD_CART);
    FOR LINHA IN EXECUTE PRODUTOS LOOP
        IF (SELECT COUNT(*) FROM COMPATIBILIDADE WHERE COD_CATEGORIA_PRIMARIA = COD_PLACA AND COD_CATEGORIA_SECUNDARIA = LINHA.COD_CATEGORIA) = 0 THEN
            COUNTER := COUNTER + 1;
        END IF;
    END LOOP;
    IF COUNTER > 0 THEN
        RAISE NOTICE 'Há produtos incompatíveis no carrinho!';
    END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION ADICIONAR_ITEM(NOME_FUNC VARCHAR(60), CPF_CLIENTE VARCHAR(14), NOME_ITEM VARCHAR(60), QUANTIDADE_ADICIONADA INT) 
RETURNS void 
AS $$
DECLARE
    COD_ITEM INT;
    COD_FUNC INT;
    COD_CART INT;
    COD_CLI INT;
    VALOR_UNITARIO DECIMAL(10,2);
    VALOR_TOTAL DECIMAL(10,2);
BEGIN
    -- Inicialização de variáveis
    SELECT COD_PRODUTO INTO COD_ITEM FROM PRODUTO WHERE NOME_PRODUTO ILIKE NOME_ITEM;
    SELECT OBTER_PRECO_DESCONTADO(COD_ITEM) INTO VALOR_UNITARIO;
    SELECT COD_CLIENTE INTO COD_CLI FROM CLIENTE NATURAL JOIN PESSOA WHERE CPF = CPF_CLIENTE;
    SELECT COD_FUNCIONARIO INTO COD_FUNC FROM FUNCIONARIO NATURAL JOIN PESSOA WHERE NOME_PESSOA ILIKE NOME_FUNC;
    SELECT COD_CARRINHO INTO COD_CART FROM CARRINHO WHERE COD_CLIENTE = COD_CLI AND VENDA_FINALIZADA = FALSE;
    -- Se carrinho não existe, criar carrinho
    IF COD_CART IS NULL THEN
        INSERT INTO CARRINHO VALUES(DEFAULT, COD_CLI, COD_FUNC, NULL, 0.0, FALSE, CURRENT_DATE);
        SELECT COD_CARRINHO INTO COD_CART FROM CARRINHO WHERE COD_CLIENTE = COD_CLI AND VENDA_FINALIZADA = FALSE;
        INSERT INTO ITEM_CARRINHO VALUES(COD_ITEM, COD_CART, VALOR_UNITARIO * QUANTIDADE_ADICIONADA, QUANTIDADE_ADICIONADA);
    ELSE -- Se já existe e o ITEM_CARRINHO não foi adicionado ainda, apenas inserir
        IF (SELECT COUNT(*) FROM ITEM_CARRINHO WHERE COD_CARRINHO = COD_CART AND COD_PRODUTO = COD_ITEM) = 0 THEN
            INSERT INTO ITEM_CARRINHO VALUES(COD_ITEM, COD_CART, VALOR_UNITARIO * QUANTIDADE_ADICIONADA, QUANTIDADE_ADICIONADA);
        ELSE -- Se já existe e o ITEM_CARRINHO também, apenas atualizar os valores
            UPDATE ITEM_CARRINHO SET QUANTIDADE = QUANTIDADE + QUANTIDADE_ADICIONADA WHERE COD_CARRINHO = COD_CART AND COD_PRODUTO = COD_ITEM;
            UPDATE ITEM_CARRINHO SET VALOR_TOTAL_ITEM = QUANTIDADE * VALOR_UNITARIO WHERE COD_CARRINHO = COD_CART AND COD_PRODUTO = COD_ITEM;
        END IF;
    END IF;
    SELECT SUM(VALOR_TOTAL_ITEM) INTO VALOR_TOTAL FROM ITEM_CARRINHO WHERE COD_CARRINHO = COD_CART;
    UPDATE CARRINHO SET VALOR_TOTAL_ITENS = VALOR_TOTAL WHERE COD_CARRINHO = COD_CART;
    PERFORM VERIFICAR_COMPATIBILIDADE(COD_CART);
    -- UPDATE PRODUTO SET QUANT_ESTOQUE = QUANT_ESTOQUE - QUANTIDADE_ADICIONADA WHERE COD_PRODUTO = COD_ITEM;
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
    SALARIO_FINAL DECIMAL(10,2);
    ACRESCIMO DECIMAL(10,2) := 0.0;
    TAXA_POR_VENDA DECIMAL(3,2) := 0.02;
BEGIN
    SELECT COD_FUNCIONARIO INTO COD_FUNC FROM FUNCIONARIO NATURAL JOIN PESSOA WHERE NOME_PESSOA ILIKE NOME;
    SELECT SALARIO INTO SALARIO_FINAL FROM FUNCIONARIO WHERE COD_FUNCIONARIO = COD_FUNC;
    QUERY := format('SELECT * FROM FUNCIONARIO NATURAL JOIN CARRINHO WHERE VENDA_FINALIZADA = TRUE AND COD_FUNCIONARIO = %1$s', COD_FUNC);
    FOR LINHA IN EXECUTE QUERY LOOP
        ACRESCIMO := ACRESCIMO + (LINHA.VALOR_TOTAL_ITENS * LINHA.TAXA_POR_VENDA);
    END LOOP;
    RETURN SALARIO_FINAL + ACRESCIMO;
END;
$$ LANGUAGE 'plpgsql';

SELECT ADICIONAR_ITEM('Fulano da Silva', '063.699.683-23', 'Ryzen 3 1100', 1);
SELECT ADICIONAR_ITEM('Fulano da Silva', '063.699.683-23', 'GIGABYTE p/ Intel LGA 1151 mATX GA-H110M-H DDR4', 1);
