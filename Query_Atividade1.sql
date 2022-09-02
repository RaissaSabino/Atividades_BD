CREATE DATABASE Loja_DB;
GO

USE Loja_DB;
GO


/* Tabelas */

CREATE TABLE Produto(
Id INT IDENTITY PRIMARY KEY,
Nome VARCHAR(100) NOT NULL,
DataValidade DATE NOT NULL,
Preco DECIMAL(9, 3) NOT NULL
);

CREATE TABLE Estoque(
Id INT IDENTITY PRIMARY KEY,
Quantidade INT NOT NULL,
ProdutoId INT FOREIGN KEY REFERENCES Produto(Id)
);

CREATE TABLE Cliente(
Id INT IDENTITY PRIMARY KEY,
Nome VARCHAR(MAX) NOT NULL,
Cpf VARCHAR(11) NOT NULL
);

CREATE TABLE Vendedor(
Id INT IDENTITY PRIMARY KEY,
Nome VARCHAR(MAX) NOT NULL,
Cpf VARCHAR(11) NOT NULL,
DataDeAdmissao DATE,
Ativo BIT
);

CREATE TABLE Comissao(
Id INT IDENTITY PRIMARY KEY,
Mes INT NOT NULL,
Ano INT NOT NULL,
ValorComissao DECIMAL(19,3),
VendedorId INT NOT NULL FOREIGN KEY REFERENCES Vendedor(Id)
);

CREATE TABLE Venda(
Id INT IDENTITY PRIMARY KEY,
Quantidade  INT NOT NULL,
DataVenda DATE NOT NULL,
PrecoFinal DECIMAL(19,3),
ProdutoId INT FOREIGN KEY REFERENCES Produto(Id),
VendedorId INT NOT NULL FOREIGN KEY REFERENCES Vendedor(Id),
ClienteId INT NOT NULL FOREIGN KEY REFERENCES Vendedor(Id),
);


INSERT INTO Produto(Nome, DataValidade, Preco)
VALUES 
('BATATA', GETDATE() + 20, '200'),
('POLENTA', GETDATE() + 200, '100'), 
('FRANGO', GETDATE() + 10, '25'),
('SASSAMI', GETDATE() + 5, '36'),
('ARROZ', GETDATE() + 9, '42'),
('TRIGO', GETDATE() + 8, '52'),
('FEIJAO', GETDATE() + 7, '77'), 
('FAROFA', GETDATE() + 92, '88')

SELECT * FROM Produto

INSERT INTO Estoque(Quantidade, ProdutoId)
VALUES 
(51, 1),
(515, 2),
(7856, 3),
(5781, 4),
(7, 5),
(86, 6),
(782, 7),
(782, 8)

SELECT * FROM Estoque

INSERT INTO Cliente(Nome, Cpf)
VALUES 
('Raissa Sabino', 12563835627),
('Nathan Cordeiro', 42563558962),
('Steicy Santos', 14552836521)

SELECT * FROM Cliente

INSERT INTO Vendedor(Nome,Cpf,DataDeAdmissao,Ativo) 
VALUES 
('Alison Castagnoli', 11235496585, GETDATE() - 300, 1),
('João Pedro Faria', 11235496554, GETDATE() - 350, 1),
('Cralos Costa', 11235496598, GETDATE() - 390, 1)

SELECT * FROM Vendedor

INSERT INTO Comissao(Mes,Ano,ValorComissao,VendedorId) 
VALUES 
(12,2022,500,1),
(11,2022,500,1),
(12,2022,500,1),
(10,2022,500,2),
(8,2022,500,2),
(9,2022,500,2),
(5,2022,500,3),
(7,2022,500,3),
(9,2022,500,3)

SELECT * FROM Comissao

INSERT INTO Venda(Quantidade,DataVenda,PrecoFinal,ProdutoId,VendedorId,ClienteId) 
VALUES 
(1, GETDATE(), 200, 1, 1, 1),
(1, GETDATE(), 100, 2, 1, 1),
(1, GETDATE(), 25, 3, 1, 1),
(1, GETDATE(), 36, 4, 2, 2),
(1, GETDATE(), 42, 5, 2, 2),
(1, GETDATE(), 52, 6, 3, 2),
(1, GETDATE(), 77, 7, 3, 3),
(1, GETDATE(), 88, 8, 3, 3)

SELECT * FROM Venda

CREATE PROCEDURE GetProdVendas AS BEGIN
select produto.Id, produto.nome, sum(venda.quantidade) as 'quantidade' from produto
inner join venda on venda.ProdutoId = produto.id
group by produto.id, produto.nome
END

CREATE PROCEDURE GetVendas AS BEGIN
select venda.id as 'Codigo Produto', cliente.nome as 'Cliente', precofinal as 'Total venda', vendedor.nome as 'Vendedor' from venda
inner join cliente on cliente.id = venda.ClienteId
inner join vendedor on vendedor.id = venda.VendedorId
END

CREATE PROCEDURE AtualizarComissao @mes int,@ano int AS BEGIN
DECLARE @ValorComissao decimal, @AuxVendedorId int;
DECLARE cursor_data CURSOR
for select
SUM(PrecoFinal), VendedorID
from Venda where MONTH(DataVenda) = @mes and YEAR(DataVenda) = @ano
group by VendedorID

open cursor_data;

FETCH NEXT FROM cursor_data into
@ValorComissao,
@AuxVendedorId;

WHILE @@FETCH_STATUS = 0
BEGIN
print 'Valor:' + CAST(@ValorComissao as varchar) + 'Vendedor:' + CAST(@AuxVendedorID as varchar)

if(exists(select * from  Comissao
where  Mes = @mes and
  Ano = @ano and
  VendedorID = @AuxVendedorId))
BEGIN
update Comissao
set Valor_Comissao = @ValorComissao
where VendedorID = @AuxVendedorId and mes = @mes and ano = @ano
END

ElSE
BEGIN
insert into Comissao(Mes,Ano,Valor_Comissao,VendedorID)
values(@mes,@ano,@ValorComissao,@AuxVendedorId)
END

FETCH NEXT FROM cursor_data into
@ValorComissao,
@AuxVendedorId;
END

CLOSE cursor_data;
Deallocate cursor_data
END

CREATE FUNCTION vendasData(@data_1 date, @data_2 date)
RETURNS TABLE
AS
RETURN
(
SELECT * FROM venda
where DataVenda > @data_1 and DataVenda < @data_2
)
GO

Create TRIGGER  UpdateEstoque
ON  Estoque
after UPDATE
AS
begin
if((select quantidade from inserted) < 50)
begin
print('Estoque inferior a 50')
end
end

Create TRIGGER  DeleteVendedor
ON  Vendedor
instead of DELETE
AS
begin
update vendedor set ativo = 0 where id = (select id from deleted)
end