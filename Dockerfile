FROM continuumio/miniconda3:4.12.0

WORKDIR /skypilot

# Install SkyPilot + dependencies
RUN conda install -c conda-forge google-cloud-sdk && \
    apt update -y && \
    apt install rsync nano vim -y && \
    rm -rf /var/lib/apt/lists/* \

# Install SkyPilot from src
RUN cd ~ && \
    git clone https://github.com/skypilot-org/skypilot && \
    cd skypilot && \
    pip install -e ".[all]" && \
    git remote add lambda https://github.com/ewzeng/skypilot && \
    git fetch lambda && \
    git checkout lambda-labs-v3 && \
    git branch lambda && \
    mkdir -p ~/.sky/catalogs/v5/lambda/ \

COPY lambda-catalog.csv ~/.sky/catalogs/v5/lambda/lambda-catalog.csv

# Exclude usage logging message
RUN mkdir -p /root/.sky && touch /root/.sky/privacy_policy

# Add files which may change frequently
COPY ./playground /skypilot/

COPY instructions.txt /skypilot/instructions.txt

# Set bash as default shell
ENV SHELL /bin/bash

RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd' \
    >> /etc/bash.bashrc \
    ; echo "\
 _____ _         ______ _ _       _   \n\
/  ___| |        | ___ (_) |     | |  \n\
\ \`--.| | ___   _| |_/ /_| | ___ | |_ \n\
 \`--. \ |/ / | | |  __/| | |/ _ \| __|\n\
/\__/ /   <| |_| | |   | | | (_) | |_ \n\
\____/|_|\_\\__, \_|   |_|_|\___/ \__|\n\
             __/ |                    \n\
            |___/    \n\
\n\
Welcome to the SkyPilot playground!\n\
\n\
This environment has SkyPilot installed and a cloud account ready for use.\n\
\n\
To start, we have defined a SkyPilot task for you in train.yaml.\n\
\n\
============================== Some SkyPilot Commands to try =================================\n\
+---------------------------------+----------------------------------------------------------+\n\
|             Command             |                        Description                       |\n\
+=================================+==========================================================+\n\
|          cat train.yaml         | Show an example SkyPilot YAML to train a simple ML model |\n\
+---------------------------------+----------------------------------------------------------+\n\
| sky launch -c myclus train.yaml | Create a cluster named myclus to run the train.yaml task |\n\
+---------------------------------+----------------------------------------------------------+\n\
|         sky logs myclus         |            Check the logs of the running task            |\n\
+---------------------------------+----------------------------------------------------------+\n\
|            sky status           |                   See running clusters                   |\n\
+---------------------------------+----------------------------------------------------------+\n\
|         sky down myclus         |                Terminate a running cluster               |\n\
+---------------------------------+----------------------------------------------------------+\n\
|    sky spot launch train.yaml   |    Run the training task with Managed Spot instances     |\n\
+---------------------------------+----------------------------------------------------------+\n\
|          sky show-gpus          |            List the GPUs available to SkyPilot           |\n\
+---------------------------------+----------------------------------------------------------+\n\
|              sky -h             |                    Show SkyPilot help                    |\n\
+---------------------------------+----------------------------------------------------------+\n\
\n\
Visit https://skypilot.readthedocs.io/ for more information.\n\
\n\
Note that only one cloud is available for this playground, so the optimizer may not list other cloud providers.\n\
\n"\
    > /etc/motd

#---------------------------------------------------------------------
# Tini entrypoint
#---------------------------------------------------------------------

# Add Tini init script - take care of runaway processes
ENV TINI_VERSION v0.7.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ENV SKYPILOT_MINIMIZE_LOGGING 1

COPY credentials.tar.gz /root/credentials.tar.gz
RUN tar -xzf /root/credentials.tar.gz -C ~ && \
    rm /root/credentials.tar.gz

RUN sky check

WORKDIR /skypilot/skypilot

# Add git branch name to PS1
# RUN echo 'export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;31m\]$(__git_ps1 " (%s)")\[\033[00m\]\$ "' >> /root/.bashrc

ENTRYPOINT ["/tini", "--"]
