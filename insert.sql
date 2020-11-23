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
(6,'blue bird','00:06:30',false,'飛翔(はばた)いたら 戻らないと言って 目指したのは 蒼い 蒼い あの空...');

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