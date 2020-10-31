// Comment out code with users.object_id for the time being.
/*
resource "azurerm_key_vault_access_policy" "kv_user_portal" {
  count        = local.enable_deployers ? length(local.deployer_users_id_list) : 0
  key_vault_id = azurerm_key_vault.kv_user[0].id

  tenant_id = data.azurerm_client_config.deployer.tenant_id
  object_id = local.deployer_users_id_list[count.index]

  secret_permissions = [
    "delete",
    "get",
    "list",
    "set",
  ]
}
*/

// Using TF tls to generate SSH key pair and store in user KV
resource "tls_private_key" "deployer" {
  count = (
    local.enable_deployers
    && local.enable_key
    && (try(file(var.sshkey.path_to_public_key), "") == "" ? true : false)
  ) ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

/*
 To force dependency between kv access policy and secrets. Expected behavior:
 https://github.com/terraform-providers/terraform-provider-azurerm/issues/4971
*/

resource "azurerm_key_vault_secret" "ppk" {
  count        = (local.enable_deployers && local.enable_key) ? 1 : 0
  name         = format("%s-sshkey", local.prefix)
  value        = local.private_key
  key_vault_id = local.kv_id
}

resource "azurerm_key_vault_secret" "pk" {
  count        = (local.enable_deployers && local.enable_key) ? 1 : 0
  name         = format("%s-sshkey-pub", local.prefix)
  value        = local.public_key
  key_vault_id = local.kv_id
}

// Generate random password if password is set as authentication type, and save in KV
resource "random_password" "deployer" {
  count = (
    local.enable_deployers
    && local.enable_password
    && local.input_pwd == null ? true : false
  ) ? 1 : 0
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "pwd" {
  count        = (local.enable_deployers && local.enable_password) ? 1 : 0
  name         = format("%s-password", local.prefix)
  value        = local.password
  key_vault_id = local.kv_id
}
