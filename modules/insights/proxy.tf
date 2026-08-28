locals {
  ingestion_endpoint = trimsuffix(regex("IngestionEndpoint=([^;]+)", azurerm_application_insights.bhs.connection_string)[0], "/")
}

resource "azurerm_api_management" "bhs" {
  name                = "bhs-${var.environment}-web-apim"
  resource_group_name = var.resource_group_name
  location            = var.location
  publisher_name      = "Belton Historical Society"
  publisher_email     = var.publisher_email
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_api" "insights_proxy" {
  name                  = "ai-proxy"
  resource_group_name   = var.resource_group_name
  api_management_name   = azurerm_api_management.bhs.name
  revision              = "1"
  display_name          = "Application Insights ingestion proxy"
  path                  = ""
  protocols             = ["https"]
  service_url           = local.ingestion_endpoint
  subscription_required = false
}

resource "azurerm_api_management_api_operation" "track" {
  operation_id        = "track"
  api_name            = azurerm_api_management_api.insights_proxy.name
  api_management_name = azurerm_api_management.bhs.name
  resource_group_name = var.resource_group_name
  display_name        = "Track telemetry"
  method              = "POST"
  url_template        = "/v2/track"
}

resource "azurerm_api_management_api_policy" "insights_proxy" {
  api_name            = azurerm_api_management_api.insights_proxy.name
  api_management_name = azurerm_api_management.bhs.name
  resource_group_name = var.resource_group_name

  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <cors allow-credentials="false">
      <allowed-origins>
    ${join("\n", [for origin in var.client_origins : format("        <origin>%s</origin>", origin)])}
      </allowed-origins>
      <allowed-methods>
        <method>POST</method>
      </allowed-methods>
      <allowed-headers>
        <header>*</header>
      </allowed-headers>
    </cors>
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
}
