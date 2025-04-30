#!/usr/bin/bash

### Opcion 0 ###
function EmpaquetaycomprimeFicherosProyecto()
{
  cd /home/$USER/formulariocitas
  tar cvzf  /home/$USER/formulariocitas.tar.gz app.py script.sql  .env requirements.txt templates/*
}

### Opcion 1 ###
function EliminarMySQL()
{
#Para el servicio
sudo systemctl stop mysql.service
#Elimina los paquetes +ficheros de configuración + datos
sudo apt purge mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*
#servidor MySQL se desinstale completamente sin dejar archivos de residuos.
sudo apt autoremove
#Limpia la cache
sudo apt autoclean
#Para cerciorarnos de que queda todo limpio:
#Eliminar los directorios de datos de MySQL:
sudo rm -rf /var/lib/mysql
#Eliminar los archivos de configuración de MySQL:
sudo rm -rf /etc/mysql/
#Eliminar los logs
sudo rm -rf /var/log/mysql
}

### Opcion 2 ###
function CrearNuevaUbicacion()
{
    if [ -d /var/www/formulario ]
    then
        echo -e "Borrando el contenido del direcctorio...\n"
        sudo rm -rf /var/www/formulariocitas
    fi
    echo "Creando directorio..."
    sudo mkdir -p /var/www/formulariocitas
    echo "Cambiando permisos del directorio..."
    sudo chown -R $USER:$USER /var/www/formulariocitas
    echo ""
    read -p "PULSA ENTER PARA CONTINUAR..."
}

### Opcion 3 ###
function CopiarFicherosProyectoNuevaUbicacion()
{
   if [ ! -e "/home/$USER/formulariocitas.tar.gz" ]
        then
echo -e "no tienes el fichero preparado, ejecuta la opción 0"
   elif [ ! -d "/var/www/formulariocitas" ]
        then
echo -e "no tienes el directorio preparado, ejecuta la opción 2"
   else
    echo "Moviendo el fichero..."
    mv /home/$USER/formulariocitas.tar.gz /var/www/formulariocitas/
    echo "Descomprimiendo el fichero..."
    sudo tar xvzf /var/www/formulariocitas/formulariocitas.tar.gz
   fi
   read -p "PULSA ENTER PARA CONTINUAR..."
   
}

### Opcion 4 ###
function InstalarMySQL()
{

instaladorMySQL = $(sudo dpkg -s mysql-server | grep "Status: install ok installed")
if [ -z "$instaladorMySQL" ]
then
echo "instalando \n"
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql.service
sudo systemctl status mysql.service
else
echo -e "mysql-server ya esta instalado en el dispositivo"
estadoMySQL = $(sudo systemctl status mysql-service | grep "Active: active(running)")
if [ -z "$estadoMySQL" ]
then
echo -e "no esta arrancado\n"
echo -e "arrancando\n"
sudo systemctl start nginx.service
else
echo "mysql.service ya esta arrancado"
fi
sudo systemctl status mysql.service
fi

}

### Opcion 5 ###
function CrearUsuarioBasesDeDatos()
{
touch $HOME/crearusuariobd.sql
echo "CREATE USER 'lsi'@'localhost' IDENTIFIED BY 'lsi';" > $HOME/crearusuariobd.sql
echo "GRANT CREATE, ALTER, DROP, INSERT, UPDATE, INDEX, DELETE, SELECT, REFERENCES, RELOAD on *.* TO 'lsi'@'localhost' WITH GRANT OPTION;" >> $HOME/crearusuariobd.sql
echo "FLUSH PRIVILEGES;" >> $HOME/crearusuariobd.sql

sudo mysql < $HOME/crearusuariobd.sql
}

### Opcion 6 ###
function CrearBaseDeDatos()
{
mysql -u lsi -p < /var/www/formulariocitas/script.sql
}

### Opcion 7 ###
function EjecutarEntornoVirtual()
{
sudo apt update
sudo apt -y upgrade
sudo apt-get update
sudo apt install -y python3-pip
sudo apt install python3-dev build-essential libssl-dev libffi-dev python3-setuptools
sudo apt install python3-venv
cd /var/www/formulariocitas
python3 -m venv venv
source v/var/www/formulariocitas/venv/bin/activate
}

### Opcion 8 ###
function InstalarLibreriasEntornoVirtual()
{
cd /var/www/formulariocitas
source venv/bin/activate
python3 -m pip install --upgrade pip
pip install -r requirements.txt
deactivate
}

### Opcion 9 ###
function Probandotodoconservidordedesarrollodeflask()
{
cd /var/www/formulariocitas
source venv/bin/activate
firefox http://127.0.0.1:5000 &
python3 /var/www/formulariocitas/app.py
}

### Opcion 10 ###
function InstalarNGINX()
{
instaladorNGINX = $(sudo dpkg -s nginx.service | grep "Status: install ok installed")
if [ -z "$instaladorNGINX" ]
then
echo "instalando \n"
sudo apt update
sudo apt install nginx
sudo systemctl start nginx.service
sudo systemctl status nginx.service
else
echo -e "nginx.service ya esta instalado en el dispositivo"
fi
}

### Opcion 11 ###
function ArrancarNGINX()
{
estadoNGINX = $(sudo systemctl status nginx.service | grep "Active: active(running)")
if [ -z "$estadoNGINX" ]
then
echo -e "no esta arrancado\n"
echo -e "arrancando\n"
sudo systemctl start nginx.service
else
echo "mysql.service ya esta arrancado"
sudo systemctl status nginx.service
fi
}

### Opcion 12 ###
function TestearPuertosNGINX()
{
instaladorNetTools = $(sudo dpkg -s net-tools | grep "Status: install ok installed")
if [ -z "$instaladorNetTools" ]
then
echo "instalando \n"
sudo apt update
sudo apt install net-tools
sudo netstat -anp | grep nginx
else
sudo netstat -anp | grep nginx
fi
}

### Opcion 13 ###
function VisualizarIndex()
{
firefox http://127.0.0.1
}


### Opcion 14 ###
function PersonalizarIndex()
{
echo "Sin implementar UnU"
}

### Opcion 15 ###
function InstalarGunicorn()
{
instaladorGunicorn = $(sudo dpkg -s gunicorn | grep "Status: install ok installed")
if [ -z "$instaladorGunicorn" ]
then
cd /var/www/formulariocitas
source venv/bin/activate
echo "instalando \n"
pip install gunicorn
deactivate
else
echo "Gunicorn ya está instalado \n"
fi
}

### Opcion 16 ###
function ConfigurarGunicorn()
{
sudo echo 'from app import app
if __name__ == "__main__":
   app.run()' > /var/www/formulariocitas/wsgi.py
source venv/bin/activate
/var/www/formulariocitas$ gunicorn --bind 127.0.0.1:5000 wsgi:app
deactivate
}

### Opcion 17 ###
function PasarPropiedadyPermisos()
{
#pasamos la propiedad de todo dentro de formulariocitas a www-data y cambiamos el grupo de eso mismo tambien a www-data
sudo chown -R www-data:www-data /var/www/formulariocitas
}

### Opcion 18 ###
function crearServicioSystemdFormularioCitas()
{
sudo echo '[Unit]
Description=Gunicorn instance to serve Flask
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/formulariocitas
Environment="PATH=/var/www/formulariocitas/venv/bin"
ExecStart=/var/www/formulariocitas/venv/bin/gunicorn --bind 127.0.0.1:5000 wsgi:app
Restart=always

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/formulariocitas.service
sudo systemctl daemon-reload
sudo systemctl start formulariocitas
systemctl status formulariocitas
}

### Opcion 19 ###
function ConfigurarNginxProxyInverso()
{
sudo echo 'server {
    listen 8080;
    server_name localhost;
    location / {
        proxy_pass http://127.0.0.1:5000;
    }
}' > /etc/nginx/conf.d/formulariocitas.conf
sudo nginx -t
}

### Opcion 20 ###
function CargarFicherosConfiguracionNginx()
{
sudo systemctl reload nginx
}

### Opcion 21 ###
function RearrancarNginx()
{
sudo systemctl restart nginx
}

### Opcion 22 ###
function TestearVirtualHost()
{
firefox http://127.0.0.1:3128
}

### Opcion 23 ###
function VerNginxLogs()
{
tail /var/log/nginx/error.log
}

### Opcion 24 ###
function CopiarServidorRemoto()
{
    salida = $(sudo dpkg -s openssh-server | grep "Status: install ok installed")
    if [ -z "$salida" ]
    then
echo "instalando \n"
sudo apt update
sudo apt install openssh-server
    else
echo -e "openssh-server ya esta instalado en el dispositivo"
    fi

    salida = $(sudo systemctl status oepnssh-server | grep "Active: active(running)")
    if [ -z "$estadoNGINX" ]
    then
echo -e "no esta arrancado\n"
        echo -e "arrancando\n"
        sudo systemctl start openssh-server
    else
        echo "nginx.service ya esta arrancado"
    fi
    sudo systemctl status openssh-server

    read -p "Inserta la IP del servidor" ip
    scp /home/$USER/formulariocitas.tar.gz $USER@$ip:/home/$USER/
    scp /home/$USER/menu.sh $USER@$ip:/home/$USER/
}
### Opcion 25 ###
LOG_DIR="/var/log/"
function ControlarIntentosConexionSSH()
{
  for log_file in $(ls "${LOG_DIR}" | grep "auth.log"); do
  cat "${LOG_DIR}${log_file}" | grep "sshd" | while read line
  do
  if [[ ${line} =~ "Failed" ]]
  then
      echo "Status: [fail] Account name: ${line:16:20} Date: ${line:0:15}"
                elif [[ $line =~ "Accepted" ]]
                then
      echo "Status: [accept] Account name: ${line:16:20} Date: ${line:0:15}"
                fi
  done
  done
}

### Opcion 26 ###
function SalirMenu()
{
echo "Fin del Programa"
}

### Opcion Secreta ###
function EasterEgg()
{
echo "Compre nuestros sobres de purificación de agua, ashe2o la marca elegida por Lamin Yamal"
}

### Main ###

#variable donde el usuario elige la opcion del menu
opcionmenuppal=0

#texto que aparece antes del menu la primera vez que se lanza

echo -e "Bienvenido al instalador de aplicacion web Yamin_Lamal 1.13"
echo -e "\nPara completar la instalacion lance todas las operaciones listadas a continuacion; NO TODAS SON OBLIGATORIAS PERO LE AYUDARAN A ENTENDER SI SE HAN REALIZADO BIEN LAS ANTERIORES"
echo -e "\ntodos los derechos reservados a Ashe2o.inc© 2025"
echo -e "\n\nEstas son las operaciones disponibles"

#bucle para pedir mas de una opcion
while test $opcionmenuppal -ne 26
do
    #Muestra el menu
    echo -e "0   Empaqueta y comprime los ficheros clave del proyecto"
    echo -e "1   Eliminar la instalación de mysql"
    echo -e "2   Crea la nueva ubicación"
    echo -e "3   Copiar ficheros a la nueva hubicación"
    echo -e "4   Instalar MySQL"
    echo -e "5   Crea un nuevo usuario en la base de datos"
    echo -e "6   Crear base de datos"
    echo -e "7   Ejecutar entorno virtual"
    echo -e "8   Instalar librerias en el entorno virtual"
    echo -e "9   Prueba con servidor de desarrollo de flask"
    echo -e "10  Instalar NGINX"
    echo -e "11  Arrancar NGINX"
    echo -e "12  Testear puertos NGINX"
    echo -e "13  visualizar index"
    echo -e "14  personalizar index"
    echo -e "15  instalar gunicorn"
    echo -e "16  configurar gunicorn"
    echo -e "17  pasar propiedas y permisos"
    echo -e "18  Crear servicio Systemd Formulario citas "
    echo -e "19  Configurar  NGINX Proxy Inversor"
    echo -e "20  cargar ficheros de configuracion NGINX"
    echo -e "21  rearrancar NGINX"
    echo -e "22  testear visual Host"
    echo -e "23  ver NGINX logs"
    echo -e "24  copiar el servidor remoto"
    echo -e "25  controlar intentos de conexion SSH"
    echo -e "26  salir del Menu \n"

    #Lee el numero asociado a la opcion que desea ejecutar el usuario
    read -p "Elige una opcion:" opcionmenuppal

    #Se identifica dicha opcion
    case $opcionmenuppal in
         0) EmpaquetaycomprimeFicherosProyecto;;
         1) EliminarMySQL;;
         2) CrearNuevaUbicacion;;
         3) CopiarFicherosProyectoNuevaUbicacion;;
         4) InstalarMySQL;;
         5) CrearUsuarioBasesDeDatos;;
         6) CrearBaseDeDatos;;
         7) EjecutarEntornoVirtual;;
         8) InstalarLibreriasEntornoVirtual;;
         9) Probandotodoconservidordedesarrollodeflask;;
         10) InstalarNGINX;;
         11) ArrancarNGINX;;
         12) TestearPuertosNGINX;;
         13) VisualizarIndex;;
         14) PersonalizarIndex;;
         15) InstalarGunicorn;;
         16) ConfigurarGunicorn;;
         17) PasarPropiedadyPermisos;;
         18) crearServicioSystemdFormularioCitas;;
         19) ConfigurarNginxProxyInverso;;
         20) CargarFicherosConfiguracionNginx;;
         21) RearrancarNginx;;
         22) TestearVirtualHost;;
         23) VerNginxLogs;;
         24) CopiarServidorRemoto;;
         25) ControlarIntentosConexionSSH;;
         26) SalirMenu;;
         69) EasterEgg;;
        *) ;;
    esac

#si el usuario quiere ejecutar otra orden muestra un mensaje extra
         if [ $opcionmenuppal != 26 ]
           then
           echo -e "\n ¿ Que mas desea hacer ? : \n"
         fi
done
exit 0
