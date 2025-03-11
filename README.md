# Introducción
Este documento explica cómo construir y ejecutar un contenedor Docker para ROS 2 (Humble) compatible con Windows y Linux. Dado que los alumnos pueden no estar familiarizados con Linux, se proporciona una solución dockerizada que elimina la necesidad de instalaciones complejas.

## 1. Requisitos previos
### Para Ubuntu (Linux)
- Tener instalado **Docker** y **Docker Compose**.
  - Instalar Docker:
    ```sh
    sudo apt update
    sudo apt install docker.io
    sudo systemctl enable --now docker
    ```
  - Agregar tu usuario al grupo `docker` para evitar usar `sudo`:
    ```sh
    sudo usermod -aG docker $USER
    newgrp docker
    ```
- (Opcional) Para aplicaciones gráficas, instalar un servidor X11:
  ```sh
  sudo apt install x11-xserver-utils
  ```

### Para Windows
- Instalar **Docker Desktop** con backend WSL2 habilitado.
  - Descargar desde [Docker](https://www.docker.com/products/docker-desktop/).
  - Habilitar **WSL2** y asegurarse de que Ubuntu esté instalado como distribución por defecto en WSL.
  - Asegurar que Docker Desktop tiene la opción "Use the WSL 2 based engine" activada.
- Instalar un servidor X11 como **VcXsrv** o **Xming** si se quieren usar aplicaciones gráficas:
  - Descargar e instalar [VcXsrv](https://sourceforge.net/projects/vcxsrv/).
  - Ejecutarlo con la opción "Disable access control".

## 2. Creación del Dockerfile
Creamos un archivo `Dockerfile` en un directorio de trabajo:
```dockerfile
FROM ros:humble

# Evita que el contenedor pregunte sobre la zona horaria
ENV DEBIAN_FRONTEND=noninteractive

# Instalar herramientas necesarias
RUN apt update && apt install -y \
    python3-pip \
    ros-humble-desktop \
    ros-humble-navigation2 \
    ros-humble-nav2-bringup \
    x11-apps && \
    rm -rf /var/lib/apt/lists/*

# Configurar entorno para ROS 2
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

CMD ["bash"]
```

## 3. Construcción del contenedor
Desde la carpeta donde se encuentra el `Dockerfile`, ejecutar:
```sh
docker build -t ros2_humble .
```

## 4. Ejecución del contenedor
### En Linux (Ubuntu)
Para lanzar el contenedor con acceso a la interfaz gráfica:
```sh
docker run -it --rm \
    --net=host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    ros2_humble
```
Si hay problemas con el acceso a X11, ejecutar:
```sh
xhost +
```

### En Windows (Docker Desktop con WSL2)
Primero, obtener la dirección IP de WSL2:
```sh
wsl hostname -I
```
Si la IP obtenida es, por ejemplo, `172.20.32.1`, ejecutar en PowerShell:
```powershell
$env:DISPLAY="172.20.32.1:0.0"
```
Luego, lanzar el contenedor:
```sh
docker run -it --rm \
    --net=host \
    -e DISPLAY=$env:DISPLAY \
    ros2_humble
```

## 5. Verificación
Para comprobar que ROS 2 y X11 funcionan, ejecutar dentro del contenedor:
```sh
rviz2
```
Si todo está correcto, se abrirá la interfaz de RViz.

---
Este contenedor proporcionará la base para las siguientes sesiones sobre ROS 2, incluyendo simulaciones y filtrado de datos.


