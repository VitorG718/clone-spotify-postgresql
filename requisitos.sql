-- --------------------------- EXCLUSÃO DE DATABASE ------------------------------
-- -------------------------------------------------------------------------------

-- ------------------------ ALTERAÇÃO DE NOME DE TABELA --------------------------
-- -------------------------------------------------------------------------------

-- ----------------------------- EXCLUSÃO DE COLUNA ------------------------------
-- -------------------------------------------------------------------------------

-- ----------------------------- INCLUSÃO DE COLUNA ------------------------------
-- -------------------------------------------------------------------------------

-- ---------------------- ALTERAÇÃO DE DADOS DE UMA TABELA -----------------------
-- -------------------------------------------------------------------------------

-- ----------------------- EXCLUSÃO DE DADOS DE UMA TABELA -----------------------
-- -------------------------------------------------------------------------------

-- ------------------------- SELECT COM FUNÇÃO DE DATA --------------------------
select 
	u.apelido, extract(year from age(now(), u.data_nascimento)) as idade, p.nome as nome_playlist
from 
	playlist as p
inner join 
	usuario as u on p.fk_id_usuario = u.id_usuario
where 
	(u.genero = 'F' and p.tipo_de_playlist = 'U') and (extract(year from age(now(), u.data_nascimento)) < 18) 
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
returns varchar(1) as $$
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
end;
$$ language plpgsql;

select nome, tipo_playlist(id_playlist) from playlist;
-- -------------------------------------------------------------------------------
create function classificacao_artista(ouvintes_mensais integer)
returns varchar(45) as $$
declare classificacao varchar(45);
begin        
    if ouvintes_mensais > 1000 and ouvintes_mensais <= 50000 
    	then classificacao = 'Iniciante';
    elseif ouvintes_mensais > 50000 and ouvintes_mensais <= 500000 
   		then classificacao = 'Intermediario';
    elseif ouvintes_mensais > 500000 and ouvintes_mensais <= 1000000 
   		then classificacao = 'Famoso';
    elseif ouvintes_mensais > 1000000 
    	then classificacao = 'Muito Famoso';
    end if;
   
    return classificacao;
end $$  language plpgsql;

select classificacao_artista(500000);
-- -------------------------------------------------------------------------------
create function classificacao_de_musicas(classificacao_musica_selecionada boolean)
returns varchar(40) as $$
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
create or replace procedure playlists_usuario(apelido_usuario varchar(45))
language plpgsql 
as $$
begin
	select 
		u.apelido as nome_usuario, p.nome as nome_playlist, p.total_de_musicas
	from 
		usuario as u
	inner join 
		playlist as p on p.fk_id_usuario = u.id_usuario
	where 
		u.apelido = apelido_usuario
	order by 
		p.total_de_musicas desc;
	
	commit;
end; $$

select playlists_usuario('VItor');



create function playlists_usuario(apelido_usuario varchar(45))
returns void as $$
begin
    select 
		u.apelido as nome_usuario, p.nome as nome_playlist, p.total_de_musicas
	from 
		usuario as u
	inner join 
		playlist as p on p.fk_id_usuario = u.id_usuario
	where 
		u.apelido = apelido_usuario
	order by 
		p.total_de_musicas desc;
end
$$ language plpgsql;

select playlists_usuario('Gabriel');
-- -------------------------------------------------------------------------------
-- douglas
drop procedure calcula_idade_album;
create or replace function calcula_idade_album()
returns text
as $$
begin 
	perform (select nome, ano_lancamento 
    from album
   	where ano_lancamento > 2000);
   return 'OK';
end
$$ language plpgsql;

select calcula_idade_album();
-- -------------------------------------------------------------------------------
-- gabriel
use clonespotify;
delimiter $$
create procedure listarmusicas()
begin
    select nome from musica;
end $$
delimiter ;
call listarmusicas();
-- -------------------------------------------------------------------------------

-- --------------------------------- TRIGGERS ------------------------------------
delimiter $$
create trigger atualizatotalmusicasplaylist before insert
on playlist_has_musica
for each row
begin
    update playlist
    set total_de_musicas = (total_de_musicas + 1)
    where playlist.idplaylist = new.idplaylist;
end$$
delimiter ;
-- douglas
create trigger playlist_has_musica_after_insert
after insert 
on playlist_has_musica
for each row
begin
	update playlist 
    set seguidores = seguidores + 1
    where new.idplaylist = idplaylist;
end;

-- gabriel
delimiter $$
create trigger iniciarseguidores before insert
on artista
for each row
begin
	set new.seguidores = 0;
end$$
delimiter ;

-- 1 commit

-- 1 rollback

-- 3 usuários com privilégios diferentes

-- 2 revoke com retirada de privilégios diferentes e 1 excluindo todos os privilégios