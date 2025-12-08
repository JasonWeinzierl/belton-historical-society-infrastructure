resource "azurerm_linux_web_app" "bhs_web" {
  name                = var.app_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.bhs.id

  https_only = true

  site_config {
    always_on                         = false
    ftps_state                        = "Disabled"
    health_check_path                 = "/api/healthcheck/status"
    health_check_eviction_time_in_min = 10
    http2_enabled                     = true

    application_stack {
      dotnet_version = "10.0"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    DOTNET_ENVIRONMENT = title(var.environment),

    APPINSIGHTS_INSTRUMENTATIONKEY             = var.insights_key
    APPLICATIONINSIGHTS_CONNECTION_STRING      = var.insights_conn_str
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3" # https://learn.microsoft.com/en-us/azure/azure-monitor/app/codeless-app-service?tabs=aspnetcore#application-settings-definitions
  }

  connection_string {
    name  = "AppConfig"
    type  = "Custom"
    value = var.app_config_conn_str
  }

  lifecycle {
    ignore_changes = [
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }
}

resource "azurerm_role_assignment" "bhs_web_key_vault" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.bhs_web.identity[0].principal_id
}

resource "azurerm_role_assignment" "bhs_github_actions" {
  scope                = azurerm_linux_web_app.bhs_web.id
  role_definition_name = "Website Contributor"
  principal_id         = var.build_server_principal_id
}
