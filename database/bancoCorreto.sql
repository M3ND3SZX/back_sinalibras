CREATE DATABASE db_sinalibras;
USE db_sinalibras;



-------------- TABELA DE PERGUNTAS ------------------
CREATE TABLE `tbl_perguntas` (
  `id_pergunta` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `pergunta` VARCHAR(250) NOT NULL,
  `video` VARCHAR(255) NOT NULL)
ENGINE = InnoDB;

select * from tbl_perguntas;

insert into tbl_perguntas (pergunta, video)
values ("Qual a frase correta?", "ww.cdbcdbcwbcwc.wsndeowcj"),
("Os sinais estão corretos??", "www.wdusbxsacxmc");

update tbl_perguntas set
pergunta = "oi",
video = "blabla"
where id_pergunta = 1;

delete from tbl_perguntas where id_pergunta = 2;


-------------- TABELA DAS ALTERNATIVAS ---------------
CREATE TABLE `tbl_alternativas` (
  `id_alternativa` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `alternativa` VARCHAR(255) NOT NULL,
  `status` TINYINT NOT NULL,
  `id_pergunta` INT NOT NULL,
  CONSTRAINT `fk_tbl_alternativas_tbl_perguntas`
    FOREIGN KEY (`id_pergunta`) REFERENCES `tbl_perguntas` (`id_pergunta`))
ENGINE = InnoDB;

select * from tbl_alternativas;

insert into tbl_alternativas (alternativa, status, id_pergunta)
values ("cachorro", 1, 4),
("gato", 0, 4),
("passaro", 0, 4),
("sapo", 0, 4);

update tbl_alternativas set
alternativa = "zzzzz",
status = 0,
id_pergunta = 3
where id_alternativa = 3;

delete from tbl_alternativas where id_alternativa = 1;


------------- procedure que insere questões junto com a alternativa --------------

DELIMITER //

CREATE PROCEDURE inserir_questao_com_alternativas (
    IN p_pergunta VARCHAR(250),
    IN p_video VARCHAR(255),
    IN p_alternativas varchar(100)
)
BEGIN
    DECLARE v_id_pergunta INT;
    DECLARE v_alternativa varchar(100);
    DECLARE v_status VARCHAR(30);
    DECLARE v_pos INT;
    DECLARE v_end INT;
    DECLARE v_delimiter CHAR(1);


    SET v_delimiter = ';';

   
    INSERT INTO tbl_perguntas (pergunta, video)
    VALUES (p_pergunta, p_video);
    SET v_id_pergunta = LAST_INSERT_ID();


    SET v_pos = 1;


    WHILE CHAR_LENGTH(p_alternativas) > 0 DO
 
        SET v_end = LOCATE(v_delimiter, p_alternativas);
        IF v_end = 0 THEN
            SET v_end = CHAR_LENGTH(p_alternativas) + 1;
        END IF;

   
        SET v_alternativa = SUBSTRING_INDEX(p_alternativas, v_delimiter, 1);
        SET v_status = SUBSTRING_INDEX(v_alternativa, ',', -1);
        SET v_alternativa = SUBSTRING_INDEX(v_alternativa, ',', 1);

        INSERT INTO tbl_alternativas (alternativa, status, id_pergunta)
        VALUES (v_alternativa, v_status, v_id_pergunta);

     
        SET p_alternativas = SUBSTRING(p_alternativas, v_end + 1);
    END WHILE;
END//

DELIMITER ;

CALL inserir_questao_com_alternativas(
    'Qual é a capital da França?',
    'video1.mp4',
    'Paris,1;Londres,0;Berlim,0'
);


---------- VIEW QUE TRAZ AS ALTERNATIVAS DE UMA PERGUNTA ESPECÍFICA -------------
create view pergunta_alternativas as
select p.id_pergunta, p.pergunta, p.video, a.id_alternativa, a.alternativa, a.status
from tbl_alternativas as a
inner join tbl_perguntas as p
on a.id_pergunta = p.id_pergunta;

select * from pergunta_alternativas where id_pergunta = 3;


------------------- TABELA DE EMAIL ANTES DO QUIZ -----------------------------------------
CREATE TABLE `tbl_usuario_teste` (
  `id_usuario_teste` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `email` VARCHAR(255) NOT NULL,
  `data_cadastro` DATE NOT NULL)
ENGINE = InnoDB;

select * from tbl_usuario_teste;

insert into tbl_usuario_teste (email, data)
values ("leticia@gmail.com", '2024-07-02');


------------- TABELA DAS RESPOSTAS DOS USUÁRIOS NO QUIZ ------------------------
CREATE TABLE `tbl_resposta_usuario` (
  `id` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `id_alternativa` INT NOT NULL,
  `id_usuario_teste` INT NOT NULL,
  CONSTRAINT `fk_tbl_resposta_usuario_tbl_alternativas`
    FOREIGN KEY (`id_alternativa`) REFERENCES `tbl_alternativas` (`id_alternativa`),
  CONSTRAINT `fk_tbl_resposta_usuario_tbl_usuario_teste`
    FOREIGN KEY (`id_usuario_teste`) REFERENCES `tbl_usuario_teste` (`id_usuario_teste`))
ENGINE = InnoDB;

select * from tbl_resposta_usuario;

insert into tbl_resposta_usuario (id_alternativa, id_usuario_teste)
values (6,3),
(11,3);


------------- VIEW QUE TRAZ O HISTÓRICO DOS USUÁRIOS NO QUIZ -----------------------
create view respostas_do_usuario as
select r.id_usuario_teste, u.email, a.id_alternativa, p.id_pergunta, a.status
from tbl_resposta_usuario as r
inner join tbl_alternativas as a
on r.id_alternativa = a.id_alternativa
inner join tbl_perguntas as p
on a.id_pergunta = p.id_pergunta
inner join tbl_usuario_teste as u
on u.id_usuario_teste = r.id_usuario_teste;

select * from respostas_do_usuario where id_usuario_teste = 1;


------------------- TABELA DO RESULTADO DO QUIZ  ---------------------------------
CREATE TABLE `tbl_resultado` (
  `id_resultado` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `pontuacao` INT NOT NULL,
  `id_usuario_teste` INT NOT NULL,
  CONSTRAINT `fk_tbl_resultado_tbl_usuario_teste`
    FOREIGN KEY (`id_usuario_teste`) REFERENCES `tbl_usuario_teste` (`id_usuario_teste`))
ENGINE = InnoDB;

select * from tbl_resultado;



------- PROCEDURE QUE CACULA O RESULTADO DO QUIZ DO USUÁRIO E ADD NA TABELA ---------------
DELIMITER $$
CREATE PROCEDURE `inserir_resultado_usuario` (IN p_id_usuario_teste INT)
BEGIN
    DECLARE pontuacao INT;

    -- Calcula a pontuação
    SELECT SUM(CASE WHEN a.status = 1 THEN 1 ELSE 0 END) INTO pontuacao
    FROM tbl_resposta_usuario AS r
    INNER JOIN tbl_alternativas AS a ON r.id_alternativa = a.id_alternativa
    WHERE r.id_usuario_teste = p_id_usuario_teste
      AND a.status = 1;

    -- Insere o resultado e o usuário na tabela
    INSERT INTO tbl_resultado (id_usuario_teste, pontuacao)
    VALUES (p_id_usuario_teste, pontuacao)
    ON DUPLICATE KEY UPDATE pontuacao = pontuacao;
END $$
DELIMITER ;

call inserir_resultado_usuario(3);



--------------- TABELA DE PROFESSORES ---------
CREATE TABLE `tbl_professor` (
  `id_professor` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `nome` VARCHAR(250) NOT NULL,
  `data_cadastro` DATE NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `senha` VARCHAR(255) NOT NULL,
  `data_nascimento` DATE NOT NULL,
  `foto_perfil` VARCHAR(255) NULL)
ENGINE = InnoDB;
 
 select * from tbl_professor;

--------------- TABELA DOS POSTS -----------------------

CREATE TABLE `tbl_postagem` (
  `id_postagem` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `texto` VARCHAR(250) NOT NULL,
  `foto_postagem` VARCHAR(255) NULL,
  `id_professor` INT NOT NULL,
  `data` date not null,
  CONSTRAINT `fk_tbl_post_tbl_professor`
    FOREIGN KEY (`id_professor`) REFERENCES `tbl_professor` (`id_professor`))
ENGINE = InnoDB;


select * from tbl_post;

insert into tbl_post (texto, foto_postagem, id_professor, data)
values ("show", "www.jedjebdcjebk.edjwbdjbd",1, '2024-09-10');





---------- VIEW QUE TRAZ OS POSTS DO USUÁRIO ------------------
create view postagem_usuario as
select t.texto, t.data, t.foto_postagem, p.nome, p.id_professor
from tbl_postagem as t
inner join tbl_professor as p
on t.id_professor = p.id_professor;

select * from post_usuario where id_professor = 1;


------------ VIEW QUE TRAZ AS INFORMAÇÕES DO POST ------------------
create view informacoes_post as
select t.id_postagem, t.texto, t.foto_postagem, t.data, p.nome
from tbl_postagem as t
inner join tbl_professor as p
on t.id_professor = p.id_professor;

select * from informacoes_post where id_post = 1;

update tbl_post set
texto = "reuniao",
foto_postagem = "wdcnsde vncsde",
id_professor = 1,
data = '2024-09-08'
where id_post =1;

delete from tbl_post where id_post = 1;

-- select para trazer os post dos mais recentes para o mais antigo
select  * from informacoes_post order by data desc;


--------- TABELA DOS MÓDULOS -----------------------
CREATE TABLE `tbl_modulo` (
  `id_modulo` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `modulo` VARCHAR(50) NOT NULL,
  `icon` varchar(255))
ENGINE = InnoDB;

select * from tbl_modulo;

insert into tbl_modulo (modulo)
values("casa"),
("animais");

delete from tbl_modulo where id_modulo =2;

update tbl_modulo set
modulo = "saudações"
where id_modulo = 1;




------------ TABELA DOS NÍVEIS ------------
CREATE TABLE `tbl_nivel` (
  `id_nivel` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `nivel` VARCHAR(20) NOT NULL,
  `icon` varchar (255) not null)
ENGINE = InnoDB;

select * from tbl_nivel;

insert into tbl_nivel (nivel)
values ("iniciante");

delete from tbl_comentario_aula where id_comentario = 22;
delete from tbl_aluno where id_aluno = 5;

alter table tbl_nivel
add column icon varchar (255) not null;

-------------- TABELA DOS ALUNOS ---------------
CREATE TABLE `tbl_aluno` (
  `id_aluno` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `nome` VARCHAR(250) NOT NULL,
  `data_cadastro` DATE NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `senha` VARCHAR(255) NOT NULL,
  `data_nascimento` DATE NOT NULL,
  `foto_perfil` VARCHAR(255) NULL)
ENGINE = InnoDB;

select * from tbl_aluno;

INSERT INTO `db_sinalibras`.`tbl_aluno` (`nome`, `data_cadastro`, `email`, `senha`, `data_nascimento`, `foto_perfil`) VALUES ('leticia', '2024-09-02', 'julia@gmail.com', MD5('12345678'), '2007-09-26', 'fvknfklvkfvrnefvne');


--------------------------- TABELA DE VIDEOAULAS --------------------------------------------

CREATE TABLE `tbl_videoaula` (
  `id_videoaula` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `titulo` VARCHAR(50) NOT NULL,
  `url_video` varchar(255) not null,
  `descricao` VARCHAR(255) NULL,
  `duracao` TIME NOT NULL,
  `foto_capa` VARCHAR(255) NOT NULL,
  `data` DATE NOT NULL,
  `id_nivel` INT NOT NULL,
  `id_modulo` INT NOT NULL,
  `id_professor` INT NOT NULL,
  CONSTRAINT `fk_tbl_videoaula_tbl_nivel`
    FOREIGN KEY (`id_nivel`) REFERENCES `tbl_nivel` (`id_nivel`),
  CONSTRAINT `fk_tbl_videoaula_tbl_modulo1`
    FOREIGN KEY (`id_modulo`) REFERENCES `tbl_modulo` (`id_modulo`),
  CONSTRAINT `fk_tbl_videoaula_tbl_professor1`
    FOREIGN KEY (`id_professor`) REFERENCES `tbl_professor` (`id_professor`))
ENGINE = InnoDB;

select * from tbl_videoaula;


INSERT INTO tbl_videoaula (titulo, descricao, duracao, foto_capa, data, id_nivel, id_modulo, id_professor)
VALUES ('cohecendo alguém', 'como se comunicar', '00:40:00', 'xbjwbxjnxk xck', '2024-12-05', '1', '1', '1'),
('blabla', 'bla', '00:30:00', 'ednxkwnex', '2023-09-27', 1, 1,1 );

delete from tbl_videoaula where id_videoaula = 5;

update tbl_videoaula set
titulo = 'teste2',
descricao = 'bem-vindo',
duracao = '00:02:20',
foto_capa = 'vcnekidvncndec',
data = '2022-02-01',
id_nivel = 1,
id_modulo =1,
id_professor =1
where id_videoaula = 4;

select * from tbl_videoaula where id_modulo = 1;
select * from tbl_videoaula where id_nivel = 1;





-- select para trazer os videos do mais recente para o mais antigo
select  * from tbl_videoaula order by data desc;

select * from tbl_videoaula where id_videoaula = 5;

select * from tbl_nivel;

select  * from tbl_videoaula order by data desc;

-- select para trazer o video pelo nome
select * from tbl_videoaula where titulo LIKE "blabla";

-- select para trazer as videoaulas de um professor especifico
select * from informacoes_videoaula where id_professor = 1;

delete from tbl_aluno where id_aluno = 31;
delete from tbl_comentario_aula where id_comentario = 31;
delete from tbl_comentario_aula where id_comentario = 34;


CREATE TABLE `tbl_comentario_aula` (
  `id_comentario` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `data` DATE NOT NULL,
  `comentario` VARCHAR(250) NOT NULL,
  `id_videoaula` INT NOT NULL,
  `id_aluno` INT NOT NULL,
  CONSTRAINT `fk_tbl_comentarios_tbl_aluno`
    FOREIGN KEY (`id_aluno`)
    REFERENCES `tbl_aluno` (`id_aluno`),
  CONSTRAINT `fk_tbl_comentarios_tbl_videoaula`
    FOREIGN KEY (`id_videoaula`)
    REFERENCES `tbl_videoaula` (`id_videoaula`)
    ON DELETE CASCADE)
ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `tbl_video_salvo` (
  `id` INT NOT NULL PRIMARY KEY auto_increment,
  `id_videoaula` INT NOT NULL,
  `id_aluno` INT NOT NULL,
  CONSTRAINT `fk_tbl_video_salvo_tbl_videoaula`
    FOREIGN KEY (`id_videoaula`) REFERENCES `tbl_videoaula` (`id_videoaula`),
  CONSTRAINT `fk_tbl_video_salvo_tbl_aluno`
    FOREIGN KEY (`id_aluno`) REFERENCES `tbl_aluno` (`id_aluno`))
ENGINE = InnoDB;




CREATE TABLE `tbl_comentario_postagem` (
  `id_comentario` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `comentario` VARCHAR(255) NOT NULL,
  `data` TIME NOT NULL,
  `id_postagem` INT NOT NULL,
  `id_aluno` INT NOT NULL,
  CONSTRAINT `fk_tbl_comentario_post_tbl_post`
    FOREIGN KEY (`id_postagem`) REFERENCES `tbl_postagem` (`id_postagem`),
  CONSTRAINT `fk_tbl_comentario_post_tbl_alunO`
    FOREIGN KEY (`id_aluno`) REFERENCES `tbl_aluno` (`id_aluno`))
ENGINE = InnoDB;

SELECT pontuacao FROM tbl_resultado where id_usuario_teste = 3 ;

SELECT * FROM tbl_resposta_usuario;


select * from pergunta_alternativas;


select * from respostas_do_usuario where id_usuario_teste = 1;


---------- VIEW QUE TRAZ OS DADOS DO ALUNO DE UM COMENTARIO da videoaula

CREATE VIEW vw_alunos_comentaram_videoaula AS
SELECT
    a.id_aluno,
    a.nome AS nome_aluno,
    a.email,
    a.data_nascimento,
    a.foto_perfil,
    a.data_cadastro
FROM
    tbl_comentario_aula AS c
INNER JOIN
    tbl_aluno AS a ON c.id_aluno = a.id_aluno;




---------- VIEW QUE TRAZ OS DADOS DO ALUNO DE UM COMENTARIO da postagem

CREATE VIEW vw_alunos_comentaram_postagem AS
SELECT
    a.id_aluno,
    a.nome AS nome_aluno,
    a.email,
    a.data_nascimento,
    a.foto_perfil,
    a.data_cadastro
FROM
    tbl_comentario_postagem AS c
INNER JOIN
    tbl_aluno AS a ON c.id_aluno = a.id_aluno;
   
   


---------- view que traz o feed

create view feed_postagens_videoaula as
SELECT
        id_postagem AS id,
        texto AS conteudo,
        foto_postagem AS foto,
        NULL AS url_video,            
        NULL AS descricao,            
        NULL AS duracao,              
        foto_postagem AS foto_capa,    
        data,
        NULL AS id_nivel,            
        NULL AS id_modulo,            
        id_professor,
        'postagem' AS tipo
    FROM tbl_postagem
   
    UNION ALL
   
    SELECT
        id_videoaula AS id,
        titulo AS conteudo,
        foto_capa AS foto,
        url_video,
        descricao,
        duracao,
        foto_capa AS foto_capa,
        data,
        id_nivel,
        id_modulo,
        id_professor,
        'videoaula' AS tipo
    FROM tbl_videoaula
   
    ORDER BY data DESC;



-------- view que tras todos os vídeos salvos do aluno -------
create view vw_todos_videos_salvos as
SELECT 
    tvs.id, 
    tvs.id_videoaula, 
    tv.titulo AS video, 
    tvs.id_aluno, 
    ta.id_aluno AS id_aluno_aluno,  -- Renomeando para evitar conflito
    ta.nome AS aluno 
FROM 
    tbl_video_salvo AS tvs 
INNER JOIN 
    tbl_videoaula AS tv ON tvs.id_videoaula = tv.id_videoaula  
INNER JOIN 
    tbl_aluno AS ta ON tvs.id_aluno = ta.id_aluno 
ORDER BY 
    tvs.id DESC;

create view  select_pontuacoes_usuarios as 
select tut.id_usuario_teste, tut.email, tut.data_cadastro, tr.pontuacao 
from tbl_usuario_teste as tut inner join tbl_resultado as tr on tut.id_usuario_teste = tr.id_usuario_teste;
