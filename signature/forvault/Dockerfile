FROM ubuntu:23.04

RUN apt update && \
	apt upgrade -y && \
	apt install -y \
	build-essential \
	gcc-multilib \
	git \
	wget \
	bc \
	squashfs-tools \
	u-boot-tools \
	kmod \
	bison \
	flex \
	rsync \
	automake \
	libtool \
	pkg-config \
	mtd-utils \
    tzdata

# Обновляем системные пакеты и устанавливаем Docker
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io

# Обновление пакетного менеджера и установка необходимых пакетов
# RUN apt-get update \
#     && apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# # Добавление официального ключа Docker GPG
# RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# # Настройка репозитория Docker
# RUN echo \
#     "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
#     $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# # Установка Docker Engine
# RUN apt-get update \
#     && apt-get install -y docker-ce docker-ce-cli containerd.io

RUN apt install -y \
	nodejs \
	npm

RUN npm i -gq \
	grunt-cli \
	generator-bbb \
	coveralls \
	bower

RUN npm i -gq \
	bbb \
	grunt \
	grunt-bbb-requirejs \
	grunt-bbb-styles \
	grunt-beep \
	grunt-cache-bust \
	grunt-connect-proxy \
	grunt-contrib-clean \
	grunt-contrib-compress \
	grunt-contrib-connect \
	grunt-contrib-copy \
	grunt-contrib-cssmin \
	grunt-contrib-jshint \
	grunt-contrib-less \
	grunt-contrib-watch \
	grunt-karma \
	grunt-karma-coveralls \
	grunt-notify \
	grunt-processhtml \
	grunt-terser \
	karma-coverage \
	karma-jasmine \
	karma-mocha \
	karma-qunit

RUN git clone https://github.com/LuaJIT/LuaJIT.git
WORKDIR /LuaJIT
RUN git checkout "v2.1.0-beta3"
RUN make install
RUN ln -s /usr/local/bin/luajit-2.1.0-beta3 /usr/local/bin/luajit
WORKDIR /

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN date > /image_date.txt

# Установка необходимых инструментов для Python
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv && \
    apt-get clean

# Создание виртуального окружения
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Устанавливаем необходимые библиотеки Python
RUN pip install hvac

COPY extraction_vault extraction_vault
COPY images/signvault.tar signvault.tar

# RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.39.3/install.sh | bash
# RUN /bin/bash -c 'source ~/.profile'
# RUN nvm install 20.10.0
# CMD ["/bin/bash"]
# CMD ["/bin/bash","-c", "/bin/bash"]
CMD ["/bin/bash","-c", "dockerd & sleep 10 && docker load -i signvault.tar && docker run -p 0.0.0.0:8200:8200 --name signvault --rm -d signvault && docker ps -a ; docker exec signvault ./start.sh; /bin/bash"]

