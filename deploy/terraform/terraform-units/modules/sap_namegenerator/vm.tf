locals {

  db_oscode       = upper(var.db_ostype) == "LINUX" ? "l" : "w"
  app_oscode      = upper(var.app_ostype) == "LINUX" ? "l" : "w"
  db_platformcode = substr(var.db_platform, 0, 3)

  anchor_server_names = [for idx in range(length(local.zones)) :
    format("%sanchor%02d%s%s", lower(var.sap_sid), idx, local.db_oscode, local.random_id_vm_verified)
  ]

  deployer_vm_names = [for idx in range(var.deployer_vm_count) :
    lower(format("%s%s%sdeploy%02d", local.env_verified, local.location_short, local.dep_vnet_verified, idx))
  ]

  anydb_computer_names = [for idx in range(var.db_server_count) :
    format("%sd%s%02dl%d%s", lower(var.sap_sid), lower(var.db_sid), idx, 0, local.random_id_vm_verified)
  ]

  anydb_computer_names_ha = [for idx in range(var.db_server_count) :
    format("%sd%s%02dl%d%s", lower(var.sap_sid), lower(var.db_sid), idx, 1, local.random_id_vm_verified)
  ]

  anydb_vm_names = [for idx in range(var.db_server_count) :
    local.zonal_deployment ? (
      format("%sd%s%sz%s%s%02dl%d%s", lower(var.sap_sid), lower(var.db_sid), local.separator, var.db_zones[idx % length(var.db_zones)], local.separator, idx, 0, local.random_id_vm_verified)) : (
      format("%sd%s%02dl%d%s", lower(var.sap_sid), lower(var.db_sid), idx, 0, local.random_id_vm_verified)
    )
  ]

  anydb_vm_names_ha = [for idx in range(var.db_server_count) :
    local.zonal_deployment ? (
      format("%sd%s%sz%s%s%02dl%d%s", lower(var.sap_sid), lower(var.db_sid), local.separator, var.db_zones[idx % length(var.db_zones)], local.separator, idx, 1, local.random_id_vm_verified)) : (
      format("%sd%s%02dl%d%s", lower(var.sap_sid), lower(var.db_sid), idx, 1, local.random_id_vm_verified)
    )
  ]

  app_computer_names = [for idx in range(var.app_server_count) :
    format("%sapp%02d%s%s", lower(var.sap_sid), idx, local.app_oscode, local.random_id_vm_verified)
  ]

  app_server_vm_names = [for idx in range(var.app_server_count) :
    local.zonal_deployment ? (
      format("%sapp%sz%s%s%02d%s%s", lower(var.sap_sid), local.separator, var.app_zones[idx % length(var.app_zones)], local.separator, idx, local.app_oscode, local.random_id_vm_verified)) : (
      format("%sapp%02d%s%s", lower(var.sap_sid), idx, local.app_oscode, local.random_id_vm_verified)
    )
  ]

  iscsi_server_names = [for idx in range(var.iscsi_server_count) :
    lower(format("%s%s%siscsi%02d", lower(local.env_verified), local.vnet_verified, local.location_short, idx))
  ]

  hana_computer_names = [for idx in range(var.db_server_count) :
    format("%sd%s%02dl%d%s", lower(var.sap_sid), lower(var.db_sid), idx, 0, local.random_id_vm_verified)
  ]

  hana_computer_names_ha = [for idx in range(var.db_server_count) :
    format("%sd%s%02dl%d%s", lower(var.sap_sid), lower(var.db_sid), idx, 1, local.random_id_vm_verified)
  ]

  hana_server_vm_names = [for idx in range(var.db_server_count) :
    local.zonal_deployment ? (
      format("%sd%s%sz%s%s%02dl%d%s", lower(var.sap_sid), lower(var.db_sid), local.separator, var.db_zones[idx % length(var.db_zones)], local.separator, idx, 0, local.random_id_vm_verified)) : (
      format("%sd%s%02dl%d%s", lower(var.sap_sid), lower(var.db_sid), idx, 0, local.random_id_vm_verified)
    )
  ]

  hana_server_vm_names_ha = [for idx in range(var.db_server_count) :
    local.zonal_deployment ? (
      format("%sd%s%sz%s%s%02dl%d%s", lower(var.sap_sid), lower(var.db_sid), local.separator, var.db_zones[idx % length(var.db_zones)], local.separator, idx, 1, local.random_id_vm_verified)) : (
      format("%sd%s%02dl%d%s", lower(var.sap_sid), lower(var.db_sid), idx, 1, local.random_id_vm_verified)
    )
  ]

  scs_computer_names = [for idx in range(var.scs_server_count) :
    format("%sscs%02d%s%s", lower(var.sap_sid), idx, local.app_oscode, local.random_id_vm_verified)
  ]

  scs_server_vm_names = [for idx in range(var.scs_server_count) :
    local.zonal_deployment ? (
      format("%sscs%sz%s%s%02d%s%s", lower(var.sap_sid), local.separator, var.scs_zones[idx % length(var.scs_zones)], local.separator, idx, local.app_oscode, local.random_id_vm_verified)) : (
      format("%sscs%02d%s%s", lower(var.sap_sid), idx, local.app_oscode, local.random_id_vm_verified)
    )
  ]

  web_computer_names = [for idx in range(var.web_server_count) :
    format("%sweb%02d%s%s", lower(var.sap_sid), idx, local.app_oscode, local.random_id_vm_verified)
  ]

  web_server_vm_names = [for idx in range(var.scs_server_count) :
    local.zonal_deployment ? (
      format("%sweb%sz%s%s%02d%s%s", lower(var.sap_sid), local.separator, var.web_zones[idx % length(var.web_zones)], local.separator, idx, local.app_oscode, local.random_id_vm_verified)) : (
      format("%sweb%02d%s%s", lower(var.sap_sid), idx, local.app_oscode, local.random_id_vm_verified)
    )
  ]

  observer_computer_names = [for idx in range(length(var.zones)) :
    format("%sobserver%02d%s%s", lower(var.sap_sid), idx, local.db_platformcode, local.random_id_vm_verified)
  ]

  observer_vm_names = [for idx in range(length(var.zones)) :
    local.zonal_deployment ? (
      format("%sobserver_z%s_%02d%s%s", lower(var.sap_sid), var.zones[idx % length(var.zones)], idx, local.db_platformcode, local.random_id_vm_verified)) : (
      format("%sobserver%02d%s%s", lower(var.sap_sid), idx, local.db_platformcode, local.random_id_vm_verified)
    )
  ]

}
