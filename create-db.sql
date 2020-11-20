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