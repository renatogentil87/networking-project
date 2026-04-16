Phase 1: Transit Gateway Deep Dive (Week 1)

Networking Topics:

    TGW routing between VPCs in the same region vs. different regions (TGW Peering)
    TGW with ECMP for IPsec VPN connections exceeding 1.25 Gbps
    TGW route tables, associations, propagations, and blackhole routes
    TGW appliance mode for stateful inspection
    TGW Connect attachments and GRE tunnels

re:Invent Videos to Search:

    NET301 — AWS Transit Gateway reference architectures for many VPCs
    NET406 — Advanced VPC design and new capabilities
    NET320 — AWS Transit Gateway and Transit VPCs

AWS Documentation:

    Transit Gateway Guide - https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html
    TGW Route Tables - https://docs.aws.amazon.com/vpc/latest/tgw/tgw-route-tables.html
    TGW Peering - https://docs.aws.amazon.com/vpc/latest/tgw/tgw-peering.html
    AWS Networking Workshop - https://catalog.workshops.aws/networking/en-US

Hands-On Lab — Terraform:

Goal: Implement TGW route table segmentation with isolated and shared-services patterns.

Terraform Resources to Deploy:

    aws_ec2_transit_gateway — Main TGW with default route table association/propagation disabled
    aws_ec2_transit_gateway_route_table — Create 3 route tables: shared-rt, spoke-isolated-rt, spoke-full-mesh-rt
    aws_ec2_transit_gateway_vpc_attachment — Attach VPCs A, B, C, and Shared VPC
    aws_ec2_transit_gateway_route_table_association — Associate Spoke-C with spoke-isolated-rt, Spoke-A and Spoke-B with spoke-full-mesh-rt, Shared VPC with shared-rt
    aws_ec2_transit_gateway_route_table_propagation — Propagate Shared VPC routes to all spoke route tables; propagate Spoke-A and Spoke-B routes to each other's route table and to shared-rt; propagate Spoke-C routes only to shared-rt
    aws_ec2_transit_gateway_route — Add blackhole routes for Spoke-C in spoke-full-mesh-rt to prevent leakage
    aws_instance — Deploy EC2 instances in each VPC for testing

Terraform Concepts You'll Learn:

    for_each with maps to dynamically create route table associations
    depends_on for resource ordering
    Complex variable structures (maps of objects)
    Module composition for TGW resources

Acceptance Criteria:

    ✅ Spoke-A and Spoke-B can ping each other
    ✅ Spoke-A and Spoke-B can ping the Shared VPC
    ✅ Spoke-C can ping the Shared VPC
    ❌ Spoke-C cannot ping Spoke-A or Spoke-B
    ✅ Shared VPC can ping all spokes
    ✅ Verify with ping and traceroute from EC2 instances
    ✅ Run terraform plan with no errors and terraform apply successfully

Estimated Time: 5–6 hours networking study + 3–4 hours Terraform

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
Phase 1.5: Cloud WAN Fundamentals (Week 1.5)

Networking Topics:

    Cloud WAN core concepts: Global network, core network, core network policy
    Network segments vs. Transit Gateway route tables
    Attachment types: VPC, VPN, Direct Connect, Connect
    Core network edges and ASN management
    Policy-based routing and attachment policies
    Segment actions: sharing routes, creating static routes

re:Invent Videos to Search:

    NET301 — AWS Cloud WAN reference architectures
    NET406 — Advanced VPC design with Cloud WAN
    NET325 — Cloud WAN deep dive

AWS Documentation:

    Cloud WAN User Guide
    Cloud WAN Policy Document
    Cloud WAN FAQs

Hands-On Lab — Terraform:

Goal: Deploy a basic Cloud WAN with multiple segments and understand policy-based routing.

Terraform Resources to Deploy:

    aws_networkmanager_global_network — Create global network container
    aws_networkmanager_core_network — Create core network with ASN range
    aws_networkmanager_core_network_policy_attachment — Define core network policy with segments
    aws_vpc — Create 3 VPCs (Prod, Dev, Shared) across 2 regions
    aws_networkmanager_vpc_attachment — Attach VPCs to Cloud WAN
    aws_instance — EC2 instances for connectivity testing

Terraform Concepts You'll Learn:

    JSON policy documents in Terraform using jsonencode()
    Multi-region provider aliases
    Attachment policy rules using tags
    Segment actions for route sharing

Acceptance Criteria:

    ✅ Global network and core network created successfully
    ✅ Three segments created: Prod, Dev, Shared
    ✅ VPCs automatically associated to segments based on Name tags
    ✅ Prod and Dev VPCs can communicate with Shared VPC
    ✅ Prod and Dev VPCs cannot communicate with each other (isolated)
    ✅ Verify connectivity with ping between EC2 instances
    ✅ Review segment route tables in Network Manager console

Estimated Time: 4–5 hours networking study + 4–5 hours Terraform
ENHANCED: Phase 2: Migrate from Transit Gateway to Cloud WAN (Week 2)

Networking Topics:

    Cloud WAN vs. Transit Gateway comparison and decision criteria
    Migration strategies: phased approach with zero downtime
    TGW peering with Cloud WAN for hybrid migration
    Route table attachments for segmentation across TGW and Cloud WAN
    BGP ASN considerations during migration

re:Invent Videos to Search:

    NET301 — Cloud WAN and Transit Gateway interoperability
    NET410 — Migration patterns to Cloud WAN

AWS Documentation:

    Cloud WAN and TGW Migration Patterns
    TGW Peering with Cloud WAN

Hands-On Lab — Terraform:

Goal: Migrate the TGW architecture from Phase 1 to Cloud WAN using a phased approach.

Migration Phases:

Phase A: Deploy Cloud WAN alongside existing TGW

    Deploy Cloud WAN core network in both regions
    Create segments matching TGW route table structure
    Establish TGW peering with Cloud WAN using route table attachments

Phase B: Migrate one VPC to Cloud WAN

    Detach VPC C from TGW
    Create Cloud WAN VPC attachment for VPC C
    Verify connectivity through Cloud WAN
    Validate no traffic disruption to VPC A and B

Phase C: Complete migration

    Migrate remaining VPCs to Cloud WAN
    Remove TGW attachments
    Decommission TGW (optional)

Terraform Resources to Deploy:

    aws_networkmanager_core_network — Cloud WAN core network
    aws_ec2_transit_gateway_peering_attachment — TGW to Cloud WAN peering
    aws_networkmanager_transit_gateway_route_table_attachment — Route table attachment
    aws_networkmanager_vpc_attachment — Migrate VPCs to Cloud WAN
    Update route tables during migration

Terraform Concepts You'll Learn:

    Blue-green migration patterns in Terraform
    Using depends_on for migration sequencing
    Conditional resource creation with count or for_each
    State migration strategies

Acceptance Criteria:

    ✅ Cloud WAN deployed alongside existing TGW without disruption
    ✅ TGW peering established with Cloud WAN
    ✅ VPC C successfully migrated to Cloud WAN with no downtime
    ✅ All VPCs migrated to Cloud WAN
    ✅ Connectivity verified between all VPCs through Cloud WAN
    ✅ TGW can be safely decommissioned
    ✅ Migration completed with zero packet loss (verify with continuous ping)

Estimated Time: 6–7 hours networking study + 5–6 hours Terraform
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

Phase 2: Route 53 Resolver & Hybrid DNS (Week 2)

Networking Topics:

    Route 53 Resolver inbound and outbound endpoints
    Resolver rules and rule associations
    DNS forwarding for hybrid environments (on-premises ↔ AWS)
    DNS query logging
    Route 53 Resolver DNS Firewall

re:Invent Videos to Search:

    NET302 — Hybrid DNS architectures
    NET212 — DNS design using Amazon Route 53
    NET307 — How to build a multi-region, multi-VPC DNS architecture

AWS Documentation:

    Route 53 Resolver - https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver.html
    Resolver Rules - https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-rules-managing.html
    DNS Firewall - https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall.html
    Query Logging - https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-query-logs.html

Hands-On Lab — Terraform:

Goal: Deploy Route 53 Resolver in the Shared VPC and configure hybrid DNS forwarding with DNS Firewall.

Terraform Resources to Deploy:

    aws_route53_resolver_endpoint (inbound) — In Shared VPC private subnets, 2 IPs across AZs
    aws_route53_resolver_endpoint (outbound) — In Shared VPC private subnets, 2 IPs across AZs
    aws_route53_resolver_rule — Forwarding rule for onprem.example.com pointing to a simulated on-prem DNS server (EC2 instance running BIND/dnsmasq)
    aws_route53_resolver_rule_association — Associate the rule with all spoke VPCs
    aws_route53_resolver_query_log_config — Enable DNS query logging to CloudWatch
    aws_route53_resolver_query_log_config_association — Associate logging with each VPC
    aws_route53_resolver_firewall_domain_list — Create a block list of malicious domains
    aws_route53_resolver_firewall_rule_group — Create a DNS Firewall rule group
    aws_route53_resolver_firewall_rule — Block rule for the domain list
    aws_route53_resolver_firewall_rule_group_association — Associate with all VPCs
    aws_instance — DNS server EC2 instance with user_data to install BIND/dnsmasq
    aws_security_group — Allow DNS traffic (UDP/TCP 53) to resolver endpoints

Terraform Concepts You'll Learn:

    templatefile() function for user_data scripts
    depends_on for resource ordering
    Creating a dedicated DNS module (modules/dns)
    Outputting endpoint IPs for cross-module references
    for_each to associate rules and logging across multiple VPCs

Acceptance Criteria:

    ✅ DNS queries from spoke VPCs for onprem.example.com resolve correctly (forwarded to the BIND/dnsmasq instance)
    ✅ DNS queries from the simulated on-prem DNS server for AWS private hosted zone records resolve via the inbound endpoint
    ✅ DNS query logs appear in CloudWatch Logs
    ✅ DNS Firewall blocks queries to domains on the block list (verify with dig blocked-domain.com returning NXDOMAIN or SERVFAIL)
    ✅ Verify with dig and nslookup from EC2 instances in each VPC
    ✅ terraform plan and terraform apply complete successfully

Estimated Time: 4–5 hours networking study + 3–4 hours Terraform

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------


Phase 3: Direct Connect Infrastructure & Advanced Features (Week 3)

Networking Topics:

    DX location types: AWS Direct Connect locations, Partners, customer colocation
    MACsec encryption on Direct Connect (supported port speeds, key management)
    DX Gateway (DXGW) — connecting VPCs in different regions, allowed prefixes, association limits
    DX + TGW integration patterns
    DX resiliency models (single/dual location, maximum resiliency)
    Public VIF and its relation to AWS backbone
    Routing path influence and local preference with DX

re:Invent Videos to Search:

    NET403 — Deep dive on AWS Direct Connect
    NET410 — Advanced architectures with AWS Direct Connect
    NET317 — AWS Direct Connect: Deep dive
    NET204 — Networking best practices and tips with AWS Direct Connect

AWS Documentation:

    Direct Connect User Guide - https://docs.aws.amazon.com/directconnect/latest/UserGuide/Welcome.html
    DX Resiliency Recommendations - https://aws.amazon.com/directconnect/resiliency-recommendation/
    DX + TGW - https://docs.aws.amazon.com/directconnect/latest/UserGuide/direct-connect-transit-gateways.html
    MACsec - https://docs.aws.amazon.com/directconnect/latest/UserGuide/MACsec.html
    DXGW - https://docs.aws.amazon.com/directconnect/latest/UserGuide/direct-connect-gateways.html

Hands-On Lab — Terraform:

Goal: Simulate DX connectivity using Site-to-Site VPN with TGW, configure BGP routing, and build a DXGW-like architecture.

Terraform Resources to Deploy:

    aws_customer_gateway — Simulating an on-premises router with a specific BGP ASN
    aws_vpn_connection — Site-to-Site VPN attached to TGW (2 tunnels for HA)
    aws_vpn_connection (second) — Second VPN for ECMP demonstration
    aws_ec2_transit_gateway — Enable ECMP support on the TGW
    aws_ec2_transit_gateway_route_table — Dedicated route table for VPN attachments
    aws_ec2_transit_gateway_route_table_association — Associate VPN attachment with the VPN route table
    aws_ec2_transit_gateway_route_table_propagation — Propagate VPN routes to spoke route tables and vice versa
    aws_ec2_transit_gateway_route — Static routes for on-premises CIDRs as backup
    aws_ec2_transit_gateway_peering_attachment — TGW peering to a second region (simulate cross-region DXGW pattern)
    aws_ec2_transit_gateway_route — Static routes in each region's TGW route table pointing to the peering attachment

Terraform Concepts You'll Learn:

    Working with VPN tunnel configuration outputs (tunnel IPs, pre-shared keys)
    BGP ASN configuration as variables
    Route propagation from VPN into TGW route tables
    sensitive = true for tunnel pre-shared keys
    Multi-region provider configuration (provider "aws" { alias = "sydney" })
    aws_ec2_transit_gateway_peering_attachment for cross-region connectivity

Acceptance Criteria:

    ✅ VPN tunnels show status UP in the AWS console
    ✅ BGP routes from the "on-premises" network are propagated to TGW route tables
    ✅ Spoke VPCs can see routes to the simulated on-premises CIDR in their route tables
    ✅ ECMP is working — traffic is distributed across both VPN connections (verify with TGW route table showing both VPN attachments for the same prefix)
    ✅ TGW peering attachment is active between two regions
    ✅ Static routes in each region point to the peering attachment for cross-region CIDRs
    ✅ EC2 instances in region 1 can ping EC2 instances in region 2 via TGW peering
    ✅ terraform plan and terraform apply complete successfully in both regions

Estimated Time: 5–6 hours networking study + 4–5 hours Terraform

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

Phase 4: Private Connectivity to S3 & AWS PrivateLink (Week 4)

Networking Topics:

    S3 Gateway Endpoint vs. S3 Interface Endpoint (PrivateLink)
    When to use each (Gateway for same-region, Interface for cross-region/on-premises via DX)
    Routing implications of each approach
    PrivateLink concepts: Interface endpoints, endpoint services, NLB-backed services
    PrivateLink vs. VPC Peering vs. TGW — when to use each

re:Invent Videos to Search:

    NET301 — AWS Transit Gateway reference architectures for many VPCs (covers PrivateLink patterns)
    NET406 — Advanced VPC design and new capabilities
    NET323 — Simplify networking with AWS PrivateLink
    NET215 — Connectivity to AWS and hybrid AWS network architectures

AWS Documentation:

    PrivateLink for S3 - https://docs.aws.amazon.com/AmazonS3/latest/userguide/privatelink-interface-endpoints.html
    Gateway Endpoints for S3 - https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-s3.html
    AWS PrivateLink - https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html
    VPC Endpoint Services - https://docs.aws.amazon.com/vpc/latest/privatelink/create-endpoint-service.html

Hands-On Lab — Terraform:

Goal: Deploy both S3 endpoint types, create a PrivateLink service, and compare connectivity patterns.

Terraform Resources to Deploy:

    aws_vpc_endpoint (type = "Gateway") — S3 Gateway Endpoint in each spoke VPC
    aws_vpc_endpoint_route_table_association — Associate Gateway Endpoint with each VPC's private route tables
    aws_vpc_endpoint (type = "Interface") — S3 Interface Endpoint in the Shared VPC with private_dns_enabled = true
    aws_vpc_endpoint (type = "Interface") — SSM, SSM Messages, and EC2 Messages endpoints (for Session Manager access without NAT)
    aws_lb (type = "network") — NLB in the Shared VPC fronting a simple web application
    aws_lb_target_group — Target group for the NLB
    aws_lb_listener — NLB listener
    aws_instance — Simple web server behind the NLB
    aws_vpc_endpoint_service — Expose the NLB as a PrivateLink service
    aws_vpc_endpoint (type = "Interface") — In each spoke VPC, consume the PrivateLink service
    aws_security_group — Security groups for PrivateLink endpoints and NLB
    aws_route53_zone (private) — Private hosted zone for the PrivateLink service DNS
    aws_route53_record — Alias record pointing to the PrivateLink endpoint DNS

Terraform Concepts You'll Learn:

    Different VPC endpoint types and their Terraform configurations
    aws_vpc_endpoint_service for creating your own PrivateLink services
    Route table associations for Gateway Endpoints
    DNS private hosted zone integration with Interface Endpoints
    for_each to deploy endpoints across multiple VPCs
    aws_vpc_endpoint_connection_notification for monitoring

Acceptance Criteria:

    ✅ aws s3 ls works from EC2 instances in all VPCs via Gateway Endpoint (no internet traffic)
    ✅ S3 Interface Endpoint in Shared VPC resolves s3.ca-central-1.amazonaws.com to private IPs (verify with nslookup)
    ✅ PrivateLink service is accessible from spoke VPCs — curl to the PrivateLink endpoint returns the web server response
    ✅ VPC Flow Logs confirm no internet-bound traffic for S3 access (destination is the Gateway Endpoint prefix list)
    ✅ SSM Session Manager works on EC2 instances without NAT Gateway (via Interface Endpoints)
    ✅ terraform plan and terraform apply complete successfully

Estimated Time: 3–4 hours networking study + 4–5 hours Terraform

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------


Phase 5: Centralized Inspection with GWLB & Network Firewall (Weeks 5–6)

Networking Topics:

    Gateway Load Balancer (GWLB) architecture and Geneve protocol encapsulation
    GWLB endpoints and how traffic flows through them
    Centralized inspection VPC pattern with TGW (appliance mode)
    AWS Network Firewall — stateless vs. stateful rule groups, rule evaluation order
    Deployment models (distributed, centralized, combined)
    AWS Network Firewall vs. 3rd party appliances (Palo Alto, Checkpoint) with GWLB

re:Invent Videos to Search:

    NET325 — Gateway Load Balancer deep dive
    NET409 — Advanced traffic management with AWS Network Firewall
    NET312 — Centralized network traffic inspection on AWS
    FWM302 — Firewalls on AWS: Which one and where?
    NET341 — Scaling network traffic inspection using AWS Gateway Load Balancer

AWS Documentation:

    Gateway Load Balancer - https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/introduction.html
    Centralized Inspection with GWLB Blog - https://aws.amazon.com/blogs/networking-and-content-delivery/centralized-inspection-architecture-with-aws-gateway-load-balancer-and-aws-transit-gateway/
    AWS Network Firewall - https://docs.aws.amazon.com/network-firewall/latest/developerguide/what-is-aws-network-firewall.html
    Network Firewall Best Practices - https://docs.aws.amazon.com/network-firewall/latest/developerguide/what-is-aws-network-firewall.html
    TGW Appliance Mode - https://docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html#TGW_Scenarios

Hands-On Lab Part A — AWS Network Firewall (Week 5):

Goal: Deploy AWS Network Firewall in the Shared VPC for centralized east-west inspection.

Terraform Resources to Deploy:

    aws_subnet — Dedicated firewall subnets in the Shared VPC (one per AZ, separate from private subnets)
    aws_route_table — Dedicated route tables for firewall subnets
    aws_networkfirewall_rule_group (stateless) — Drop invalid packets, allow established connections
    aws_networkfirewall_rule_group (stateful) — Block specific domains, allow ICMP for testing, block SSH from Spoke-C to Spoke-A
    aws_networkfirewall_firewall_policy — Reference both rule groups, set default actions
    aws_networkfirewall_firewall — Deploy in the firewall subnets
    aws_networkfirewall_logging_configuration — Send logs to CloudWatch and S3
    aws_cloudwatch_log_group — For firewall alert and flow logs
    Update aws_ec2_transit_gateway_vpc_attachment — Enable appliance mode on the Shared VPC attachment
    Update aws_route_table — Modify Shared VPC route tables to route spoke-bound traffic through the firewall endpoints
    aws_route — In firewall subnet route tables, route return traffic back to TGW

Terraform Concepts You'll Learn:

    Complex nested resource configurations (rule groups within policies)
    dynamic blocks for generating firewall rules from variables
    Subnet design patterns for firewall endpoints (3-tier: TGW subnet, firewall subnet, private subnet)
    Advanced routing with TGW appliance mode
    aws_networkfirewall_firewall sync states output for endpoint IDs

Acceptance Criteria (Part A):

    ✅ Traffic between spokes passes through the Network Firewall (verify with firewall flow logs)
    ✅ Stateful rule blocks SSH from Spoke-C to Spoke-A (verify ssh fails, ping succeeds)
    ✅ Stateless rule drops invalid packets
    ✅ Firewall logs appear in both CloudWatch and S3
    ✅ TGW appliance mode is enabled on the Shared VPC attachment
    ✅ All existing connectivity (spoke ↔ shared) still works
    ✅ terraform plan and terraform apply complete successfully

Hands-On Lab Part B — GWLB (Week 6):

Goal: Deploy a GWLB with a dummy appliance to understand Geneve encapsulation and traffic flow.

Terraform Resources to Deploy:

    aws_lb (type = "gateway") — Gateway Load Balancer in the inspection VPC
    aws_lb_target_group — Target group with Geneve protocol (port 6081)
    aws_lb_listener — GWLB listener
    aws_lb_target_group_attachment — Register the dummy appliance
    aws_instance — Dummy appliance EC2 with IP forwarding enabled via user_data (sysctl -w net.ipv4.ip_forward=1) and a simple Geneve decap/encap script
    aws_vpc_endpoint_service — GWLB endpoint service (with gateway_load_balancer_arns)
    aws_vpc_endpoint (type = "GatewayLoadBalancer") — GWLB endpoints in spoke VPCs
    aws_route_table — Update spoke ingress route tables to send traffic through GWLB endpoints
    aws_security_group — Allow Geneve traffic (UDP 6081) and health check traffic

Terraform Concepts You'll Learn:

    GWLB-specific Terraform configurations
    Endpoint service with GWLB integration (gateway_load_balancer_arns vs. network_load_balancer_arns)
    user_data for enabling IP forwarding on the appliance instance
    Cross-VPC endpoint deployment patterns
    acceptance_required on endpoint services

Acceptance Criteria (Part B):

    ✅ GWLB health checks pass on the dummy appliance (target group shows healthy)
    ✅ Traffic from spoke VPCs is routed through the GWLB endpoint (verify with VPC Flow Logs on the appliance ENI)
    ✅ The dummy appliance receives Geneve-encapsulated packets (verify with tcpdump -i eth0 port 6081)
    ✅ End-to-end connectivity works through the GWLB (ping from spoke to shared VPC traverses the appliance)
    ✅ terraform plan and terraform apply complete successfully

Estimated Time: 5–6 hours networking study per week + 4–5 hours Terraform per week


------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

Phase 6: VPC Flow Logs & Monitoring (Week 7)

Networking Topics:

    VPC Flow Log record format and fields (v2 through v5)
    Flow Log destinations (CloudWatch Logs, S3, Kinesis Data Firehose)
    Flow Log filtering (accept, reject, all)
    Custom log formats and additional fields (vpc-id, subnet-id, pkt-srcaddr, pkt-dstaddr, flow-direction)
    Analyzing flow logs for troubleshooting connectivity issues
    Transit Gateway Flow Logs

re:Invent Videos to Search:

    NET205 — Monitoring and troubleshooting network traffic
    SEC318 — Threat detection and response using AWS security services
    NET210 — AWS networking best practices in production
    COP344 — Observability best practices at Amazon

AWS Documentation:

    VPC Flow Logs - https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html
    Flow Log Record Examples - https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-records-examples.html
    TGW Flow Logs - https://docs.aws.amazon.com/vpc/latest/tgw/tgw-flow-logs.html
    CloudWatch Logs Insights - https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html

Hands-On Lab — Terraform:

Goal: Enable comprehensive monitoring across all VPCs and TGW, and build a troubleshooting workflow.

Terraform Resources to Deploy:

    aws_flow_log — VPC Flow Logs on all VPCs (CloudWatch destination) with custom log format including flow-direction, pkt-srcaddr, pkt-dstaddr, tcp-flags
    aws_flow_log — VPC Flow Logs on all VPCs (S3 destination) for long-term storage
    aws_flow_log — TGW Flow Logs for transit gateway traffic visibility
    aws_iam_role + aws_iam_policy — IAM roles for Flow Logs to write to CloudWatch
    aws_cloudwatch_log_group — Log groups with 30-day retention for each VPC
    aws_s3_bucket — Centralized S3 bucket for flow log storage
    aws_s3_bucket_lifecycle_configuration — Transition to Glacier after 90 days, expire after 365 days
    aws_s3_bucket_policy — Allow Flow Logs service to write to the bucket
    aws_cloudwatch_query_definition — Pre-built CloudWatch Insights queries for common troubleshooting scenarios (top talkers, rejected traffic, cross-AZ traffic)
    aws_sns_topic + aws_cloudwatch_metric_alarm — Alert when rejected traffic exceeds a threshold

Terraform Concepts You'll Learn:

    IAM assume role trust policies in Terraform
    S3 bucket lifecycle configurations
    for_each to deploy flow logs across all VPCs from a single resource block
    CloudWatch Log Group retention settings
    aws_cloudwatch_query_definition for reusable Insights queries
    SNS + CloudWatch Alarms integration

Acceptance Criteria:

    ✅ Flow logs are captured for all VPCs and the TGW
    ✅ Logs appear in both CloudWatch and S3
    ✅ S3 lifecycle rules are configured (verify with aws s3api get-bucket-lifecycle-configuration)
    ✅ CloudWatch Insights queries return results — run the pre-built queries to identify:
        Top 10 source/destination pairs by traffic volume
        All rejected traffic in the last hour
        Cross-AZ traffic patterns
    ✅ TGW Flow Logs show traffic traversing the transit gateway
    ✅ SNS alarm triggers when you intentionally generate rejected traffic (e.g., try to SSH to a port blocked by a security group)
    ✅ Can trace a packet's path from source VPC → TGW → destination VPC using flow logs from all three points
    ✅ terraform plan and terraform apply complete successfully

Estimated Time: 2–3 hours networking study + 3–4 hours Terraform

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
Phase 7: Advanced Terraform Patterns (Week 8)

Terraform Topics:

    Module composition and reusable module design
    Remote state with S3 backend and DynamoDB locking
    Terraform workspaces vs. directory-based environments
    Variable validation and custom validation rules
    terraform import for existing resources
    moved blocks for refactoring without destroying resources
    CI/CD pipeline integration

re:Invent Videos to Search:

    DOP302 — Infrastructure as code best practices
    DOP310 — Terraform on AWS best practices
    DOP201 — Automating infrastructure management

AWS Documentation:

    Terraform AWS Provider - https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    S3 Backend Configuration - https://developer.hashicorp.com/terraform/language/backend/s3
    Terraform Best Practices - https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices

Hands-On Lab — Terraform:

Goal: Refactor your entire project into a production-ready structure with remote state, validation, and CI/CD.

Tasks:

    Reorganize into modules:
        modules/networking — VPCs, subnets, route tables, NAT GWs
        modules/transit-gateway — TGW, route tables, attachments, propagations
        modules/compute — EC2 instances, security groups
        modules/dns — Route 53 Resolver endpoints, rules, DNS Firewall
        modules/security — Network Firewall, NACLs, Security Groups
        modules/monitoring — Flow Logs, CloudWatch, SNS alarms
        modules/endpoints — VPC Endpoints (Gateway, Interface, GWLB)

    Implement remote state:
        aws_s3_bucket for state storage with versioning enabled
        aws_dynamodb_table for state locking
        Configure backend "s3" in your Terraform configuration
        Test state locking by running terraform plan from two terminals simultaneously

    Create environment-specific variable files:
        environments/dev.tfvars — Smaller instance types, single NAT GW, fewer VPCs
        environments/prod.tfvars — Production instance types, HA NAT GWs, full VPC set

    Add variable validation:
        CIDR block format validation using can(cidrhost(var.vpc_cidr, 0))
        Instance type allowed values
        VPC name length and character constraints
        Ensure private subnet CIDRs fall within VPC CIDR

    Practice terraform import and moved blocks:
        Manually create a security group in the console, then terraform import it
        Refactor a resource name using a moved block (e.g., rename aws_vpc.main to aws_vpc.this) without destroying it

    Implement code quality:
        terraform fmt -check — Formatting validation
        terraform validate — Configuration validation
        Install and run tflint for AWS-specific linting
        Create a simple shell script or Makefile that runs all three checks

Acceptance Criteria:

    ✅ All modules are self-contained with their own variables.tf, outputs.tf, and main.tf
    ✅ Remote state is stored in S3 with DynamoDB locking (verify lock by running concurrent plans)
    ✅ terraform plan -var-file=environments/dev.tfvars and terraform plan -var-file=environments/prod.tfvars both succeed with different configurations
    ✅ Variable validation rejects invalid CIDR blocks (e.g., terraform plan with vpc_cidr = "not-a-cidr" fails with a clear error)
    ✅ terraform import successfully imports the manually created security group
    ✅ moved block renames a resource without triggering destroy/create
    ✅ terraform fmt -check, terraform validate, and tflint all pass
    ✅ Full terraform apply deploys the entire infrastructure from scratch successfully

Estimated Time: 6–8 hours Terraform

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
