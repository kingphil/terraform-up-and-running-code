terraform {
  required_version = ">= 0.12, < 0.13"
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
    labels = {
      App = "nginx"
    }
  }

  spec {
    replicas = var.replica_size
    selector {
      match_labels = {
        App = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          App = "nginx"
        }
      }

      spec {
        container {
          image = "nginx:${var.image_version}"
          name  = "example"

          port {
            container_port = local.http_port
          }

          ## somewhat equivalent to AMI flavor
          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            # requests {
            #   cpu    = "250m"
            #   memory = "50Mi"
            # }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
  }
  spec {
    selector = {
      App = kubernetes_deployment.nginx.metadata[0].labels.App
    }
    port {
      port        = local.http_port
      target_port = local.http_port
      #node_port = 32001
    }

    type = "NodePort"
  }
}

## stolen from https://github.com/terraform-providers/terraform-provider-kubernetes/blob/master/_examples/ingress/main.tf
resource "kubernetes_ingress" "nginx" {
  metadata {
    name = "nginx"

    annotations = {
      ## pek note: see URL above; the example is wrong wrong wrong with its annotation
      #"ingress.kubernetes.io/rewrite-target" = "/"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ## pek: not sure what this does, and it doesn't seem to be needed
    # backend {
    #   service_name = "nginx"
    #   service_port = local.http_port
    # }

    rule {
      host = "works.pekware.net"

      http {
        path {
          path = "/path-example"

          backend {
            service_name = "nginx"
            service_port = local.http_port
          }
        }
      }
    }
  }
}

output "node_port" {
  value = kubernetes_service.nginx.spec[0].port[0].node_port
}

output "URL" {
  value = "${kubernetes_ingress.nginx.spec[0].rule[0].host}${kubernetes_ingress.nginx.spec[0].rule[0].http[0].path[0].path}"
}

locals {
  http_port = 80
}
