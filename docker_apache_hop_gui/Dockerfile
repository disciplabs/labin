FROM dorowu/ubuntu-desktop-lxde-vnc

# Remover repositórios conflitantes e instalações anteriores
RUN rm /etc/apt/sources.list.d/google-chrome.list || true
#RUN apt-get remove -y google-chrome-stable || true

# Atualizar e instalar dependências necessárias
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg2 \
    ca-certificates \
    openjdk-11-jdk \
    unzip \
    firefox

# Baixar e instalar o Apache Hop GUI
#RUN wget https://downloads.apache.org/hop/2.8.0/apache-hop-client-2.8.0.zip -O /opt/hop.zip && \
#    unzip /opt/hop.zip -d /opt/ && \
#    rm /opt/hop.zip

# Baixar e instalar o Apache Hop GUI
RUN wget https://downloads.apache.org/hop/2.8.0/apache-hop-client-2.8.0.zip -O /opt/hop.zip && \
    unzip /opt/hop.zip -d /opt/ && \
    rm /opt/hop.zip

# Ajustar permissões
RUN chmod -R 777 /opt/hop

# Configurar variáveis de ambiente
ENV HOP_HOME=/opt/hop
ENV PATH="$HOP_HOME:$PATH"

# Iniciar o hop-gui e o Firefox automaticamente
RUN echo "/opt/hop/hop-gui.sh &" >> /opt/startup.sh
RUN echo "firefox &" >> /opt/startup.sh

# Limpar cache do apt-get
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expor a porta para o noVNC
EXPOSE 80
