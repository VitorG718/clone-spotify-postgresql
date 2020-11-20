CREATE TYPE enum_genero AS ENUM('M', 'F');

CREATE TABLE IF NOT EXISTS usuario (
  id_usuario integer not null,
  apelido varchar(45) not null ,
  senha varchar(20) not null ,
  email varchar(100) not null ,
  data_nascimento date not null ,
  genero enum_genero not null,
  primary key (id_usuario)
);

create type enum_qualidade_de_download as enum ('Baixa', 'Normal', 'Alto', 'Altissima');
create type enum_qualidade_de_reproducao as enum ('Baixa', 'Normal', 'Alto', 'Altissima');
create type enum_idioma as enum('Portugues', 'English');

CREATE TABLE IF NOT EXISTS configuracao (
  idioma enum_idioma NOT NULL DEFAULT 'English',
  conteudo_explicito boolean NOT NULL DEFAULT false,
  auto_play boolean NOT NULL DEFAULT true,
  qualidade_de_download enum_qualidade_de_download  NOT NULL DEFAULT 'Normal',
  qualidade_de_reproducao enum_qualidade_de_reproducao  NOT NULL DEFAULT 'Normal',
  fk_id_usuario integer NOT null REFERENCES usuario (id_usuario),
  primary key (fk_id_usuario)
);

create type enum_tipo as ENUM('desktop', 'smartphone', 'browser');

CREATE TABLE IF NOT EXISTS dispositivos_conectados (
  id_dispositivos_conectados integer NOT NULL,
  nome varchar(45) NOT NULL,
  tipo enum_tipo NOT NULL,
  fk_id_usuario integer not null REFERENCES usuario (id_usuario),
  primary key (id_dispositivos_conectados, fk_id_usuario)
);

create type enum_tipo_de_playlist as ENUM('U', 'R', 'S');

CREATE TABLE IF NOT EXISTS playlist (
  id_playlist integer NOT NULL,
  nome varchar(45) NOT NULL,
  duracao TIME NOT NULL,
  tipo_de_playlist enum_tipo_de_playlist NOT NULL DEFAULT 'U',
  privacidade boolean NOT NULL DEFAULT false,
  total_de_musicas integer NULL DEFAULT 0,
  seguidores integer NULL DEFAULT NULL,
  fk_id_usuario integer  NOT null REFERENCES usuario (id_usuario),
  PRIMARY KEY (id_playlist)
);

CREATE TABLE IF NOT EXISTS artista (
  id_artista integer NOT null,
  nome varchar(45) NOT NULL,
  biografia varchar(200) NOT NULL,
  seguidores integer NOT NULL DEFAULT 0,
  ouvintes_mensais integer NOT NULL DEFAULT 0,
  verificado boolean NULL DEFAULT false,
  PRIMARY KEY (id_artista)
);

CREATE TABLE IF NOT EXISTS album (
  id_album integer NOT NULL,
  nome varchar(100) NOT NULL,
  qtd_musicas integer NOT NULL DEFAULT 0,
  ano_lancamento integer not NULL,
  PRIMARY KEY (id_album)
);

CREATE TABLE IF NOT EXISTS musica (
  id_musica integer NOT NULL,
  nome varchar(45) NOT NULL,
  duracao time NOT NULL,
  explicita boolean NOT NULL,
  letra varchar(200) NULL DEFAULT NULL,
  PRIMARY KEY (id_musica)
);

CREATE TABLE IF NOT EXISTS playlist_has_musica (
  fk_id_musica integer NOT null REFERENCES musica (id_musica),
  fk_id_playlist integer NOT null REFERENCES playlist (id_playlist),
  PRIMARY KEY (fk_id_playlist, fk_id_musica)
);

CREATE TABLE IF NOT EXISTS artista_has_musica (
  fk_id_artista integer NOT null REFERENCES artista (id_artista),
  fk_id_musica integer NOT null REFERENCES musica (id_musica),
  fk_id_album integer NOT null REFERENCES album (id_album),
  PRIMARY KEY (fk_id_artista, fk_id_musica)
);