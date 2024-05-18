from lib import config # do not import anything before this
from p4app import P4Mininet
from mininet.topo import Topo
from mininet.cli import CLI
from ipaddress import ip_address
import os

NUM_WORKERS = 8

class SMLTopo(Topo):
    def __init__(self, **opts):
        Topo.__init__(self, **opts)

    def build(self):
        switch = self.addSwitch("s1")
        for i in range(NUM_WORKERS):
            host = self.addHost(f"w{i}")
            self.addLink(switch, host)

def RunWorkers(net):
    """
    Starts the workers and waits for their completion.
    Redirects output to logs/<worker_name>.log (see lib/worker.py, Log())
    This function assumes worker i is named 'w<i>'. Feel free to modify it
    if your naming scheme is different
    """
    worker = lambda rank: "w%i" % rank
    log_file = lambda rank: os.path.join(os.environ['APP_LOGS'], "%s.log" % worker(rank))
    for i in range(NUM_WORKERS):
        net.get(worker(i)).sendCmd('python worker.py %d %d > %s' % (i, NUM_WORKERS, log_file(i)))
    for i in range(NUM_WORKERS):
        net.get(worker(i)).waitOutput()

def RunControlPlane(net):
    """
    One-time control plane configuration
    """
    #Add MAC entry of switch to table for ARP
    switch = net.switches[0]
    switch_mac = int("00:00:00:00:00:10".replace(":",""),16)
    switch.insertTableEntry(
        table_name="TheIngress.arp.arp_responder",
        match_fields={"hdr.arp.opcode": 1},
        action_name="TheIngress.arp.sendARPResponse",
        action_params={"switch_mac_addr": switch_mac},
    )

    #Add IP:Port entry in switch for all nodes
    port_to_node = {}
    for link in net.links:
        sw = link.intf1
        host = link.intf2
        port_no = sw.node.ports[sw]
        port_to_node[port_no] = host.node

    for key, value in switch.ports.items():
        if key.name.startswith(switch.name):
            switch.insertTableEntry(
                table_name="TheEgress.ur.udp_replier_table",
                match_fields={"standard_metadata.egress_port": value},
                action_name="TheEgress.ur.sendUDPReply",
                action_params={
                    "switch_mac_addr": switch_mac,
                    "node_mac": int(port_to_node[value].MAC().replace(":",""),16),
                    "node_ip": int(ip_address(port_to_node[value].IP())),
                },
            )

    #Muticast
    ports = []
    for key, value in switch.ports.items():
        if key.name.startswith(switch.name):
            ports.append(value)
    # setting up the broadcast groups
    switch.addMulticastGroup(mgid=1, ports=ports)

topo = SMLTopo()
net = P4Mininet(program="p4/main.p4", topo=topo)
net.run_control_plane = lambda: RunControlPlane(net)
net.run_workers = lambda: RunWorkers(net)
net.start()
net.run_control_plane()
CLI(net)
net.stop()
