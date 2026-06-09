resource "random_password" "jwt_secret" {
  count   = var.deploy_kubernetes ? 1 : 0
  length  = 48
  special = true
}

resource "random_password" "agent_token_secret" {
  count   = var.deploy_kubernetes ? 1 : 0
  length  = 48
  special = true
}

data "http" "gateway_api_standard_crds" {
  count = var.deploy_kubernetes ? 1 : 0
  url   = var.gateway_api_crds_url
}

locals {
  gateway_api_crd_raw_documents = var.deploy_kubernetes ? [
    for document in split("\n---", data.http.gateway_api_standard_crds[0].response_body) :
    document
    if length(regexall("(?m)^apiVersion:", document)) > 0
  ] : []
  gateway_api_crd_decoded_documents = [
    for document in local.gateway_api_crd_raw_documents :
    {
      for key, value in yamldecode(document) :
      key => value
      if key != "status"
    }
  ]
  gateway_api_crd_documents = {
    for manifest in local.gateway_api_crd_decoded_documents :
    "${manifest.kind}-${manifest.metadata.name}" => manifest
  }

  platform_public_url       = var.domain_name != "" ? "https://${var.domain_name}" : "https://${module.frontdoor.endpoint_hostname}"
  platform_gateway_hostname = var.platform_gateway_hostname != "" ? var.platform_gateway_hostname : var.domain_name
  platform_frontend_image   = coalesce(var.frontend_image_repository, "${module.app_hosting.acr_login_server}/clustersage-frontend")
  platform_backend_image    = coalesce(var.backend_image_repository, "${module.app_hosting.acr_login_server}/clustersage-backend")
  platform_database_url     = var.create_database ? "postgresql+asyncpg://${var.postgres_admin_login}:${urlencode(var.postgres_admin_password)}@${module.database[0].fqdn}:5432/${module.database[0].database_name}?ssl=require" : ""
  platform_chart_values = {
    serviceAccount = {
      create = true
      name   = var.platform_service_account_name
      annotations = {
        "azure.workload.identity/client-id" = module.managed_identity.client_id
      }
    }
    podLabels = {
      "azure.workload.identity/use" = "true"
    }
    frontend = {
      replicaCount = var.frontend_replica_count
      image = {
        repository = local.platform_frontend_image
        tag        = var.frontend_image_tag
      }
      env = {
        NEXT_PUBLIC_API_URL = local.platform_public_url
      }
    }
    backend = {
      replicaCount = var.backend_replica_count
      image = {
        repository = local.platform_backend_image
        tag        = var.backend_image_tag
      }
      env = {
        APP_ENV                                    = var.environment
        PUBLIC_APP_URL                             = local.platform_public_url
        PUBLIC_API_URL                             = local.platform_public_url
        CORS_ALLOWED_ORIGINS                       = local.platform_public_url
        AZURE_CLIENT_ID                            = module.managed_identity.client_id
        AZURE_STORAGE_CONTAINER                    = module.storage.container_name
        AZURE_SERVICEBUS_FULLY_QUALIFIED_NAMESPACE = module.service_bus.fully_qualified_namespace
        CLUSTER_CONNECTED_QUEUE_NAME               = module.service_bus.queue_name
        AZURE_COMMUNICATION_EMAIL_ENDPOINT         = module.email.communication_service_endpoint
        EMAIL_SENDER_ADDRESS                       = module.email.sender_address
        APPLICATIONINSIGHTS_CONNECTION_STRING      = module.monitoring.application_insights_connection_string
      }
    }
    emailWorker = {
      enabled      = true
      replicaCount = var.email_worker_replica_count
    }
    ingress = {
      enabled = false
    }
    gateway = {
      enabled   = true
      className = "kgateway"
      namespace = var.kgateway_namespace
      name      = var.platform_gateway_name
      hostname  = local.platform_gateway_hostname
    }
    migrations = {
      enabled = true
    }
  }
}

resource "kubernetes_manifest" "gateway_api_crds" {
  for_each = local.gateway_api_crd_documents
  manifest = each.value

  field_manager {
    force_conflicts = true
  }
}

resource "time_sleep" "gateway_api_crds" {
  count           = var.deploy_kubernetes ? 1 : 0
  create_duration = "20s"
  depends_on      = [kubernetes_manifest.gateway_api_crds]
}

resource "helm_release" "kgateway_crds" {
  count            = var.deploy_kubernetes ? 1 : 0
  name             = "kgateway-crds"
  namespace        = var.kgateway_namespace
  create_namespace = true
  chart            = "oci://cr.kgateway.dev/kgateway-dev/charts/kgateway-crds"
  version          = var.kgateway_chart_version
  wait             = true
  timeout          = 600

  depends_on = [time_sleep.gateway_api_crds]
}

resource "time_sleep" "kgateway_crds" {
  count           = var.deploy_kubernetes ? 1 : 0
  create_duration = "20s"
  depends_on      = [helm_release.kgateway_crds]
}

resource "helm_release" "kgateway" {
  count     = var.deploy_kubernetes ? 1 : 0
  name      = "kgateway"
  namespace = var.kgateway_namespace
  chart     = "oci://cr.kgateway.dev/kgateway-dev/charts/kgateway"
  version   = var.kgateway_chart_version
  wait      = true
  timeout   = 600

  depends_on = [time_sleep.kgateway_crds]
}

resource "time_sleep" "kgateway_control_plane" {
  count           = var.deploy_kubernetes ? 1 : 0
  create_duration = "30s"
  depends_on      = [helm_release.kgateway]
}

resource "helm_release" "clustersage_platform" {
  count            = var.deploy_kubernetes ? 1 : 0
  name             = var.platform_release_name
  namespace        = var.platform_namespace
  create_namespace = true
  chart            = "${path.module}/../deploy/helm/clustersage-platform"
  values           = [yamlencode(local.platform_chart_values)]
  wait             = true
  timeout          = 900

  set_sensitive {
    name  = "backend.secrets.DATABASE_URL"
    value = local.platform_database_url
  }

  set_sensitive {
    name  = "backend.secrets.JWT_SECRET"
    value = random_password.jwt_secret[0].result
  }

  set_sensitive {
    name  = "backend.secrets.AGENT_TOKEN_SECRET"
    value = random_password.agent_token_secret[0].result
  }

  set_sensitive {
    name  = "backend.secrets.AZURE_STORAGE_CONNECTION_STRING"
    value = module.storage.primary_connection_string
  }

  set {
    name  = "backend.secrets.AZURE_SERVICEBUS_CONNECTION_STRING"
    value = ""
  }

  set {
    name  = "backend.secrets.AZURE_COMMUNICATION_EMAIL_CONNECTION_STRING"
    value = ""
  }

  depends_on = [
    time_sleep.kgateway_control_plane,
    azurerm_federated_identity_credential.clustersage_workloads,
    azurerm_role_assignment.servicebus_sender,
    azurerm_role_assignment.servicebus_receiver,
    azurerm_role_assignment.communication_email_owner,
    azurerm_role_assignment.storage_blob_contributor
  ]
}
