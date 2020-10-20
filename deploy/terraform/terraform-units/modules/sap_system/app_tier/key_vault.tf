// retrieve public key from sap landscape's Key vault
data "azurerm_key_vault_secret" "sid_pk" {
  count        = local.enable_auth_key ? 1 : 0
  name         = local.secret_sid_pk_name
  key_vault_id = local.kv_landscape_id
}

// Generate random password if password is set as authentication type and user doesn't specify a password
resource "random_password" "password" {
  count = (
    local.enable_auth_password
  && try(var.application.authentication.password, null) == null) ? 1 : 0
  length           = 16
  special          = true
  override_special = "_%@"
}

/*
 To force dependency between kv access policy and secrets. Expected behavior:
 https://github.com/terraform-providers/terraform-provider-azurerm/issues/4971
*/

// store the app logon username in KV
resource "azurerm_key_vault_secret" "app_auth_username" {
  depends_on   = [var.sid_kv_user_msi]
  count        = local.enable_auth_password ? 1 : 0
  name         = format("%s-app-auth-username", replace(local.prefix,"_","-"))
  value        = local.sid_auth_username
  key_vault_id = local.sid_kv_user.id
}

// store the app logon password in KV
resource "azurerm_key_vault_secret" "app_auth_password" {
  depends_on   = [var.sid_kv_user_msi]
  count        = local.enable_auth_password ? 1 : 0
  name         = format("%s-app-auth-password", replace(local.prefix,"_","-"))
  value        = local.sid_auth_password
  key_vault_id = local.sid_kv_user.id
}
