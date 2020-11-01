variable "infrastructure_w_defaults" {
  description = "infrasturcture dict with default values"
}

variable "software_w_defaults" {
  description = "software dect with default values"
}

variable "nics-jumpboxes-linux" {
  description = "NICs of the Linux jumpboxes"
}

variable "nics-jumpboxes-windows" {
  description = "NICs of the Windows jumpboxes"
}

variable "public-ips-jumpboxes-linux" {
  description = "Public IPs of the Linux jumpboxes"
}

variable "public-ips-jumpboxes-windows" {
  description = "Public IPs of the Windows jumpboxes"
}

variable "jumpboxes-linux" {
  description = "linux jumpboxes with rti"
}

variable "nics-dbnodes-admin" {
  description = "Admin NICs of HANA database nodes"
}

variable "nics-dbnodes-db" {
  description = "NICs of HANA database nodes"
}

variable "nics-iscsi" {
  description = "NICs of ISCSI target servers"
}

variable "loadbalancers" {
  description = "List of LoadBalancers created for HANA Databases"
}

variable "hdb-sid" {
  description = "List of SIDs used when generating Load Balancers"
}

variable "hana-database-info" {
  description = "Updated hana database json"
}

variable "nics_scs" {
  description = "List of NICs for the SCS Application VMs"
}

variable "nics_app" {
  description = "List of NICs for the Application Instance VMs"
}

variable "nics_web" {
  description = "List of NICs for the Web dispatcher VMs"
}

# Any DB
variable "nics_anydb" {
  description = "List of NICs for the AnyDB VMs"
}

variable "nics_scs_admin" {
  description = "List of NICs for the SCS Application VMs"
}

variable "nics_app_admin" {
  description = "List of NICs for the Application Instance VMs"
}

variable "nics_web_admin" {
  description = "List of NICs for the Web dispatcher VMs"
}

// Any DB
variable "nics_anydb_admin" {
  description = "List of Admin NICs for the anyDB VMs"
}

variable "random_id" {
  description = "Random hex string"
}

variable "anydb-loadbalancers" {
  description = "List of LoadBalancers created for HANA Databases"
}

variable "any-database-info" {
  description = "Updated anydb database json"
}

locals {

  ips_iscsi                    = var.nics-iscsi[*].private_ip_address
  ips_jumpboxes_windows        = var.nics-jumpboxes-windows[*].private_ip_address
  ips_jumpboxes_linux          = var.nics-jumpboxes-linux[*].private_ip_address
  public-ips-jumpboxes-windows = var.public-ips-jumpboxes-windows[*].ip_address
  public-ips-jumpboxes-linux   = var.public-ips-jumpboxes-linux[*].ip_address
  ips_dbnodes_admin            = [for key, value in var.nics-dbnodes-admin : value.private_ip_address]
  ips_dbnodes_db               = [for key, value in var.nics-dbnodes-db : value.private_ip_address]
  databases = [
    var.hana-database-info
  ]
  hdb_vms = flatten([
    for database in local.databases : flatten([
      [
        for dbnode in database.dbnodes : {
          role           = dbnode.role,
          platform       = database.platform,
          authentication = database.authentication,
          name           = dbnode.computername
        }
        if try(database.platform, "NONE") == "HANA"
      ],
      [
        for dbnode in database.dbnodes : {
          role           = dbnode.role,
          platform       = database.platform,
          authentication = database.authentication,
          name           = dbnode.computername
        }
        if try(database.platform, "NONE") == "HANA" && database.high_availability
      ]
    ])
    if database != {}
  ])

  ips_primary_scs = length(var.nics_scs_admin) > 0 ? var.nics_scs_admin : var.nics_scs
  ips_primary_app = length(var.nics_app_admin) > 0 ? var.nics_app_admin : var.nics_app
  ips_primary_web = length(var.nics_web_admin) > 0 ? var.nics_web_admin : var.nics_web

  ips_scs = [for key, value in local.ips_primary_scs : value.private_ip_address]
  ips_app = [for key, value in local.ips_primary_app : value.private_ip_address]
  ips_web = [for key, value in local.ips_primary_web : value.private_ip_address]

  ips_primary_anydb = length(var.nics_anydb_admin) > 0 ? var.nics_anydb_admin : var.nics_anydb
  ips_anydbnodes    = [for key, value in local.ips_primary_anydb : value.private_ip_address]

  anydatabases = [
    var.any-database-info
  ]
  anydb_vms = flatten([
    for adatabase in local.anydatabases : flatten([
      [
        for dbnode in adatabase.dbnodes : {
          role           = dbnode.role,
          platform       = upper(adatabase.platform),
          authentication = adatabase.authentication,
          name           = dbnode.name
        }
        if contains(["ORACLE", "DB2", "SQLSERVER", "ASE"], upper(try(adatabase.platform, "NONE")))
      ],
      [
        for dbnode in adatabase.dbnodes : {
          role           = dbnode.role,
          platform       = upper(adatabase.platform),
          authentication = adatabase.authentication,
          name           = dbnode.name
        }
        if adatabase.high_availability && contains(["ORACLE", "DB2", "SQLSERVER", "ASE"], upper(try(adatabase.platform, "NONE")))
      ]
    ])
    if adatabase != {}
  ])
}
