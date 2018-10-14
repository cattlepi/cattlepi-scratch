export HOME=/sd
cd $HOME && git clone https://github.com/cattlepi/cattlepi.git
cd $HOME/cattlepi && make envsetup

# need to figure out the nodes and if they are free
export BUILDER_NODE=${BUILDER_NODE:-192.168.1.235}