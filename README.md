# [Mini-Project] Pet Cuddle o Tron

####  Descrição
Este projeto iremos criar toda essa arquitetura abaixo com terraform! Utilizaremos o terraform para provisionar o nosso código na cloud, subir nosso website statico. Objetivo do projeto: Enviar e-mail de notificação de lembrete baseado no tempo estimado pelo front. 
    
![Alt text](./assets/arquitetura.png "Title")

Dentro da pasta `iac`temos nossos módulos terraform cada módulo é responsável por subir uma parte da arquitetura dentro da aws.

O módulo `state_machine_module` provisiona o step function que recebe uma requisição do api lambda com um payload indicando o email a receber a notificação e o tempo de espera do lembrete.

O módulo `email_remindar_lambda` ele recebe um e-mail e envia uma notificação para o e-mail selecionado! 

O módulo `api_lambda_module` provisiona um endpoint api gateway post, e um api lambda que vai ser invocado pelo api gateway. Toda vez que uma chamada de api é feita para o api gateway ele recebe a requisição.

O módulo `frontend_module` cria um bucket website stático e sobe os arquivos javascript e html necessários para rodar uma simples aplicação frontend.