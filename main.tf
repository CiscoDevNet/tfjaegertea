#Helm install of sample app on IKS
data "terraform_remote_state" "iksws" {
  backend = "remote"
  config = {
    organization = var.org
    workspaces = {
      name = var.ikswsname
    }
  }
}

data "terraform_remote_state" "global" {
  backend = "remote"
  config = {
    organization = var.org
    workspaces = {
      name = var.globalwsname
    }
  }
}

variable "org" {
  type = string
}
variable "ikswsname" {
  type = string
}
variable "globalwsname" {
  type = string
}

resource helm_release teaiksfrtfcb {
  name       = "teaiksapp"
  namespace = "default"
  chart = local.instrapp
  #chart = "https://prathjan.github.io/helm-chart/newapp-1.0.0.tgz"

  set {
    name  = "MESSAGE"
    value = "Hello IKS from TFCB!!"
  }
}

provider "helm" {
  kubernetes {
    host = local.kube_config.clusters[0].cluster.server
    client_certificate = base64decode(local.kube_config.users[0].user.client-certificate-data)
    client_key = base64decode(local.kube_config.users[0].user.client-key-data)
    cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)
  }
}

locals {
  kube_config = yamldecode(data.terraform_remote_state.iksws.outputs.kube_config)
  instrapp = data.terraform_remote_state.global.outputs.instrapp
}

