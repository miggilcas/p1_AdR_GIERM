# Usamos la imagen base de PX4 con ROS Humble
FROM ros:humble

# Evitar preguntas interactivas en la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Definir usuario y contraseña por defecto
ARG USER_NAME="student"
ARG USER_PASSWORD="student"

ENV USER_NAME $USER_NAME
ENV USER_PASSWORD $USER_PASSWORD
ENV CONTAINER_IMAGE_VER=v1.0.0

RUN echo $USER_NAME
RUN echo $USER_PASSWORD
RUN echo $CONTAINER_IMAGE_VER

# Actualizar e instalar herramientas necesarias
RUN apt-get update && apt-get install -y \
  sudo \
  curl \
  git-core \
  gnupg \
  locales \
  nodejs \
  zsh \
  wget \
  nano \
  npm \
  fonts-powerline \
  && locale-gen en_US.UTF-8 \
  && adduser --quiet --disabled-password --shell /bin/zsh --home /home/$USER_NAME --gecos "User" $USER_NAME \
  && echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd && usermod -aG sudo $USER_NAME



# Instalar paquetes adicionales de ROS 2 (Nav2, Turtlebot3, Filtros de Kalman y partículas)
RUN apt update && apt install -y \
  ros-humble-navigation2 \
  ros-humble-nav2-bringup \
  ros-humble-turtlebot3* \
  ros-humble-robot-localization \
  ros-humble-nav2-amcl \
  python3-pip && \
  pip install filterpy

# Instalar herramientas de visualización y depuración en ROS 2
RUN apt update && apt install -y \
  ros-humble-rviz2 \
  ros-humble-gazebo-ros-pkgs \
  ros-humble-ros2bag \
  ros-humble-ros2launch \
  ros-humble-plotjuggler-ros && \
  apt clean
# Cambiar al nuevo usuario
USER $USER_NAME
WORKDIR /home/$USER_NAME
# terminal colors with xterm
ENV TERM xterm

# set the zsh theme
ENV ZSH_THEME agnoster
# Configurar Zsh con Oh My Zsh
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true && \
  echo "export ZSH_THEME=agnoster" >> /home/$USER_NAME/.zshrc && \
  chown $USER_NAME:$USER_NAME /home/$USER_NAME/.zshrc

# Instalar plugin zsh-autosuggestions para sugerencias de comandos
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
  echo "plugins=(git zsh-autosuggestions)" >> ~/.zshrc && \
  echo "source /opt/ros/humble/setup.zsh" >> ~/.zshrc
# Crear el directorio de trabajo si no existe
RUN mkdir -p /home/student/ros2_ws && chown student:student /home/student/ros2_ws


# Iniciar Zsh al entrar en el contenedor
CMD ["zsh"]

