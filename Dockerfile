FROM continuumio/miniconda3:23.3.1-0

WORKDIR /skypilot

# Install SkyPilot + dependencies
RUN conda install -c conda-forge google-cloud-sdk && \
    apt update -y && \
    apt-get install --no-install-recommends -y \
    git gcc rsync sudo patch openssh-server \
    pciutils nano fuse socat netcat-openbsd curl rsync vim tini && \
    pip install skypilot-nightly && \
    rm -rf /var/lib/apt/lists/*

# Define API URL as a build argument with a default value
ARG API_URL=http://localhost:46580
RUN sky api login -e ${API_URL}

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
|    sky jobs launch train.yaml   |   Run the training as a Managed Job with auto recovery   |\n\
+---------------------------------+----------------------------------------------------------+\n\
|          sky show-gpus          |            List the GPUs available to SkyPilot           |\n\
+---------------------------------+----------------------------------------------------------+\n\
|              sky -h             |                    Show SkyPilot help                    |\n\
+---------------------------------+----------------------------------------------------------+\n\
\n\
Visit https://docs.skypilot.co/ for more information.\n\
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

ENTRYPOINT ["/tini", "--"]
