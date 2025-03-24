# ROS 2 + Nav2 en Docker

Este proyecto proporciona un entorno preconfigurado en Docker para trabajar con ROS 2 Humble, Nav2 y otras herramientas necesarias para simulación y desarrollo de robótica.

## Características:
- Basado en Ubuntu 22.04 + ROS 2 Humble.
- Integración con Nav2 para navegación.
- Uso de Zsh con Oh My Zsh.
- Carpetas compartidas con el sistema host.
- Acceso a la interfaz gráfica (RViz, Gazebo, etc.).

## Requisitos previos

Antes de ejecutar el contenedor, asegúrate de cumplir con estos requisitos:

### En Ubuntu
1. Tener instalado Docker 

### En Windows (WSL 2)
1. Instalar WSL 2 con Ubuntu si aún no lo tienes:
   wsl --install -d Ubuntu

2. Instalar Docker Desktop con soporte para WSL 2:
   - Descárgalo de https://www.docker.com/products/docker-desktop/
   - Activa la integración con WSL 2 en la configuración de Docker Desktop.

3. Verifica que Docker funciona en WSL:
   docker --version

4. Habilitar acceso a X11 en WSL 2 (para aplicaciones gráficas como RViz y Gazebo).
   

## Cómo ejecutar el contenedor

### 1. Clona este repositorio
```
   git clone https://github.com/miggilcas/p1_AdR_GIERM.git
   cd p1_AdR_GIERM
```
### 2. Crear carpeta compartida
Es obligatorio crear una carpeta en `~/` llamada `AdR`, ya que el contenedor está configurado para usarla como almacenamiento compartido.
```
   mkdir -p ~/AdR
```
Si quieres acceder a esta carpeta desde WSL en Windows, puedes usar:
   explorer.exe .

Si estás en Ubuntu, ya tendrás acceso a la carpeta directamente dentro del contenedor.

### 3. Edita la configuración (Opcional)
Abre `config.env` y ajusta las variables según tus necesidades:
   nano config.env

Ejemplo de configuración:
```
   CONTAINER_NAME=adr_humble_zsh
   IMAGE_NAME=adr_humble_zsh
   USER_NAME=student
   DISPLAY=${DISPLAY}
   X11_SOCKET=/tmp/.X11-unix
   NETWORK=host
   PORTS="11311:11311 9090:9090 14550:14550/udp 14570:14570/udp 14560:14560"
   SHARED_PATHS='${HOME}/AdR'

```

### 4. Construir la imagen Docker
```
   ./manage_container.sh o ./manage_container_WSL.sh
```


Si deseas utilizar un editor de código, puedes instalar y usar Visual Studio Code. En WSL, puedes abrir la carpeta de trabajo con:
```
   code .
```
## Verificación y pruebas

Para comprobar que ROS 2 funciona correctamente en el contenedor:

### Probar Publicadores y Subscriptores
En una terminal dentro del contenedor:
```
   ros2 topic pub /test_topic std_msgs/msg/String "{data: 'Hola desde Docker!'}" --rate 1
```
En otra terminal dentro del contenedor:
```
   ros2 topic echo /test_topic
```
Si todo está bien, deberías ver los mensajes enviados en la segunda terminal.

### Probar Rviz
Ejecuta:
```
   rviz2
```
Si se abre sin errores, significa que el acceso gráfico funciona correctamente.



## Tutoriales útiles
Si tienes problemas durante la instalación o configuración, puedes revisar estos tutoriales:

### Instalación de Docker en Windows 11:
[How To Install Docker on Windows 11 - Step-by-Step for Beginners (Updated 2025)](https://www.youtube.com/watch?v=bw-bMhlhcpg)

### Configuración completa de Docker en Windows con WSL 2:
[Docker Complete Setup on Windows (With WSL Ubuntu)](https://www.youtube.com/watch?v=2ezNqqaSjq8)

### Instalación de Ubuntu en WSL 2:
[Problemas al instalar Ubuntu en WSL? How to Install Ubuntu on Windows 11 (WSL)](https://www.youtube.com/watch?v=wjbbl0TTMeo)

## Contacto y soporte
Si tienes problemas o sugerencias, abre un issue en el repositorio de GitHub.

