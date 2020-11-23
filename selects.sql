
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
