-- ********************************************************************************
-- * Project: Clone do Spotify                                                    *
-- * Version: 1.0.0                                                               *
-- * Authors: Gabriel Arthur Ferreira Fiusa,                                      *
-- *		  Douglas Henrique de Souza Pereira,                                  * 
-- *		  Vitor Gledison Oliveira Souza                                   	  *
-- ********************************************************************************

-- ********************************************************************************
-- *                                   DATABASE                                   *
-- ********************************************************************************

create database cloneSpotify;

create type enum_genero as enum('M', 'F');
create type enum_qualidade_de_download as enum ('Baixa', 'Normal', 'Alto', 'Altissima');
create type enum_qualidade_de_reproducao as enum ('Baixa', 'Normal', 'Alto', 'Altissima');
create type enum_idioma as enum('Português', 'English');
create type enum_tipo as enum('desktop', 'smartphone', 'browser');
create type enum_tipo_de_playlist as enum('U', 'R', 'S');

create table if not exists usuario (
  id_usuario integer not null,
  apelido varchar(45) not null,
  senha varchar(20) not null,
  email varchar(100) not null,
  data_nascimento date not null,
  genero enum_genero not null,
  primary key (id_usuario)
);

create table if not exists configuracao (
  idioma enum_idioma not null default 'English',
  conteudo_explicito boolean not null default false,
  auto_play boolean not null default true,
  qualidade_de_download enum_qualidade_de_download not null default 'Normal',
  qualidade_de_reproducao enum_qualidade_de_reproducao not null default 'Normal',
  fk_id_usuario integer not null references usuario (id_usuario),
  primary key (fk_id_usuario)
);

create table if not exists dispositivos_conectados (
  id_dispositivos_conectados integer not null,
  nome varchar(45) not null,
  tipo enum_tipo not null,
  fk_id_usuario integer not null references usuario (id_usuario),
  primary key (id_dispositivos_conectados, fk_id_usuario)
);

create table if not exists playlist (
  id_playlist integer not null,
  nome varchar(45) not null,
  duracao time not null default '00:00:00',
  tipo_de_playlist enum_tipo_de_playlist not null default 'U',
  privacidade boolean not null default false,
  total_de_musicas integer not null default 0,
  seguidores integer default null,
  fk_id_usuario integer references usuario (id_usuario),
  primary key (id_playlist)
);

create table if not exists artista (
  id_artista integer not null,
  nome varchar(45) not null,
  biografia varchar(200) not null,
  seguidores integer not null default 0,
  ouvintes_mensais integer not null default 0,
  verificado boolean null default false,
  primary key (id_artista)
);

create table if not exists seguidores_playlist (
	fk_id_playlist integer not null references playlist (id_playlist),
	fk_id_usuario integer not null references usuario (id_usuario),
	primary key (fk_id_playlist, fk_id_usuario)
);

create table if not exists seguidores_artista (
	fk_id_artista integer not null references artista (id_artista),
	fk_id_usuario integer not null references usuario (id_usuario),
	primary key (fk_id_artista, fk_id_usuario)
);

create table if not exists album (
  id_album integer not null,
  nome varchar(100) not null,
  qtd_musicas integer not null default 0,
  ano_lancamento integer not null,
  primary key (id_album)
);

create table if not exists musica (
  id_musica integer not null,
  nome varchar(45) not null,
  duracao time not null,
  explicita boolean not null,
  letra varchar(200),
  primary key (id_musica)
);

create table if not exists playlist_has_musica (
  fk_id_musica integer not null references musica (id_musica),
  fk_id_playlist integer not null references playlist (id_playlist),
  primary key (fk_id_musica, fk_id_playlist)
);

create table if not exists artista_has_musica (
  fk_id_artista integer not null references artista (id_artista),
  fk_id_musica integer not null references musica (id_musica),
  fk_id_album integer not null references album (id_album),
  primary key (fk_id_artista, fk_id_musica)
);

-- ********************************************************************************
-- *                                  REQUISITOS                                  *
-- ********************************************************************************

-- --------------------------- EXCLUSÃO DE DATABASE ------------------------------
drop database clonespotify;
-- -------------------------------------------------------------------------------

-- ------------------------ ALTERAÇÃO DE NOME DE TABELA --------------------------
alter table dispositivos_conectados rename to d_conectados;

alter table d_conectados rename to dispositivos_conectados;
-- -------------------------------------------------------------------------------

-- ----------------------------- EXCLUSÃO DE COLUNA ------------------------------
alter table musica drop column letra;
-- -------------------------------------------------------------------------------

-- ----------------------------- INCLUSÃO DE COLUNA ------------------------------
alter table album add column descricao varchar(255);
-- -------------------------------------------------------------------------------

-- ---------------------- ALTERAÇÃO DE DADOS DE UMA TABELA -----------------------
update
	playlist
set
	tipo_de_playlist = 'S'
where
	id_playlist = 6;
-- -------------------------------------------------------------------------------

-- ----------------------- EXCLUSÃO DE DADOS DE UMA TABELA -----------------------
delete
from
	dispositivos_conectados
where
	id_dispositivos_conectados in
	(
		select
			id_dispositivos_conectados
		from
			dispositivos_conectados
		where
			nome = 'DESKTOP-OSI17L3'
	);
-- -------------------------------------------------------------------------------

-- ------------------------- SELECT COM FUNÇÂO DE DATA --------------------------
select 
	u.apelido, 
	extract(year from age(now(), u.data_nascimento)) as idade, 
	p.nome as nome_playlist
from 
	playlist as p
inner join 
	usuario as u on p.fk_id_usuario = u.id_usuario
where 
	(u.genero = 'F' and p.tipo_de_playlist = 'U') and 
	(extract(year from age(now(), u.data_nascimento)) < 18) 
order by u.apelido;
-- -------------------------------------------------------------------------------

-- ------------------------------------ VIEWS ------------------------------------
create or replace view musicas_nao_explicitas as
(
     select
          m.nome as nome_musica,
          case
               when m.explicita = false then 'Não'
               when m.explicita = true then 'Sim'
          end as explicita
     from
         musica as m
     where
          m.explicita = false
);

select * from musicas_nao_explicitas;
-- -------------------------------------------------------------------------------
create view vmusica as 
(
	select 
		nome, duracao
	from 
		musica
	where 
		explicita = true
);

select * from vmusica;
-- -------------------------------------------------------------------------------
create or replace view verificados as 
(
	select 
		a.nome as artistas,
		case 
			when a.verificado = false then 'Não'
			when a.verificado = true then 'Sim'
		end as verificados
	from 
		artista as a 
	where 
		a.verificado = true
);

select * from verificados;
-- -------------------------------------------------------------------------------

-- --------------------------------- FUNCTIONS -----------------------------------
create function tipo_playlist(id_playlist_selecionada integer)
	returns varchar(1) 
as $$
	declare tipo_playlist_selecionada char(1);
	begin
		select tipo_de_playlist
		into tipo_playlist_selecionada
	    from playlist
	    where id_playlist = id_playlist_selecionada;
	    return 
			case tipo_playlist_selecionada
				when 'U' then 'Usuário'
	            when 'S' then 'Sistema'
	            when 'R' then 'Rádio'
			end;
	end
$$ language plpgsql;

select nome, tipo_playlist(id_playlist) from playlist;
-- -------------------------------------------------------------------------------
create function classificacao_artista(ouvintes_mensais integer)
	returns varchar(45) 
as $$
	declare classificacao varchar(45);
	begin        
	    if ouvintes_mensais > 1000 and ouvintes_mensais <= 50000 
	    	then classificacao = 'Iniciante';
	    elseif ouvintes_mensais > 50000 and ouvintes_mensais <= 500000 
	   		then classificacao = 'Intermediário';
	    elseif ouvintes_mensais > 500000 and ouvintes_mensais <= 1000000 
	   		then classificacao = 'Famoso';
	    elseif ouvintes_mensais > 1000000 
	    	then classificacao = 'Muito Famoso';
	    end if;
	   
	    return classificacao;
	end 
$$  language plpgsql;

select classificacao_artista(500000);
-- -------------------------------------------------------------------------------
create function classificacao_de_musicas(classificacao_musica_selecionada boolean)
	returns varchar(40) 
as $$
	declare explicit varchar(40);
	begin
	    if classificacao_musica_selecionada = true 
	   		then explicit = 'Explicito';
		elseif classificacao_musica_selecionada = false 
			then explicit = 'Livre';
		end if;
	
	    return explicit;
	end
$$ language plpgsql;

select classificacao_de_musicas(true);
-- -------------------------------------------------------------------------------

-- ----------------------------- STORED PROCEDURES -------------------------------
create or replace procedure atualiza_seguidores()
	language plpgsql 
as $$
begin
   update 
		playlist as p
	set 
		seguidores = 0
	where
		p.privacidade = false and tipo_de_playlist = 'U';
end; $$

call atualiza_seguidores();
-- -------------------------------------------------------------------------------
create or replace procedure reset_config(in id_usuario integer)
	language plpgsql 
as $$
begin
   update 
		configuracao as c
	set 
		(auto_play, qualidade_de_download, qualidade_de_reproducao) = (true, 'Normal', 'Normal')
	where
		c.fk_id_usuario = id_usuario;
end; $$

call reset_config(1);
-- -------------------------------------------------------------------------------

-- --------------------------------- TRIGGERS ------------------------------------
create or replace function incrementa_qtd_musicas_playlist()
	returns trigger 
	language plpgsql
as $$
begin
	update 
		playlist as p
	set 
		total_de_musicas = total_de_musicas + 1
	where
		new.pk_id_playlist = p.id_playlist;
end $$ 

create trigger tg_incrementa_qtd_musicas_playlist
    after insert on playlist_has_musica
    for each row
    execute procedure incrementa_qtd_musicas_playlist();
-- -------------------------------------------------------------------------------
create or replace function decrementa_qtd_musicas_playlist()
	returns trigger 
	language plpgsql
as $$
begin
	update 
		playlist as p
	set 
		total_de_musicas = total_de_musicas + 1
	where
		new.pk_id_playlist = p.id_playlist;
end $$ 

create trigger tg_decrementa_qtd_musicas_playlist
    after insert on playlist_has_musica
    for each row
    execute procedure decrementa_qtd_musicas_playlist();
-- -------------------------------------------------------------------------------

-- ---------------------------------- COMMIT -------------------------------------
begin;
	update usuario
	set apelido = 'Jose'
	where id_usuario = 5;
commit;

begin;
	delete from configuracao where idioma = 'English';
commit;
-- -------------------------------------------------------------------------------

-- --------------------------------- ROLLBACK ------------------------------------
begin;
	insert into musica values(7, 'Hype', '00:02:51', true);
rollback;

begin;
	delete from configuracao where idioma = 'English';
rollback;
-- -------------------------------------------------------------------------------

-- ---------------- 3 USUÁRIOS COM PRIVILÉGIOS DIFERENTES ------------------------
-- USER 1
create user douglas;
grant all privileges on all tables in schema public to douglas;

-- USER 2
create user gabriel;
grant update, select on musica to gabriel;

-- USER 3
create user vitor;
grant insert, update, delete on musica, album, playlist to vitor;

grant select on usuario to Douglas;
grant select on musica to Vitor;
grant select on playlist to Gabriel;
-- -------------------------------------------------------------------------------

-- ------------- 2 REVOKE COM RETIRADA DE PRIVILÉGIOS DIFERENTES E ---------------
-- --------------------- 1 EXCLUINDO TODOS OS PRIVILÉGIOS ------------------------
revoke insert on clonespotify.public.musica from douglas;
revoke update, delete on musica from vitor;
revoke update on musica from gabriel;
revoke all privileges on all tables in schema public from douglas;

revoke select on public.usuario to Douglas;
revoke select on public.musica to Vitor;
revoke privileges on * from public;

-- ********************************************************************************
-- *                                   INSERTS                                    *
-- ********************************************************************************

insert into usuario values 
(1,'Gabriel','Coxinha123','vnz12945@eoopy.com','2000/11/25','M'),
(2,'Douglas','Douglinhas311','dch26059@cuoly.com','2000/08/28','M'),
(3,'Vitor','VitinDaQuebrada','eky97463@cuoly.com','2001/07/26','M'),
(4,'Lucas','NaoSeiAondeEstou','hsz70759@eoopy.com','2002/03/13','M'),
(5,'Matheus','password','zng26681@bcaoo.com','2002/10/29','M'),
(6,'Pedro','monkey','ggh75707@bcaoo.com','2003/06/16','M'),
(7,'Carlos','!@#$%^&*','ype92143@eoopy.com','2004/02/01','M'),
(8,'Maria','donald','hua97591@cuoly.com','2004/09/18','F'),
(9,'Fernanda','football','wiw85813@cuoly.com','2005/05/06','F'),
(10,'Carol','princess','ifz69162@eoopy.com','2005/12/22','F'),
(11,'Gertrudes','minaDoDouglas','princesinha@eoopy.com','2003/05/13','F');

insert into playlist (id_playlist, nome, tipo_de_playlist, privacidade) values
(1,'Musicas_Curtidas','S',true),
(2,'Mais_Ouvidas','S',true),
(3,'Dilsinho','R',false),
(4,'Sidoka','R',false);

insert into playlist (id_playlist, nome, privacidade, fk_id_usuario) values
(5,'Sertanejo',false,1),
(6,'Lofi',true,10),
(7,'Hits',false,2);

insert into artista (id_artista, nome, biografia, seguidores, ouvintes_mensais, verificado) values
(1,'Beatriz','Ex-estudante de Harvard que largou os estudos para se dedicar à música como um estudo social.',123144,5234,false),
(2,'Ana','Veio de uma família carente e gravou sua primeira música aos 7 anos de idade com a ajuda de uma "vaquinha" online.',13487,1349,false),
(3,'Miguel','Pai ta on.',367097,37098,true),
(4,'Ravi','Ficou inconsiente por 3 anos, após acordar lançou seu primeiro sucesso.',411862,46424,true),
(5,'Mariana','Mariana conta 1, Mariana ++.',533838,62356,true),
(6,'Alice','A mesma de Alice no País das Maravilhas.',655815,7828,false),
(7,'Guilherme','Morava na perifieria, por isso lançou o hit Rave na Favela',777791,9422045,true),
(8,'João','Morava no interior de Goiás, na sua adolescência encontrou um pó brilhante e colocou no bolso junto de um grão de feijão que acabou cresendo, fazendo João ir nas alturas das paradas de sucesso.',899768,110152,true),
(9,'Gabriel','Trabalhou por 10 anos como programador, por isso resolveu seguir o caminho musical.',1021744,126084,true),
(10,'Luna','Luna olhou para lua e lançou seu primeiro Single.',1143721,142016,true);

insert into album (id_album, nome, ano_lancamento) values
(1,'ruxell remix',1999),
(2,'Ao vivo em ibirapuera',2010),
(3,'MEZMERIZE',2019),
(4,'WAP-Single',2009),
(5,'chou ikimonobakari tennen kinen members best selection',2015);

insert into musica values
(1,'B.y.o.b.','00:03:10',true,'Why do they always send the poor? Barbarisms by barbaras With pointed heels...'),
(2,'WAP','00:03:50',true,'I said, certified freak Seven days a week Wet ass pussy...'),
(3,'Liverdade Provisória','00:04:30',false,'No início foi assim Terminou tá terminado Cada um pro seu lado Não precisa ligar mais...'),
(4,'na raba toma tapao','00:05:10',false,'É o Niack chega em casa (é o CL na voz) Dj Pernambuco É o Niack (é mais uma né) Do jeitinho diferente...'),
(5,'oh juliana','00:05:50',false,'Mas esse é o Léo da 17 Sucesso com a mulherada Eu sei que eu não sou teu dono Mas tu tá na minha mão...'),
(6,'blue bird','00:06:30',false,'??(???)??? ???????? ?????? ?? ?? ???...');

insert into configuracao values
('Português',false,true,'Normal','Normal', 1);

insert into dispositivos_conectados values
(1,'DESKTOP-OSI17L3','desktop',1),
(2,'XT7498-4','smartphone',7),
(3,'GO7810-7','smartphone',4),
(4,'IO5584-7','smartphone',10),
(5,'WEB-Player(Chrome)','browser',2);

insert into artista_has_musica values
(1,1,1),
(4,3,5),
(4,5,2),
(7,4,3),
(10,6,4);

insert into playlist_has_musica values
(1,1),
(2,2),
(3,2),
(4,2),
(6,4),
(1,6),
(2,6),
(3,6),
(4,6),
(6,6);

insert into seguidores_playlist values
(7,1),
(7,2),
(7,4),
(7,5),
(3,6),
(4,7),
(5,8),
(5,11);

insert into seguidores_artista values
(7,1),
(9,2),
(10,6),
(1,7),
(5,8),
(3,11);

-- ********************************************************************************
-- *                                   SELECTS                                    *
-- ********************************************************************************

-- 1) Selecionar as musicas das playlists que não contém nenhum conteúdo explicito e tem duracao maior que 3 minutos, 
--    agrupadas pela playlist em que estão contidas.
select
	m.nome as nome_musica,
	play.nome as nome_playlist
from
	playlist_has_musica as p
inner join musica as m on
	p.fk_id_musica = m.id_musica
inner join playlist as play on
	p.fk_id_playlist = play.id_playlist
where
	(m.explicita = false and m.duracao > '00:03:00')
order by
	play.nome;

-- 2) Obter o apelido e id dos usuários do sexo feminino que tem menos de 18 anos e tem pelo menos uma playlist criada por 
--    ele mesmo, ordenados pelo nome.  
select 
	u.apelido,
	extract(year from age(now(), u.data_nascimento)) as idade,
	p.nome as nome_playlist
from 
	playlist as p
inner join usuario as u on
	p.fk_id_usuario = u.id_usuario
where 
	(u.genero = 'F' and p.tipo_de_playlist = 'U') and 
	(extract(year from age(now(), u.data_nascimento)) < 18) 
order by u.apelido;

-- 3) Selecionar as playlists que possuem mais de 3 músicas, sejam privadas e criadas pelo usuário, agrupadas pelo usuário
select
	u.apelido as nome_usuario,
	p.nome as nome_playlist,
	p.total_de_musicas
from
	playlist as p
inner join usuario as u on
	p.fk_id_usuario = u.id_usuario
where
	p.privacidade = true and p.total_de_musicas > 3
order by 
	nome_usuario;

-- 4) Listar todas as playlists de um usuário ordenado pela quantidade de músicas na playlist
select
	u.apelido as nome_usuario,
	p.nome as nome_playlist,
	p.total_de_musicas
from
	usuario as u
inner join playlist as p on
	p.fk_id_usuario = u.id_usuario
where
	u.apelido = 'Gabriel'
order by
	p.total_de_musicas desc;

-- 5) selecionar as playlist's publicas para o usuário
 select
	nome
from
	playlist
where
	privacidade = true;

-- 6) Listar todas musicas de um artista e seus respectivos Álbuns ordenados pelo ano de lançamento
select
	a.nome as artista,
	m.nome as musica,
	alb.nome as album,
	alb.ano_lancamento
from
	artista_has_musica as ahm
inner join musica as m on
	m.id_musica = ahm.fk_id_musica
inner join artista as a on
	a.id_artista = ahm.fk_id_artista
inner join album as alb on
	alb.id_album = ahm.fk_id_album
order by
	alb.ano_lancamento desc;

-- 7) Selecionar o nome das musicas e a duração das mesmas que começam com a letra B e possuem uma duração menor que 00:04:00
-- 	  e esta contida em pelo menos uma playlist
select
	m.nome as nome_musica,
	m.duracao as duracao_musica,
	play.nome as nome_playlist
from
	playlist_has_musica as p
inner join musica as m on
	m.id_musica = p.fk_id_musica
inner join playlist as play on
	play.id_playlist = p.fk_id_playlist
where
	(m.duracao < '00:04:00' and m.nome like 'B%');

-- 8) Selecionar musicas que nao estão contidas em nenhuma playlist;
select *
from
	musica as m
where
	not exists 
	(
		select *
		from
			playlist_has_musica as play
		where
			play.fk_id_musica = m.id_musica
	);
