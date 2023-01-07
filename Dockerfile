FROM continuumio/miniconda3:4.12.0

WORKDIR /skypilot

# ADD ./requirements.txt /skypilot-tutorial/requirements.txt

# Install tutorial dependencies
# RUN pip install -r requirements.txt

# Install SkyPilot + dependencies
RUN conda install -c conda-forge google-cloud-sdk && \
    apt update -y && \
    apt install rsync nano -y && \
    pip install skypilot[aws,gcp] && \
    rm -rf /var/lib/apt/lists/*

# Exclude usage logging message
RUN mkdir -p /root/.sky && touch /root/.sky/privacy_policy

# Add files which may change frequently
COPY ./playground /skypilot/

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
This environment has SkyPilot installed and a GCP account ready for use.\n\
\n\
Feel free to explore SkyPilot, launch clusters and queue jobs.\n\
\n\
To start, we have defined a SkyPilot task for you. Have a look at train.yaml in this directory 'cat train.yaml'.\n\
\n\
Run 'sky launch train.yaml' to run your first skypilot task! \n\
\n\
Run 'sky -h' to see all available commands, or visit https://skypilot.readthedocs.io/.\n\
\n\
Note that only GCP is available for this playground, so the optimizer may not list other cloud providers.\n\
\n"\
    > /etc/motd

#---------------------------------------------------------------------
# Tini entrypoint
#---------------------------------------------------------------------

# Add Tini init script - take care of runaway processes
ENV TINI_VERSION v0.7.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ENTRYPOINT ["/tini", "--"]

# CMD ["/bin/bash", "-c", "cp -a /credentials/. /root/;sky show-gpus;"]
# docker run -v D:/credentials_skypilot:/credentials:ro --rm -p 8888:8888 -it skypilot-playground "cp -a /credentials/. /root/ && /bin/bash"
