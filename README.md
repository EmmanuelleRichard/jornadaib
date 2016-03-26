# jornadaib
Aplicativo desenvolvido para a feira de ciências, chamada "Jornada", do Instituto Brasil, instituição de ensino de Natal/RN

A parte mobile/web foi desenvolvida com IonicFramework, enquanto que a server foi desenvolvida em Ruby on Rails.

## Configuração do NGINX
### web
server { 
        listen 80; 
        server_name jornadaib.com.br www.jornadaib.com.br; 
        root /home/xxxx/1sistemas/jornadaib/mobile/www; 
} 

### server
server{ 
        listen 80; 
        server_name web.jornadaib.com.br; 
        passenger_enabled on; 
        passenger_app_env development; 
        root /home/xxxx/1sistemas/jornadaib/web/public; 
} 

