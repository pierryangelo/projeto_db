﻿CREATE TABLE PESSOA (
    COD_PESSOA SERIAL PRIMARY KEY NOT NULL,
    NOME_PESSOA VARCHAR(60) NOT NULL,
    DT_NASC_PESSOA DATE,
    EMAIL_PESSOA VARCHAR(60) NOT NULL,
    CPF VARCHAR(14) NOT NULL
);

INSERT INTO PESSOA VALUES(DEFAULT, 'Gildásio Filho', '1998-01-30', 'gildasiogx@gmail.com', '063.699.683-23');
INSERT INTO PESSOA VALUES(DEFAULT, 'Gildásio Chagas', '1970-10-09', 'gildasiochagas@gmail.com', '333.333.333-23');
INSERT INTO PESSOA VALUES(DEFAULT, 'Fulano da Silva', '1988-05-20','fulaninho@hotmail.com', '222.222.222-22');
INSERT INTO PESSOA VALUES(DEFAULT, 'Maria Fulana', '1990-04-12','fulaninha@hotmail.com', '444.444.444-44');

CREATE TABLE CLIENTE (
    COD_CLIENTE SERIAL PRIMARY KEY NOT NULL,
    COD_PESSOA INT REFERENCES PESSOA(COD_PESSOA),
    VISIVEL BOOLEAN DEFAULT TRUE
);

INSERT INTO CLIENTE VALUES (DEFAULT, 1);
INSERT INTO CLIENTE VALUES (DEFAULT, 2);

CREATE TABLE FUNCIONARIO (
    COD_FUNCIONARIO SERIAL PRIMARY KEY NOT NULL,
    COD_PESSOA INT REFERENCES PESSOA(COD_PESSOA),
    SALARIO DECIMAL(10,2),
    VISIVEL BOOLEAN DEFAULT TRUE
);

INSERT INTO FUNCIONARIO VALUES(DEFAULT, 3, 940.00);
INSERT INTO FUNCIONARIO VALUES(DEFAULT, 4, 1200.00);

CREATE TABLE CUPOM (
    COD_CUPOM SERIAL PRIMARY KEY NOT NULL,
    IDENTIFICACAO VARCHAR(20),
    DESCONTO DECIMAL(3,2),
    DATA_EXPIRACAO DATE,
    USOS_DISPONIVEIS INT
);

CREATE TABLE TIPO_PAGAMENTO (
    COD_TIPO_PAGAMENTO SERIAL PRIMARY KEY NOT NULL,
    DESCRICAO VARCHAR(60),
    QUANT_DIAS_COMPENSA INT
);

INSERT INTO TIPO_PAGAMENTO VALUES(DEFAULT, 'CARTÃO DE CRÉDITO', 0);
INSERT INTO TIPO_PAGAMENTO VALUES(DEFAULT, 'CARTÃO DE DÉBITO', 1);
INSERT INTO TIPO_PAGAMENTO VALUES(DEFAULT, 'BOLETO BANCÁRIO', 2);
INSERT INTO TIPO_PAGAMENTO VALUES(DEFAULT, 'TRANSFERÊNCIA BANCÁRIA', 3);

CREATE TABLE CARRINHO (
    COD_CARRINHO SERIAL PRIMARY KEY NOT NULL,
    COD_CLIENTE INT NOT NULL REFERENCES CLIENTE(COD_CLIENTE),
    COD_FUNCIONARIO INT NOT NULL REFERENCES FUNCIONARIO(COD_FUNCIONARIO),
    COD_CUPOM INT REFERENCES CUPOM(COD_CUPOM),
    VALOR_TOTAL_ITENS DECIMAL(10,2),
    VENDA_FINALIZADA BOOLEAN,
    DATA_CRIACAO DATE
);

CREATE TABLE PAGAMENTO (
    COD_PAGAMENTO SERIAL PRIMARY KEY NOT NULL,
    COD_TIPO_PAGAMENTO INT NOT NULL REFERENCES TIPO_PAGAMENTO(COD_TIPO_PAGAMENTO),
    COD_CARRINHO INT NOT NULL REFERENCES CARRINHO(COD_CARRINHO),
    VALOR_TOTAL_CARRINHO DECIMAL(10,2),
    VALOR_PAGO DECIMAL(10,2),
    DATA_PAGO TIMESTAMP
);

CREATE TABLE MARCA (
    COD_MARCA SERIAL PRIMARY KEY NOT NULL,
    NOME_MARCA VARCHAR(60),
    TAXA_MARCA DECIMAL(3,2),
    VISIVEL BOOLEAN DEFAULT TRUE
);

INSERT INTO MARCA VALUES(DEFAULT, 'Intel', 0.0);
INSERT INTO MARCA VALUES(DEFAULT, 'AMD', 0.0);
INSERT INTO MARCA VALUES(DEFAULT, 'NVIDIA', 0.0);
INSERT INTO MARCA VALUES(DEFAULT, 'Corsair', 0.0);
INSERT INTO MARCA VALUES(DEFAULT, 'Kingston', 0.0);

CREATE TABLE TIPO_PRODUTO (
    COD_TIPO_PRODUTO SERIAL PRIMARY KEY NOT NULL,
    DESCR_TIPO_PRODUTO VARCHAR(100)
);

INSERT INTO TIPO_PRODUTO VALUES(DEFAULT, 'Placa-mãe');
INSERT INTO TIPO_PRODUTO VALUES(DEFAULT, 'Processador');
INSERT INTO TIPO_PRODUTO VALUES(DEFAULT, 'Memória RAM');
INSERT INTO TIPO_PRODUTO VALUES(DEFAULT, 'Placa de vídeo');

CREATE TABLE CATEGORIA (
    COD_CATEGORIA SERIAL PRIMARY KEY NOT NULL,
    COD_MARCA INT NOT NULL REFERENCES MARCA(COD_MARCA),
    COD_TIPO_PRODUTO INT NOT NULL REFERENCES TIPO_PRODUTO(COD_TIPO_PRODUTO),
    NOME_CATEGORIA VARCHAR(60),
    TAXA_CATEGORIA DECIMAL(3,2),
    VISIVEL BOOLEAN DEFAULT TRUE
);

INSERT INTO CATEGORIA VALUES(DEFAULT, 1, 2, 'Core i3', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 1, 2, 'Core i5', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 1, 2, 'Core i7', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 1, 2, 'Pentium', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 2, 2, 'Ryzen 3', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 2, 2, 'Ryzen 5', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 2, 2, 'Ryzen 7', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 2, 4, 'Radeon RX', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 2, 2, 'FX', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 3, 4, 'GTX 1060', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 3, 4, 'GTX 1070', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 3, 4, 'GTX 1080', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 3, 4, 'GTX 980', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 3, 4, 'GTX 750 Ti', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 1, 1, 'LGA DDR4 p/ Intel', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 1, 1, 'LGA DDR3 p/ Intel', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 2, 1, 'AM3+ DDR3 p/ AMD', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 4, 3, 'Vengeance DDR3', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 4, 3, 'Vengeance DDR4', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 5, 3, 'HyperX FURY DDR3', 0.0);
INSERT INTO CATEGORIA VALUES(DEFAULT, 5, 3, 'HyperX FURY DDR4', 0.0);

CREATE TABLE PRODUTO (
    COD_PRODUTO SERIAL PRIMARY KEY NOT NULL,
    COD_CATEGORIA INT NOT NULL REFERENCES CATEGORIA(COD_CATEGORIA),
    NOME_PRODUTO VARCHAR(60),
    DESCR TEXT,
    VALOR DECIMAL(10,2),
    QUANT_ESTOQUE INT,
    TAXA_PRODUTO DECIMAL(3,2),
    VISIVEL BOOLEAN DEFAULT TRUE
);

INSERT INTO PRODUTO VALUES(DEFAULT, 1, 'Intel Core i3-6100 Skylake', 'Processador Dual-core/4 threads', 499.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 1, 'Intel Core i3-7100 Kaby Lake', 'Processador Dual-core/4 threads', 469.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 2, 'Intel Core i5-7400 Kaby Lake', 'Processador Quad-core/4 threads', 739.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 2, 'Intel Core i5-7600K Kaby Lake', 'Processador Quad-core/4 threads', 939.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 3, 'Intel Core i7-6700K Skylake', 'Processador Quad-core/8 threads', 1339.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 3, 'Intel Core i7-7700K Kaby Lake', 'Processador Quad-core/8 threads', 1499.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 4, 'Intel Pentium G3260 Haswell', 'Processador Dual-core/2 threads', 249.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 4, 'Intel Pentium G4500 Skylake', 'Processador Dual-core/4 threads', 329.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 5, 'Ryzen 3 1100', 'Processador Quad-core/4 threads', 400, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 5, 'Ryzen 3 1200X', 'Processador Quad-core/4 threads', 470, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 6, 'Ryzen 5 1400', 'Processador Quad-core/8 threads', 699.99, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 6, 'Ryzen 5 1500X', 'Processador Quad-core/8 threads', 799.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 6, 'Ryzen 5 1600', 'Processador Hexa-core/12 threads', 979.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 6, 'Ryzen 5 1600X', 'Processador Hexa-core/12 threads', 1059.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 7, 'Ryzen 7 1700', 'Processador Octa-core/16 threads', 1349.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 7, 'Ryzen 7 1700X', 'Processador Octa-core/16 threads', 1629.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 7, 'Ryzen 7 1800X', 'Processador Octa-core/16 threads', 2099.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 8, 'Radeon RX 460 - 2GB', 'Placa de vídeo com 2GB VRAM', 399.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 8, 'Radeon RX 460 - 4GB', 'Placa de vídeo com 4GB VRAM', 599.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 8, 'Radeon RX 470 - 4GB', 'Placa de vídeo com 4GB VRAM', 899.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 8, 'Radeon RX 480 - 4GB', 'Placa de vídeo com 4GB VRAM', 999.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 8, 'Radeon RX 480 - 8GB', 'Placa de vídeo com 8GB VRAM', 1399.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 9, 'FX 4300', 'Processador Quad-core/4 threads', 359.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 9, 'FX 6300', 'Processador Hexa-core/12 threads', 399.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 9, 'FX 8300', 'Processador Octa-core/16 threads', 449.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 10, 'GIGABYTE GTX 1060 - 6GB', 'Placa de vídeo com 6GB VRAM', 1149.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 10, 'ASUS GTX 1060 - 6GB', 'Placa de vídeo com 6GB VRAM', 1069.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 11, 'GIGABYTE GTX 1070 - 8GB', 'Placa de vídeo com 8GB VRAM', 1849.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 11, 'EVGA GTX 1070 - 8GB', 'Placa de vídeo com 8GB VRAM', 1699.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 12, 'EVGA GTX 1080 - 8GB', 'Placa de vídeo com 8GB VRAM', 2349.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 13, 'GIGABYTE GTX 980 - 4GB', 'Placa de vídeo com 4GB VRAM', 2049.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 13, 'EVGA GTX 980 - 4GB', 'Placa de vídeo com 4GB VRAM', 1999.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 14, 'ASUS GTX 750 Ti - 2GB', 'Placa de vídeo com 2GB VRAM', 574.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 14, 'GIGABYTE GTX 750 Ti - 2GB', 'Placa de vídeo com 2GB VRAM', 499.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 15, 'GIGABYTE p/ Intel LGA 1151 mATX GA-H110M-H DDR4', 'Placa-mãe para processadores Intel e memórias RAM DDR4', 349.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 16, 'MSI p/ Intel LGA 1150 ATX B85-G43 GAMING DDR3', 'Placa-mãe para processadores Intel e memórias RAM DDR3', 359.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 17, 'ASRock p/ AMD AM3+ ATX 970A-G/3.1 DDR3', 'Placa-mãe para processadores AMD e memórias RAM DDR3', 459.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 18, 'Corsair Vengeance 4GB 1600Mhz DDR3', 'Memória RAM DDR3', 179.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 19, 'Corsair Vengeance 8GB 2133MHz DDR4', 'Memória RAM DDR4', 337.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 20, 'HyperX FURY 4GB 1333Mhz DDR3', 'Memória RAM DDR3', 169.90, 10, 0.0);
INSERT INTO PRODUTO VALUES(DEFAULT, 21, 'HyperX FURY 4GB 2666Mhz DDR4', 'Memória RAM DDR4', 169.90, 10, 0.0);

CREATE TABLE COMPATIBILIDADE (
    COD_CATEGORIA_PRIMARIA INT NOT NULL REFERENCES CATEGORIA(COD_CATEGORIA),
    COD_CATEGORIA_SECUNDARIA INT NOT NULL REFERENCES CATEGORIA(COD_CATEGORIA)
);

INSERT INTO COMPATIBILIDADE VALUES(15, 1);
INSERT INTO COMPATIBILIDADE VALUES(15, 2);
INSERT INTO COMPATIBILIDADE VALUES(15, 3);
INSERT INTO COMPATIBILIDADE VALUES(15, 4);
INSERT INTO COMPATIBILIDADE VALUES(15, 19);
INSERT INTO COMPATIBILIDADE VALUES(15, 21);
INSERT INTO COMPATIBILIDADE VALUES(16, 1);
INSERT INTO COMPATIBILIDADE VALUES(16, 2);
INSERT INTO COMPATIBILIDADE VALUES(16, 3);
INSERT INTO COMPATIBILIDADE VALUES(16, 4);
INSERT INTO COMPATIBILIDADE VALUES(16, 18);
INSERT INTO COMPATIBILIDADE VALUES(16, 20);
INSERT INTO COMPATIBILIDADE VALUES(17, 5);
INSERT INTO COMPATIBILIDADE VALUES(17, 6);
INSERT INTO COMPATIBILIDADE VALUES(17, 7);
INSERT INTO COMPATIBILIDADE VALUES(17, 9);
INSERT INTO COMPATIBILIDADE VALUES(17, 18);
INSERT INTO COMPATIBILIDADE VALUES(17, 20);

CREATE TABLE ITEM_CARRINHO (
    COD_PRODUTO INT NOT NULL REFERENCES PRODUTO(COD_PRODUTO),
    COD_CARRINHO INT NOT NULL REFERENCES CARRINHO(COD_CARRINHO),
    VALOR_TOTAL_ITEM DECIMAL(10,2),
    QUANTIDADE INT
);

CREATE OR REPLACE VIEW CATALOGO AS SELECT * FROM PRODUTO NATURAL JOIN CATEGORIA NATURAL JOIN MARCA;

-- SELECT * FROM CATALOGO