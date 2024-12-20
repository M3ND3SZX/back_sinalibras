/************************************************************************************************************
 * Objetivo: Arquivo responsável pela comunicação como banco de dados
 * Data: 03/09/2024
 * Autor: Julia Mendes 
 * Versão: 1.0
 * 
************************************************************************************************************/


const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();


const selectValidarAluno = async function (email,senha){


 let sql = `select ta.id_aluno, ta.nome, ta.email from tbl_aluno as ta
 where email = '${email}' and senha = md5('${senha}')`



    let rsUsuario = await prisma.$queryRawUnsafe(sql)


    if(rsUsuario){
       
        return rsUsuario
    }else{
        return false
    }
}



const selectVerificarEmail = async function (email){
    try{
     let sql = `select ta.nome, ta.email from tbl_aluno as ta where email = '${email}';`


     let rsAluno = await prisma.$queryRawUnsafe(sql)

     if (rsAluno.length > 0){
        return rsAluno
     } else{
        let sqlAluno = `select ta.nome, ta.email from tbl_professor as ta where email = '${email}';`

        let rsProfAluno = await prisma.$queryRawUnsafe(sqlAluno)

        if(rsProfAluno){
            return rsProfAluno
        }else{
            return false
        }
     }


    
    }catch(error){
        return false
    }
    
}


const selectAllAlunos = async function (){
    
    let sql = 'select id_aluno, nome, email, data_nascimento, foto_perfil  from tbl_aluno'

    let rsAluno = await prisma.$queryRawUnsafe(sql);
    
    if( rsAluno) {
    return rsAluno;
}else
       return false;
}

const selectByIdAluno = async function (id){
    try{
        let sql = `select id_aluno, nome, email, data_nascimento, foto_perfil  from tbl_aluno where id_aluno = ${id}`

        let rsUsuario = await prisma.$queryRawUnsafe(sql)


        return rsUsuario
       

    } catch (error){
   
        return false
    }

}


const insertAluno = async function(dadosAluno){
       
    let sql 
        try{
    
            

            if(dadosAluno.foto_perfil != "" && 
                dadosAluno.foto_perfil != null &&
                dadosAluno.foto_perfil != undefined
                ){
           
        sql = `insert into tbl_aluno ( 
                                nome, 
                                data_cadastro,
                                email,
                                senha,
                                data_nascimento,
                                foto_perfil
                                ) values (
                                 '${dadosAluno.nome}',
                                   '${dadosAluno.data_cadastro}',
                                    '${dadosAluno.email}',
                                    MD5('${dadosAluno.senha}'),
                                    '${dadosAluno.data_nascimento}',
                                    '${dadosAluno.foto_perfil}'
                                )`
    
                }else {
    
                  sql =  `insert into tbl_aluno ( 
                                nome, 
                                data_cadastro,
                                email,
                                senha,
                                data_nascimento,
                                foto_perfil
                                ) values (
                                    '${dadosAluno.nome}',
                                    '${dadosAluno.data_cadastro}',
                                    '${dadosAluno.email}',
                                    MD5('${dadosAluno.senha}'),
                                    '${dadosAluno.data_nascimento}',
                                     null
                                )`
                }
    
        

        

        let rsUsuario = await prisma.$executeRawUnsafe(sql)

        if(rsUsuario){
            return true
        }else
            return false

    } catch(error) {
        return false
    }

}




 const selectUltimoIdAluno = async function (){
        try{
           let sql = `select cast(last_insert_id()as DECIMAL) as id_aluno from tbl_aluno limit 1;`
   
           let rsUsuario = await prisma.$queryRawUnsafe(sql);
           return rsUsuario
   
           
        } catch (error) {
           return false
       }
   }

   
const updateAluno = async function (id, dadosAluno) {

    let sql  


    try{
    
        if(dadosAluno.foto_perfil != "" && 
            dadosAluno.foto_perfil != null &&
            dadosAluno.foto_perfil != undefined
            ){
    
        sql = `update tbl_aluno set
            nome =  '${dadosAluno.nome}',
            email =  '${dadosAluno.email}',
            data_nascimento =  '${dadosAluno.data_nascimento}',
            foto_perfil = '${dadosAluno.foto_perfil}'
            where tbl_aluno.id_aluno = ${id}`

            }else{

                sql = `update tbl_aluno set
                nome =  '${dadosAluno.nome}',
                email =  '${dadosAluno.email}',
                data_nascimento =  '${dadosAluno.data_nascimento}',
                foto_perfil = null
                where tbl_aluno.id_aluno = ${id}`


            }
    
    
        let rsAluno = await prisma.$executeRawUnsafe(sql)

        if (rsAluno)
      return rsAluno

    }catch(error){

        return false
    }

}


    
const deleteAluno = async function (id){

    try {
   
       let sql = `delete from tbl_aluno where id_aluno = ${id}`
   
       let rsAluno = await prisma.$executeRawUnsafe(sql);  

       if(rsAluno)
       return true
       else
       return false

      
     } catch (error) {
       return false
       }
   
}

const selectAlunoByNome = async function (nome){
    try{
        let sql = `select * from tbl_aluno where nome LIKE "%${nome}%"`
       

        let rsUsuario = await prisma.$queryRawUnsafe(sql);
        return rsUsuario;
    } catch (error) {
        return false
    }
}


const selectAlunoByEmail = async function (email){
    try{
        let sql = `select * from tbl_aluno where email LIKE "%${email}%"`

        let rsAluno = await prisma.$queryRawUnsafe(sql)

        if(rsAluno)
        return rsAluno
        else
        return false
    }catch(error){
        return false
    }
}








module.exports = {
    selectAllAlunos,
    selectByIdAluno,
    selectAlunoByNome,
    selectAlunoByEmail,
    insertAluno,
    selectUltimoIdAluno,
    updateAluno,
    deleteAluno,
    selectValidarAluno,
    selectVerificarEmail
}