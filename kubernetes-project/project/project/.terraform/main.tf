locals {
  cluster_type = "kuber"
}

provider "google-beta" {
  version = "~> 3.76.0"
  region  = "us-central1"
  credentials = "../terraform-gke-keyfile.json"
}

provider "google" {
  version = "~> 3.76.0"
  region  = "us-central1"
  credentials = "../terraform-gke-keyfile.json"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                            = "./terraform-google-kubernetes-engine/modules/beta-public-cluster/"
  project_id                        = "principal-bird-321719"
  name                              = "${local.cluster_type}-cluster"
  region                            = "us-central1"
  zones                             = ["us-central1-c"]
  network                           = "default"
  subnetwork                        = "default"
  ip_range_pods                     = ""
  ip_range_services                 = ""
  create_service_account            = false
  service_account                   = "terraform-gke@principal-bird-321719.iam.gserviceaccount.com"
  http_load_balancing               = false
  horizontal_pod_autoscaling        = true
  disable_legacy_metadata_endpoints = false
  remove_default_node_pool          = true
  logging_service                   = "none"
  monitoring_service                = "none"

  node_pools = [
     {
      name                          = "managers"
      machine_type                  = "n1-standard-2"
      node_locations                = "us-central1-c"
      min_count                     = 2
      max_count                     = 3
      local_ssd_count               = 0
      disk_size_gb                  = 35
      disk_type                     = "pd-standard"
      image_type                    = "COS"
      auto_repair                   = true
      auto_upgrade                  = true
      service_account               = "terraform-gke@principal-bird-321719.iam.gserviceaccount.com"
      preemptible                   = false
      initial_node_count            = 2
      enable_integrity_monitoring   = false
         
    },
    {
      name                          = "workers"
      machine_type                  = "n1-standard-2"
      node_locations                = "us-central1-c"
      min_count                     = 2
      max_count                     = 3
      local_ssd_count               = 0
      disk_size_gb                  = 35
      disk_type                     = "pd-standard"
      image_type                    = "COS"
      auto_repair                   = true
      auto_upgrade                  = true
      service_account               = "terraform-gke@principal-bird-321719.iam.gserviceaccount.com"
      preemptible                   = false
      initial_node_count            = 2
      enable_integrity_monitoring   = false
        
    },
  ]
  
  node_pools_oauth_scopes = {
    all = []
   
  }

#   node_pools_metadata = {
#     all = []
#   }

  node_pools_labels = {
    
    managers = {
      manager = true
    }

    workers = {
      worker = true
    }
  }

  node_pools_taints = {
    
    managers = [
      {
        key    = "manager"
        value  = true
        effect = "NO_SCHEDULE"
      },
    ]
  } 

}