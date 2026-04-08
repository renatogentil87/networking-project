Phase 0: BGP Fundamentals Refresh (Week 1)

Goal: Rebuild your BGP muscle memory — from basics to advanced path selection

Networking Topics:

    BGP neighbor relationships (eBGP vs iBGP), states, and timers
    BGP path selection algorithm (all 15 steps): Weight → Local Preference → Locally Originated → AS Path → Origin → MED → eBGP over iBGP → IGP Metric → Oldest Path → Router ID → Neighbor IP
    BGP attributes: Well-known mandatory, well-known discretionary, optional transitive, optional non-transitive
    Route filtering: prefix-lists, route-maps, AS-path ACLs, community-based filtering
    BGP communities (standard, extended, large) and their use cases
    BGP summarization and the as-set keyword

Video Training:

    Orhan Ergun - CCIE SP v5 Course (you already have this) — BGP sections
    Orhan Ergun - CCNP ENARSI 300-410 Course (you already have this) — BGP deep-dive sections
    Keith Barker / CBT Nuggets — BGP Path Selection (search YouTube for free overview)
    INE CCNP Enterprise — BGP sections (if you have access)

EVE-NG Lab — BGP Fundamentals:

Topology: 4 routers — R1 and R2 in AS 65001 (iBGP), R3 in AS 65002, R4 in AS 65003

Lab Tasks:

    Configure eBGP between R1↔R3 and R2↔R4
    Configure iBGP between R1↔R2 (using loopbacks with update-source and next-hop-self)
    Advertise prefixes and verify the BGP table with show ip bgp
    Manipulate path selection: change Weight on R1, Local Preference on R2, prepend AS-path on R3
    Implement prefix-list filtering to block specific prefixes
    Configure BGP communities and filter based on community values
    Test convergence by shutting down links and observing failover

Python Automation Lab:

    Use netmiko library to SSH into EVE-NG routers and collect show ip bgp output
    Parse BGP table output using Python re (regex) to extract prefixes, next-hops, and AS-paths
    Build a simple script that compares BGP tables across all routers and flags inconsistencies

Estimated Time: 5–6 hours study + 4–5 hours EVE-NG lab + 2 hours Python
Phase 1: BGP Advanced — Route Reflectors, Confederations & Scaling (Week 2)

Goal: Master iBGP scaling techniques you've forgotten

Networking Topics:

    iBGP full-mesh problem and why route reflectors exist
    Route Reflector rules: client vs non-client, cluster-id, originator-id loop prevention
    Hierarchical Route Reflectors (RR of RRs)
    BGP Confederations — sub-AS design, when to use vs RR
    BGP Bestpath selection with RR (cluster-list length)
    BGP Additional Paths (Add-Path) for path diversity
    BGP Graceful Restart and NSF (Non-Stop Forwarding)

Video Training:

    Orhan Ergun - CCIE SP v5 Course — Route Reflector and Confederation sections
    INE — BGP Route Reflectors deep dive
    Cisco Live presentations — Search for "BRKMPL-2100" (BGP in SP networks)

EVE-NG Lab — Route Reflectors & Confederations:

Topology: 6 routers — AS 65001 with R1 and R2 as Route Reflectors, R3/R4/R5 as clients, R6 in AS 65002

Lab Tasks:

    Configure R1 and R2 as redundant Route Reflectors with different cluster-ids
    Configure R3, R4, R5 as RR clients
    Verify route reflection with show ip bgp — observe the originator-id and cluster-list attributes
    Simulate RR failure (shut R1) and verify R2 takes over
    Reconfigure the same topology using Confederations instead of RR (sub-AS 65010, 65020)
    Compare BGP table behavior between RR and Confederation designs
    Configure BGP Additional Paths on the RR to advertise multiple paths to clients

Python Automation Lab:

    Use napalm library to pull BGP neighbor state from all routers programmatically
    Build a script that validates all iBGP sessions are established and reports any down peers
    Create a Python script that generates a BGP topology diagram from show ip bgp summary output

Estimated Time: 5–6 hours study + 4–5 hours EVE-NG lab + 2 hours Python
Phase 2: Transit Gateway Deep Dive (Week 3)

(This is your existing Phase 1 — kept exactly as you had it)

Networking Topics:

    TGW routing between VPCs in the same region vs. different regions (TGW Peering)
    TGW with ECMP for IPsec VPN connections exceeding 1.25 Gbps
    TGW route tables, associations, propagations, and blackhole routes
    TGW appliance mode for stateful inspection
    TGW Connect attachments and GRE tunnels

re:Invent Videos: NET301, NET406, NET320

AWS Documentation: Transit Gateway Guide, TGW Route Tables, TGW Peering, AWS Networking Workshop

Hands-On Lab — Terraform: (Same as your existing Phase 1 lab — TGW route table segmentation with isolated and shared-services patterns)

Estimated Time: 5–6 hours networking study + 3–4 hours Terraform
Phase 3: MPLS Fundamentals — LDP, Labels & Forwarding (Week 4)

Goal: Rebuild your MPLS foundation from scratch

Networking Topics:

    MPLS architecture: Label Edge Router (LER/PE), Label Switch Router (LSR/P), label stack
    Label operations: Push, Swap, Pop, and Penultimate Hop Popping (PHP)
    Label Distribution Protocol (LDP) — neighbor discovery, session establishment, label binding
    MPLS forwarding: Label Forwarding Information Base (LFIB) vs FIB vs RIB
    MPLS and IGP interaction (OSPF/IS-IS as underlay)
    TTL propagation in MPLS
    MPLS traceroute and debugging

Video Training:

    Orhan Ergun - MPLS Bootcamp - Beginner to Advanced (you already have this!) — Start here
    Orhan Ergun - CCIE SP v5 Course — MPLS sections
    "MPLS in the SDN Era" book by Antonio Sanchez-Monge (highly recommended reference)
    Cisco Live — Search for "BRKMPL-1100" (MPLS fundamentals)

EVE-NG Lab — MPLS Fundamentals:

Topology: 5 routers in a linear chain — PE1 → P1 → P2 → P3 → PE2 (all in one IGP domain using OSPF)

Lab Tasks:

    Configure OSPF as the IGP underlay between all routers
    Enable MPLS and LDP on all core-facing interfaces
    Verify LDP neighbor adjacencies with show mpls ldp neighbor
    Verify label bindings with show mpls ldp bindings and show mpls forwarding-table
    Trace a packet from PE1 to PE2 — observe Push → Swap → Swap → Pop (PHP) behavior
    Use traceroute mpls to verify the label-switched path
    Disable PHP and observe the difference (explicit null)
    Shut down a link and observe LDP/IGP reconvergence

Python Automation Lab:

    Use netmiko to collect show mpls forwarding-table from all routers
    Build a Python script that maps the complete Label Switched Path (LSP) from PE1 to PE2 by correlating labels across routers
    Create a simple visualization of the MPLS label path using Python print statements (ASCII art topology)

Estimated Time: 5–6 hours study + 4–5 hours EVE-NG lab + 2 hours Python
Phase 4: Route 53 Resolver & Hybrid DNS (Week 5)

(This is your existing Phase 2 — kept exactly as you had it)

Estimated Time: 4–5 hours networking study + 3–4 hours Terraform
Phase 5: MPLS L3VPN — VRF, MP-BGP, PE/CE Routing (Week 6)

Goal: Master MPLS L3VPN — the most important MPLS application

Networking Topics:

    VRF (Virtual Routing and Forwarding) — VRF-lite vs MPLS VRF
    Route Distinguisher (RD) vs Route Target (RT) — critical distinction
    MP-BGP for VPNv4 address family between PE routers
    PE-CE routing protocols (static, OSPF, BGP, EIGRP)
    Route import/export with Route Targets
    Hub-and-spoke vs full-mesh VPN topologies using RT manipulation
    Inter-AS MPLS VPN (Option A, B, C) — overview

Video Training:

    Orhan Ergun - MPLS Bootcamp — L3VPN sections
    Orhan Ergun - CCIE SP v5 Course — L3VPN deep dive
    Cisco Live — Search for "BRKMPL-2100" (MPLS L3VPN)

EVE-NG Lab — MPLS L3VPN:

Topology: PE1 — P1 — P2 — PE2, with CE1 connected to PE1 and CE2 connected to PE2 (two customers: Customer-A and Customer-B)

Lab Tasks:

    Configure MPLS core (reuse from Phase 3 lab)
    Create VRFs on PE1 and PE2 for Customer-A (RD 65001:100, RT 65001:100) and Customer-B (RD 65001:200, RT 65001:200)
    Configure MP-BGP VPNv4 peering between PE1 and PE2 (using loopbacks)
    Configure PE-CE routing: OSPF for Customer-A, BGP for Customer-B
    Verify VRF routing tables with show ip route vrf CUST-A and show ip bgp vpnv4 all
    Verify end-to-end connectivity: CE1-A can reach CE2-A but NOT CE1-B or CE2-B
    Implement hub-and-spoke: modify RTs so Customer-A spoke sites must route through a hub CE
    Verify traffic flow through the hub

Python Automation Lab:

    Build a script using netmiko that collects VRF routing tables from all PEs and generates a per-customer route report
    Create a Python script that validates VRF isolation — checks that no routes leak between customers
    Use jinja2 templates to generate VRF configurations from a YAML data file (infrastructure as code for Cisco!)

Estimated Time: 6–7 hours study + 5–6 hours EVE-NG lab + 3 hours Python
Phase 6: Direct Connect, DXGW & Hybrid Connectivity (Week 7)

(This is your existing Phase 3 — enhanced with DX Gateway lab)

Networking Topics:

    DX location types, MACsec encryption, port speeds
    DX Gateway (DXGW) — connecting VPCs in different regions, allowed prefixes, association limits
    DX + TGW integration patterns (Transit VIF)
    DX resiliency models (single/dual location, maximum resiliency)
    Public VIF, Private VIF, Transit VIF — when to use each
    BGP routing with DX — local preference, AS-path prepending, MED for path influence
    DX failover to VPN (backup path design)

re:Invent Videos: NET403, NET410, NET317, NET204

Hands-On Lab — Terraform (DX + DXGW Simulation):

Since you can't create real DX connections in a lab, simulate the architecture:

    Deploy a Customer Gateway with BGP ASN simulating your on-premises router
    Create 2 Site-to-Site VPN connections to TGW (simulating dual DX connections for resiliency)
    Create a DX Gateway resource (aws_dx_gateway) — even without a physical DX, you can create the DXGW and associate it with a TGW
    Create a TGW in a second region (Sydney) and set up TGW Peering — this simulates the cross-region DXGW pattern
    Configure BGP path preference using AS-path prepending on one VPN to simulate primary/backup DX paths
    Deploy ECMP across both VPN connections
    Test failover by disabling one VPN tunnel

EVE-NG Lab — BGP with DX Simulation:

Topology: Customer Router (CE) ↔ 2x ISP Routers (simulating DX) ↔ AWS Router (simulating VGW/TGW)

Lab Tasks:

    Configure eBGP between CE and both ISP routers
    Simulate primary/backup paths using Local Preference and AS-path prepending
    Implement MED to influence inbound traffic from AWS
    Test failover scenarios
    Configure BFD (Bidirectional Forwarding Detection) for fast failover — as used with DX

Estimated Time: 5–6 hours networking study + 4–5 hours Terraform + 3 hours EVE-NG
Phase 7: Private Connectivity to S3 & AWS PrivateLink (Week 8)

(This is your existing Phase 4 — kept exactly as you had it)

Estimated Time: 3–4 hours networking study + 4–5 hours Terraform
Phase 8: MPLS L2VPN & Segment Routing (Week 9)

Goal: Learn modern MPLS — L2VPN services and Segment Routing (the future of MPLS)

Networking Topics:

    L2VPN concepts: pseudowire, VPWS (Virtual Private Wire Service), VPLS (Virtual Private LAN Service)
    EVPN (Ethernet VPN) — the modern replacement for VPLS
    Segment Routing fundamentals — SRGB, Node-SID, Adjacency-SID
    Segment Routing vs LDP — why SR is replacing LDP
    SR-MPLS vs SRv6
    TI-LFA (Topology-Independent Loop-Free Alternate) for fast reroute with SR

Video Training:

    Orhan Ergun - MPLS Bootcamp — L2VPN and Segment Routing sections
    Orhan Ergun - CCIE SP v5 Course — L2VPN deep dive
    Cisco Live — Search for "BRKMPL-2900" (Segment Routing)
    "MPLS in the SDN Era" book — Segment Routing chapters

EVE-NG Lab — L2VPN & Segment Routing:

Lab Tasks (L2VPN):

    Configure a point-to-point VPWS (pseudowire) between PE1 and PE2
    Verify L2 connectivity — CE1 and CE2 should be in the same broadcast domain
    Configure VPLS for multi-point L2 connectivity (if IOS-XR images available)

Lab Tasks (Segment Routing):

    Replace LDP with Segment Routing on the MPLS core
    Configure Node-SIDs on each router
    Verify the SRGB and label allocation with show segment-routing mpls state
    Configure TI-LFA for sub-50ms failover
    Compare convergence time: LDP vs Segment Routing (shut a link and measure)

Estimated Time: 5–6 hours study + 5–6 hours EVE-NG lab
Phase 9: Centralized Inspection with GWLB & Network Firewall (Weeks 10–11)

(This is your existing Phase 5 — kept exactly as you had it, Parts A and B)

Estimated Time: 5–6 hours networking study per week + 4–5 hours Terraform per week
Phase 10: VPC Flow Logs & Monitoring (Week 12)

(This is your existing Phase 6 — kept exactly as you had it)

Estimated Time: 2–3 hours networking study + 3–4 hours Terraform
Phase 11: Network Automation with Python & Ansible (Week 13)

Goal: Build network automation skills for both Cisco and AWS

Networking Topics:

    Python for network automation: netmiko, napalm, paramiko, nornir
    Ansible for network automation: cisco.ios, cisco.iosxr, amazon.aws collections
    REST APIs for AWS networking (boto3)
    Infrastructure as Code comparison: Terraform vs Ansible vs Python
    YANG models and NETCONF/RESTCONF (modern network programmability)

Hands-On Labs:

Python Labs:

    Build a multi-vendor BGP neighbor health checker using napalm (works with EVE-NG routers)
    Create a Python script using boto3 that audits all TGW route tables and generates a report
    Build a script that compares Cisco BGP tables with AWS TGW route tables for a hybrid environment
    Use jinja2 + yaml to generate Cisco router configs and Terraform .tf files from the same data source

Ansible Labs:

    Create an Ansible playbook that configures BGP on all EVE-NG routers from a YAML inventory
    Create an Ansible playbook using amazon.aws collection to deploy VPCs and TGW attachments
    Build a combined playbook: configure Cisco routers AND deploy AWS infrastructure in one run

Estimated Time: 6–8 hours Python + 4–5 hours Ansible
Phase 12: Advanced Terraform Patterns (Week 14)

(This is your existing Phase 7 — kept exactly as you had it)

Estimated Time: 6–8 hours Terraform