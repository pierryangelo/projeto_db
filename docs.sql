-- Sobre funções na ordem que estão declaradas no arquivo functions.sql

-- DESCONTO_APLICADO(NOME VARCHAR(60), PORCENTAGEM DECIMAL(3,2)) RETURNS TEXT
-- Uma função de suporte feita para evitar acumulo de IF para retornar um TEXT simples, apenas formata a frase de retorno se o desconto foi aplicado ou retirado em um determinado produto, categoria ou marca, ela é chamada como retorno das duas funções abaixo

-- APLICAR_DESCONTO(TIPO VARCHAR(15), NOME VARCHAR(60), PORCENTAGEM(3,2)) RETURNS TEXT
-- Aplica uma taxa de desconto a um produto, marca ou categoria, que tem efeito sobre o preço do produto ao adicionar no carrinho, funciona verificando que tipo foi digitado e em seguida fazendo um UPDATE no respectivo campo, não sem verificar a existência do item desejado
-- USO:
SELECT APLICAR_DESCONTO('MARCA', 'Intel', 0.1);

-- RESETAR_DESCONTO(TIPO VARCHAR(15), NOME VARCHAR(60)) RETURNS TEXT
-- Apenas chama a função descrita acima passando 0.0 na porcentagem
-- USO:
SELECT RESETAR_DESCONTO('MARCA', 'Intel');

-- OBTER_PRECO_DESCONTADO(COD_ITEM INT) RETURNS DECIMAL(10,2)
-- Retorna o preço do produto com o respectivo desconto, se houver. A ordem de privilégio é produto > categoria > marca, ou seja, por mais que haja uma promoção na marca Intel inteira, o desconto da categoria Core i7 vale mais, e o mesmo para o respectivo produto.
-- USO:
SELECT OBTER_PRECO_DESCONTADO(1);

-- VERIFICAR_COMPATIBILIDADE(COD_CART INT) RETURNS TEXT
-- Caso haja alguma placa-mãe no carrinho passado como parâmetro, essa função verificará se os componentes em seguida (e atuais) são compatíveis com ela e adicionará um aviso à mensagem mostrada ao adicionar um produto no carrinho atual. Ela funciona apenas de aviso, já que apesar de tudo, o usuário ainda pode comprar várias placas-mãe e vários processadores diferentes
-- USO:
SELECT VERIFICAR_COMPATIBILIDADE(1);

-- ADICIONAR_ITEM(CPF_FUNCIONARIO VARCHAR(14), CPF_CLIENTE VARCHAR(14), NOME_ITEM VARCHAR(60), QUANTIDADE_ADICIONADA INT) RETURNS TEXT
-- Adiciona um produto ao carrinho atual do cliente com aquele funcionário, que é sempre o mesmo até que sua venda seja concretizada. Caso concretizada, um novo carrinho será feito. Tal função adiciona o item ao carrinho caso não esteja lá e o atualiza caso já esteja, também atualizando o valor total do carrinho a cada operação e verificando a compatibilidade geral do mesmo
-- USO:
SELECT ADICIONAR_ITEM('444.444.444-44', '063.699.683-23', 'Ryzen 3 1100', 3);

-- REMOVER_ITEM(COD_CART INT, COD_ITEM INT, A_REMOVER INT) RETURNS TEXT
-- Faz basicamente o oposto da anterior, removendo o item caso a quantidade fique igual a zero ou apenas atualizando a listagem e o preço total do carrinho
-- USO:
SELECT REMOVER_ITEM(1, 9, 1);

-- ATUALIZAR_CARRINHO(COD_CART INT) RETURNS DECIMAL(10,2)
-- Função que atualiza o valor total do carrinho fazendo a soma dos itens relacionados em ITEM_CARRINHO e retorna o valor calculado
-- USO:
SELECT ATUALIZAR_CARRINHO(1);

-- OBTER_CARRINHO(COD_CART INT) RETURNS TABLE(COD_PRODUTO INT, NOME VARCHAR(60), TIPO VARCHAR(60), VALOR DECIMAL(10,2), QUANTIDADE INT)
-- Retorna uma tabela customizada com apenas os itens relacionados, seu tipo e quantidade, além do valor total do carrinho passado como parâmetro
-- USO:
SELECT OBTER_CARRINHO(1);

-- OBTER_CARRINHO(COD_FUNC INT, COD_CLI INT) RETURNS INT
-- Agora recebendo o código do funcionário e o código do cliente, essa função passa a criar o carrinho do respectivo par ou retorna o código do carrinho já em andamento e que não esteja com a venda finalizada
-- USO:
SELECT OBTER_CARRINHO(1, 1);

-- PROCURAR_CLIENTE(CPF_CLIENTE VARCHAR(14)) RETURNS INT
-- Procura e retorna o código do cliente, caso exista, com o respectivo CPF passado como parâmetro
-- USO:
SELECT PROCURAR_CLIENTE('063.699.683-23');

-- PROCURAR_FUNCIONARIO(CPF_CLIENTE VARCHAR(14)) RETURNS INT
-- Procura e retorna o código do funcionário, caso exista, com o respectivo CPF passado como parâmetro
-- USO:
SELECT PROCURAR_FUNCIONARIO('444.444.444-44');

-- PROCURAR_ITEM(NOME VARCHAR(60)) RETURNS INT
-- Procura e retorna o código do produto, caso exista, de acordo com o nome repassado, tal nome não precisa ser idêntico ao original do produto e pode conter apenas o começo ou o final
-- USO:
SELECT PROCURAR_ITEM('Corsair Vengeance 8GB');

-- PROCURAR_TIPO_PAGAMENTO(NOME VARCHAR(60)) RETURNS INT
-- Procura e retorna o tipo do pagamento com base no nome dado, que também não precisa ser idêntico ao original. Colocar 'CRÉDITO' na busca retornará o código do tipo 'CARTÃO DE CRÉDITO', por exemplo.
-- USO:
SELECT PROCURAR_TIPO_PAGAMENTO('CRÉDITO');

-- OBTER_SALARIO_FUNCIONARIO(CPF VARCHAR(60)) RETURNS DECIMAL(10,2)
-- A primeira variação dessa função recebe apenas o CPF do funcionário, retornando o seu salário padrão com um acréscimo de 2% no valor de cada venda que ele realizou no mês/ano atual
-- USO:
SELECT OBTER_SALARIO_FUNCIONARIO('444.444.444-44');

-- OBTER_SALARIO_FUNCIONARIO(CPF VARCHAR(60), MES INT) RETURNS DECIMAL(10,2)
-- A segunda variação dessa função recebe o CPF do funcionário e um valor inteiro correspondendo ao mês do ano atual, retornando o seu salário padrão com um acréscimo de 2% no valor de cada venda que ele realizou no mês passado como parâmetro
-- USO:
SELECT OBTER_SALARIO_FUNCIONARIO('444.444.444-44', 4);

-- OBTER_SALARIO_FUNCIONARIO(CPF VARCHAR(60), MES INT, ANO INT) RETURNS DECIMAL(10,2)
-- A terceira variação dessa função recebe o CPF, mês e o ano, retornando o valor do salário com um acréscimo de 2% no valor de cada venda que ele realizou no respectivo mês/ano passados nos parâmetros
-- USO:
SELECT OBTER_SALARIO_FUNCIONARIO('444.444.444-44', 4, 2017);

-- CRIAR_CUPOM(ID_CUPOM VARCHAR(20), TAXA DECIMAL(3,2), DATA_LIMITE DATE, USOS INT) RETURNS TEXT
-- Cria um cupom de desconto com os parâmetros fornecidos, caso forneça um identificador que já foi utilizado anteriormente, este terá seus dados atualizados (exceto o código, obviamente)
-- USO:
SELECT CRIAR_CUPOM('2017DESCONTO10', 0.1, '2017-04-20', 20);

-- CONTABILIZAR_CUPOM(COD_CUP INT) RETURNS VOID
-- Faz a contabilização de usos disponíveis e/ou zera tal quantidade caso necessário, é utilizada apenas na função de realizar pagamento
-- USO:
SELECT CONTABILIZAR_CUPOM(1);

-- OBTER_CUPOM(ID_CUPOM VARCHAR(20)) RETURNS INT
-- Retorna o código do cupom com base na identificação passada como parâmetro
-- USO:
SELECT OBTER_CUPOM('2017DESCONTO10');

-- OBTER_VALOR_TOTAL_CARRINHO(COD_CART INT) RETURNS DECIMAL(10,2)
-- Retorna o preço final do carrinho já com o desconto do cupom, caso exista algum relacionado ao carrinho
-- USO:
SELECT OBTER_VALOR_TOTAL_CARRINHO(1);

-- REALIZAR_PAGAMENTO(COD_CART INT, FORMA VARCHAR(60), VALOR_RECEBIDO DECIMAL(10,2), ID_CUPOM VARCHAR(20)) RETURNS TEXT
-- Faz o procedimento de pagamento para um carrinho, recebendo uma forma, um valor e um cupom. É possível pagar um mesmo carrinho de várias formas até que o valor total desde esteja finalizado, quando isso ocorrer, a flag de VENDA_FINALIZADA no carrinho fica TRUE e o cupom relacionado, caso exista, é contabilizado
-- USO:
SELECT REALIZAR_PAGAMENTO(1, 'DÉBITO', 800.00, '2017DESCONTO10');

-- REALIZAR_PAGAMENTO(COD_CART INT, FORMA VARCHAR(60), VALOR_RECEBIDO DECIMAL(10,2)) RETURNS TEXT
-- Mesma função acima só que sem um cupom, caso não haja necessidade de usar algum
-- USO:
SELECT REALIZAR_PAGAMENTO(1, 'DÉBITO', 800.00);

-- STATUS_CARRINHO(COD_CART INT) RETURNS TEXT
-- Retorna um TEXT que é uma frase explicando qual cliente e qual funcionário está relacionado ao carrinho, além da quantidade total de itens e seu valor final
-- USO:
SELECT STATUS_CARRINHO(1);

-- GERENCIAR_CLIENTE(NOME VARCHAR(60), DT_NASC DATE, EMAIL VARCHAR(60), CPF_N VARCHAR(14)) RETURNS TEXT
-- Função para criar e atualizar clientes, recebendo todos os parâmetros deste e criando os respectivos valores nas tabelas PESSOA e CLIENTE, ou atualizando-os
-- USO:
SELECT GERENCIAR_CLIENTE('Gildásio de Lima Filho', '1998-01-30', 'gildasiogx@gmail.com', '063.699.683-23');

-- GERENCIAR_FUNCIONARIO(NOME VARCHAR(60), DT_NASC DATE, EMAIL VARCHAR(60), CPF_N VARCHAR(14), SALARIO_N DECIMAL(10,2)) RETURNS TEXT
-- Função para criar e atualizar funcionários, recebendo todos os parâmetros deste e criando os respectivos valores nas tabelas PESSOA e CLIENTE, ou atualizando-os
-- USO:
SELECT GERENCIAR_FUNCIONARIO('Fulano da Silva', '1988-05-20','fulaninho@hotmail.com', '222.222.222-22', 950.00);

-- REMOVER_FUNCIONARIO(CPF_FUNCIONARIO VARCHAR(14)) RETURNS TEXT
-- Função para tornar invisível o funcionário para todas as pesquisas relacionadas a ele, facilitando guardar o registro das vendas realizadas por ele e também ver seu respectivo histórico
-- USO:
SELECT REMOVER_FUNCIONARIO('222.222.222-22');

-- REMOVER_CLIENTE(CPF_CLIENTE VARCHAR(14)) RETURNS TEXT
-- Função para tornar invisível o cliente para todas as pesquisas relacionadas a ele, facilitando guardar o registro das compras realizadas por ele e também ver seu respectivo histórico
-- USO:
SELECT REMOVER_CLIENTE('333.333.333-33');

-- PROCURAR_CATEGORIA(NOME VARCHAR(60)) RETURNS INT
-- Função para pesquisa do código da categoria com base no seu respectivo nome, caso esteja visível
-- USO:
SELECT PROCURAR_CATEGORIA('Ryzen 3');

-- PROCURAR_MARCA(NOME VARCHAR(60)) RETURNS INT
-- Função para pesquisa do código da marca com base no seu respectivo nome, caso esteja visível
-- USO:
SELECT PROCURAR_MARCA('AMD');

-- REMOVER_CATEGORIA(NOME VARCHAR(60)) RETURNS TEXT
-- Semelhante às outras remoções, apenas torna invisível para pesquisas à marca relacionada pelo nome
-- USO:
SELECT REMOVER_CATEGORIA('Ryzen 3');

-- REMOVER_MARCA(NOME VARCHAR(60)) RETURNS TEXT
-- Semelhante às outras remoções, apenas torna invisível para pesquisas à categoria relacionada pelo nome
-- USO:
SELECT REMOVER_MARCA('AMD')

-- GERENCIAR_PRODUTO(NOME VARCHAR(60), NOVO_NOME VARCHAR(60), CATEG INT, DESCRICAO TEXT, QUANT_ESTQ INT) RETURNS TEXT
-- Função para criar novos produtos e/ou atualizar os existentes com base nos dados fornecidos
-- USO:
SELECT GERENCIAR_PRODUTO('Ryzen 3 1100', 'Ryzen 3 1100X', PROCURAR_CATEGORIA('Ryzen 3'), 'Processador AMD', 10);

-- GERENCIAR_MARCA(NOME VARCHAR(60), NOVO_NOME VARCHAR(60)) RETURNS TEXT
-- Função para criar uma nova marca ou trocar o nome da existente com base nos dados fornecidos
-- USO:
SELECT GERENCIAR_MARCA('AMD', 'AMD2');
SELECT GERENCIAR_MARCA('Nova marca', NULL);

-- GERENCIAR_CATEGORIA(NOME VARCHAR(60), NOVO_NOME VARCHAR(60), MARC INT) RETURNS TEXT
-- Função para criar uma nova categoria ou trocar o nome da existente com base nos dados fornecidos
SELECT GERENCIAR_CATEGORIA('Ryzen 3', NULL, PROCURAR_MARCA('AMD'));
SELECT GERENCIAR_CATEGORIA('Ryzen 3_2', NULL, PROCURAR_MARCA('AMD'));

-- Exemplo de uma operações:

SELECT * FROM CLIENTE NATURAL JOIN PESSOA
SELECT REMOVER_CLIENTE('333.333.333-23');
SELECT GERENCIAR_CLIENTE('Gildásio Chagas', '1970-10-09', 'gildasiochagas@gmail.com', '333.333.333-23');

-- Quatro produtos são adicionados, três processadores AMD e uma placa-mãe p/ Intel
SELECT ADICIONAR_ITEM('444.444.444-44', '063.699.683-23', 'Ryzen 3 1100', 3);
SELECT ADICIONAR_ITEM('444.444.444-44', '063.699.683-23', 'GIGABYTE p/ Intel LGA 1151', 1);

-- O segundo ADICIONAR_ITEM faz com que um aviso seja mostrado como mensagem de que a placa-mãe adicionada não é compatível com o processador que já está no carrinho, então ela é removida
SELECT REMOVER_ITEM(1, 35, 1);

-- Um status do carrinho é mostrado
SELECT STATUS_CARRINHO(OBTER_CARRINHO(PROCURAR_FUNCIONARIO('444.444.444-44'), PROCURAR_CLIENTE('063.699.683-23')));

-- O pagamento é feito utilizando um cupom de 10% de desconto, então a função mostrará que há troco a ser recebido
SELECT REALIZAR_PAGAMENTO(1, 'DÉBITO', 1200.00, '2017DESCONTO10');

-- Por fim, vemos que o funcionário ganhou um bônus no salário de acordo com a venda concretizada
SELECT OBTER_SALARIO_FUNCIONARIO('444.444.444-44');