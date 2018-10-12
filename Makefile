clean:
	-killall confd
	-ncs --stop
	-rm -Rf logs/ ncs-cdb/ netsim/ packages/ scripts/ state/ target/ ncs.conf README.ncs README.netsim


netsim:
	-ncs-netsim create-device cisco-ios ios1
	-ncs-netsim add-device cisco-nx nx1
	-ncs-netsim start

nso:
	-ncs-setup --dest .
	-cp *.xml ncs-cdb
	-ncs
