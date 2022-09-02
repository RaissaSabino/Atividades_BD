CREATE DATABASE Senai_DB;
GO

USE Senai_DB;
GO


create table cliente(
id int primary key identity,
nome varchar(500),
cpf varchar(15)
)

create table conta(
num_conta int primary key identity,
num_agencia int,
id_cliente int,
saldo decimal(19,3)
FOREIGN KEY (id_cliente) REFERENCES cliente(id)
)

create table movimentacao(
id int primary key identity,
num_conta int,
saldo_anterior decimal(19,3),
saldo_atual decimal(19,3),
data_movimentacao datetime
FOREIGN KEY (num_conta) REFERENCES conta(num_conta)
)

insert into cliente 
values 
('Raissa','12345678922'),
('Nathan','12345678922'),
('Steicy','12345678922'),
('João','12345678922'),
('Carlos','12345678922'), 
('Alison','12345678922')


insert into conta 
values 
(1,1,165),
(2,2,2452),
(3,3,4532),
(4,4,783),
(5,5,7863),
(6,6,42378)

CREATE TRIGGER criarMovimentacao
ON conta
AFTER insert
as
BEGIN
declare @num_conta int
select @num_conta = num_conta from inserted

insert into movimentacao values(@num_conta, 0, 0, getdate())
END

go

CREATE TRIGGER deletarConta
ON conta
AFTER DELETE
as
BEGIN
declare @num_conta int
select @num_conta = num_conta from deleted
insert into movimentacao values(@num_conta, 0, 0, getdate())
delete from movimentacao where num_conta = @num_conta
END

go


CREATE TRIGGER verificarSaldo
ON conta
after insert
as
BEGIN
declare @saldo int
declare @num_conta int
select @num_conta = num_conta from inserted
select @saldo = saldo from inserted

if (@saldo!= 0)
begin
update conta set saldo = 0 where num_conta = @num_conta
delete from movimentacao WHERE ID=(SELECT MAX(id) FROM movimentacao)
end
END

go

CREATE TRIGGER registrarMovimentacao
ON conta
after update
as
BEGIN
declare @saldo_novo int
declare @saldo_anterior int
declare @num_conta int
select @saldo_novo = saldo from inserted
select @saldo_anterior = saldo from deleted
select @num_conta = num_conta from deleted

insert into movimentacao values(@num_conta, @saldo_anterior, @saldo_novo, getdate())
END

go

create PROCEDURE Sacar
@valor decimal, @conta int
AS
BEGIN
declare @saldo_novo int

select @saldo_novo = saldo from conta where num_conta = @conta

set @saldo_novo = @saldo_novo - @valor

update conta set saldo = @saldo_novo where num_conta = @conta
END

go

create PROCEDURE Depositar
@valor decimal, @conta int
AS
BEGIN
declare @saldo_novo int

select @saldo_novo = saldo from conta where num_conta = @conta

set @saldo_novo = @saldo_novo + @valor

update conta set saldo = @saldo_novo where num_conta = @conta
END

go

create PROCEDURE ListarContas
@valor decimal
AS
BEGIN
select * from conta where saldo > @valor
END

go

create PROCEDURE Pix
@valor decimal, @conta_1 int, @conta_2 int
AS
BEGIN
declare @saldo_novo_1 int
declare @saldo_novo_2 int

select @saldo_novo_1 = saldo from conta where num_conta = @conta_1
select @saldo_novo_2 = saldo from conta where num_conta = @conta_2

set @saldo_novo_1 = @saldo_novo_1 - @valor
set @saldo_novo_2 = @saldo_novo_2 + @valor

update conta set saldo = @saldo_novo_1 where num_conta = @conta_1
update conta set saldo = @saldo_novo_2 where num_conta = @conta_2
END


go


CREATE FUNCTION MostrarMovimentacoes
(
    @num_conta int,
@data_1 date,
@data_2 date
)
RETURNS Table
AS
return(
    select * from movimentacao where num_conta = @num_conta and data_movimentacao > @data_1 and data_movimentacao < @data_2
)