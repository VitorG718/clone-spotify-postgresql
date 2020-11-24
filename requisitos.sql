-- --------------------------- EXCLUSAO DE DATABASE ------------------------------
drop database clonespotify;
-- -------------------------------------------------------------------------------

-- ------------------------ ALTERACAO DE NOME DE TABELA --------------------------
alter table dispositivos_conectados rename to d_conectados;
-- -------------------------------------------------------------------------------

-- ----------------------------- EXCLUSAO DE COLUNA ------------------------------
alter table musica drop column letra;
-- -------------------------------------------------------------------------------

-- ----------------------------- INCLUSAO DE COLUNA ------------------------------
alter table album add column descricao;
-- -------------------------------------------------------------------------------

-- ---------------------- ALTERACAO DE DADOS DE UMA TABELA -----------------------
update playlist
set tipo_de_playlist = 'S'
where id_playlist = 6;
-- -------------------------------------------------------------------------------

-- ----------------------- EXCLUSAO DE DADOS DE UMA TABELA -----------------------
delete from dispositivos_conectados
where id_dispositivos_conectados in(select id_dispositivos_conectados
                                    from dispositivos_conectados
                                    where nome = 'DESKTOP-OSI17L3');
-- -------------------------------------------------------------------------------

-- ------------------------- SELECT COM FUNCAO DE DATA --------------------------
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
               when m.explicita = false then 'Nï¿½o'
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
			when a.verificado = false then 'Nï¿½o'
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
			when 'U' then 'Usuï¿½rio'
            when 'S' then 'Sistema'
            when 'R' then 'Rï¿½dio'
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

-- 1 commit

begin;
update usuario
set apelido = 'Jose'
where id_usuario = 5;
commit;

begin;
delete from public.configuracao where idioma = 'English';
commit;

-- 1 rollback

begin;
insert into musica VALUES(7, 'Hype', '00:02:51', true, '');
rollback;

begin;
delete from public.configuracao where idioma = 'English';
rollback ;

-- 3 usuários com privilégios diferentes

-- User 1
create user douglas;
grant all privileges on all tables in schema public to douglas;

-- User 2
create user gabriel;
grant update, select on musica to gabriel;

-- User 3
create user vitor;
grant insert, update, delete on musica, album, playlist to vitor;

-- Gabriel

GRANT SELECT ON public.usuario TO Douglas;
GRANT SELECT ON public.musica TO Vitor;
GRANT SELECT ON public.playlist TO Gabriel;

-- 2 revoke com retirada de privilégios diferentes e 1 excluindo todos os privilégios
revoke insert on clonespotify.public.musica from douglas;
revoke update, delete on musica from vitor;
revoke all privileges on all tables in schema public from douglas;
revoke update  on musica from gabriel;

-- Gabriel
REVOKE SELECT ON public.usuario TO Douglas;
REVOKE SELECT ON public.musica TO Vitor;
REVOKE PRIVILEGES ON * FROM public;
---------------------------------------------------------------------------------------------------------------------

