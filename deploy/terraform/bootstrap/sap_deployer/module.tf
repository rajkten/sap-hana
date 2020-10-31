/*
Description:

  Example to deploy deployer(s) using local backend.
*/
module "sap_deployer" {
  source         = "../../terraform-units/modules/sap_deployer/common_infrastructure"
  infrastructure = var.infrastructure
  deployers      = var.deployers
  options        = var.options
  ssh-timeout    = var.ssh-timeout
  sshkey         = var.sshkey
}

module "deployer" {
  depends_on = [module.sap_deployer]
  source         = "../../terraform-units/modules/sap_deployer/deployer"
  infrastructure = var.infrastructure
  deployers      = var.deployers
  options        = var.options
  ssh-timeout    = var.ssh-timeout
  sshkey         = var.sshkey
  kv_id = module.sap_deployer.deployer_kv_user_arm_id

}
