locals {
  networkfirewall-tags = {
    Managedby = "Terraform"
    Project   = "Networking Project"
  }
}


resource "aws_networkfirewall_rule_group" "block_icmp" {
  capacity = 100
  name     = "stateless-egress-rules"
  type     = "STATELESS"

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        # Rule 1: Drop ICMP to 8.8.8.8 from VPC A
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [1]
              source {
                address_definition = "172.16.0.0/16"
              }
              destination {
                address_definition = "8.8.8.8/32"
              }
            }
          }
        }

        # Rule 2: Drop ICMP to 8.8.8.8 from VPC B
        stateless_rule {
          priority = 2
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [1]
              source {
                address_definition = "172.18.0.0/16"
              }
              destination {
                address_definition = "8.8.8.8/32"
              }
            }
          }
        }

        # Rule 3: Drop ICMP to 8.8.8.8 from VPC C
        stateless_rule {
          priority = 3
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [1]
              source {
                address_definition = "172.20.0.0/16"
              }
              destination {
                address_definition = "8.8.8.8/32"
              }
            }
          }
        }

        # Rule 4: Pass all other traffic
        stateless_rule {
          priority = 100
          rule_definition {
            actions = ["aws:forward_to_sfe"]
            match_attributes {
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
}


resource "aws_networkfirewall_firewall_policy" "egress_policy" {
  name = "centralized-egress-policy"
  firewall_policy {
    stateless_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_icmp.arn
      priority     = 1
    }
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  }
}


resource "aws_networkfirewall_firewall" "centralized_egress" {
  name                = "centralized-egress-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.egress_policy.arn
  vpc_id              = aws_vpc.firewall-vpc.id

  subnet_mapping {
    subnet_id = aws_subnet.firewall-private-subnet.id
  }

  tags = merge(local.networkfirewall-tags, {
    Name = "centralized-egress-firewall"
  })
}

resource "aws_cloudwatch_log_group" "firewall_alert_logs" {
  name              = "/aws/networkfirewall/alert"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "firewall_flow_logs" {
  name              = "/aws/networkfirewall/flow"
  retention_in_days = 7
}

resource "aws_networkfirewall_logging_configuration" "firewall_logs" {
  firewall_arn = aws_networkfirewall_firewall.centralized_egress.arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_alert_logs.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }

    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_flow_logs.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}
