# TOC <!-- omit from toc -->

1. Azure-MySQLandPostgreSQL-DNS
2. The issue
3. MySQL and PostgreSQL single and flexbile server private connectivity options
   1. Single server
   2. Flexbile server

# Azure-MySQLandPostgreSQL-DNS

Azure MySQL and PostgreSQL flexible server Azure Private DNS Zone integration for Azure Landing Zones (aka Enterprise Sclae Landing-zones).

# The issue

Users, Teams or the Service Principal used in CI/CD Pipelines are not allowed to 'link' their own created Azure private DNS zones to the Hub VNET. Not doing so would break the cetnral DNS handling which is mostly deployed in the Hub and is responsible for all DNS resolving. this will result in other teams (Landing-zones) not able to resolve the MySQL or PostgreSQL Flexible server hostnames to their private IP addresses.
  
If you've pre-deployed Azure private DNS Zones in your Hub (or other) subscription you have to grant the users, teams or the Service Principal used in CI/CD Pipelines permissions (e.g. Needs the Azure Private DNS zone contributor RBAC role). This means that every Team that deploys a MySQL or PostgreSQL Flexible server in a Landing-zone subscription is dependend on the Team how's responsible for Hub or Azure Private DNS zones to set the correct permissions. Not doing so would break the deployement of MySQL or PostgreSQL Flebixel servers as the DNS record cannot be registered.

Both of them bring us to the essence of the issue: MySQL and PostgreSQL Sinlge vs Flebixle servers handle private connectivity differently.

# MySQL and PostgreSQL single and flexbile server private connectivity options

## Single server

Azure MySQL and PostgreSQL Single server supports **Azure Private Endpoints** for private connectivity.
This can be configured using the common methods mentioned in [Private Link and DNS integration at scale][PrivateDNSatScale] article.

## Flexbile server

Azure MySQL and PostgreSQL Flexible server supports **Azure VNET Injection** for private connectivity.

 [PrivateDNSatScale]: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/private-link-and-dns-integration-at-scale
