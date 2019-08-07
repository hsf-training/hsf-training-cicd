# start from the base contur image provided by the UCL folks
FROM huangjoanna/contur

# perform everything as root user in the main /contur directory
USER root
WORKDIR /contur

# put madgraph inside
RUN wget https://launchpad.net/mg5amcnlo/2.0/2.6.x/+download/MG5_aMC_v2.6.6.tar.gz && \
    tar -xzf MG5_aMC_v2.6.6.tar.gz && \
    rm MG5_aMC_v2.6.6.tar.gz
   
# need rsync command to run the pythia install
RUN yum -y install rsync 

# install pythia inside of madgraph
RUN cd MG5_aMC_v2_6_6 && \
    echo "install pythia8" >> install.dat && \
    ./bin/mg5_aMC install.dat && \
    rm install.dat

# get the DMsimp model and put it within the madgraph image
RUN cd MG5_aMC_v2_6_6/models && \
    wget http://feynrules.irmp.ucl.ac.be/raw-attachment/wiki/DMsimp/DMsimp_s_spin1_v2.1.zip && \
    unzip DMsimp_s_spin1_v2.1.zip && \
    rm DMsimp_s_spin1_v2.1.zip

# leave the image in the contur directory space
WORKDIR /contur
