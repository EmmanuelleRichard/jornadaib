# jornadaib
Aplicativo desenvolvido para a feira de ciências, chamada "Jornada", do Instituto Brasil, instituição de ensino de Natal/RN

A parte mobile/web foi desenvolvida com IonicFramework, enquanto que a server foi desenvolvida em Ruby on Rails.

Utilizamos um único código tanto para a versão web quanto para a mobile.

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

## Geração do APK

echo "************** remover debug console plugin"

cordova plugin rm cordova-plugin-console

echo "************** gerar o build para Android"

cordova build --release android


echo "************** Gerar a chave privada com o comando abaixo.  Gere uma única vez porque se gerar outra impede a atualizacao do apk na Play Store"

> usar este comando para gerar a chave: 
> keytool -genkey -v -keystore my-release-key.keystore -alias alias_name -keyalg RSA -keysize 2048 -validity 10000

echo "************** Aplicar a chave no APK"

jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore /home/rick/trabalho/1sistemas/jornadaib/mobile/platforms/android/build/outputs/apk/android-release-unsigned.apk alias_name

echo "************** remove o apk antigo"

rm jornadaib.apk

echo "************** zip align tool para otimizar APK"

> Dependendo de onde esteja o zipaligin:
> ~/./Development/android-sdk-linux/build-tools/22.0.1/zipalign -v 4 /home/rick/trabalho/1sistemas/jornadaib/mobile/platforms/android/build/outputs/apk/android-release-unsigned.apk jornadaib.apk

/home/XXX/Android/Sdk/build-tools/23.0.2/zipalign -v 4 /home/XXX/trabalho/1sistemas/jornadaib/mobile/platforms/android/build/outputs/apk/android-release-unsigned.apk jornadaib.apk
