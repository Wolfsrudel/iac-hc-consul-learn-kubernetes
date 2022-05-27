
resource "kubernetes_secret" "consul_secrets" {
  metadata {
    name = "${local.cluster_id}-hcp"
  }

  data = {
    caCert              = var.consul_ca_file
    gossipEncryptionKey = var.gossip_encryption_key
    bootstrapToken      = var.boostrap_acl_token
  }

  type = "Opaque"
}

resource "helm_release" "consul" {
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"
  version    = var.chart_version
  chart      = "consul"

  values = [
    templatefile("${path.module}/template/consul.tpl", {
      datacenter       = var.datacenter
      consul_hosts     = jsonencode(var.consul_hosts)
      cluster_id       = local.cluster_id
      k8s_api_endpoint = var.k8s_api_endpoint
      consul_version   = substr(var.consul_version, 1, -1)
      api_gateway_version = var.api_gateway_version
    })
  ]

  # Helm installation relies on the Kuberenetes secret being
  # available.
  depends_on = [kubernetes_secret.consul_secrets]
}