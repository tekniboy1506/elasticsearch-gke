terraform {
  source = "tfr:///terraform-google-modules/kubernetes-engine/google//?version=33.1.0"
}

locals {
    common_vars = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))
}

inputs = {
  
  project_id = local.common_vars.inputs.project_id
  region = local.common_vars.inputs.region
  network = local.common_vars.inputs.network
  subnetwork = local.common_vars.inputs.subnetwork
  machine_type = "e2-medium"
  ip_range_pods = "10.0.0.0/16"
  ip_range_services = "10.1.0.0/20"
  disk_size_gb = 30
  name       = "elasticsearch-cluster"
  min_node_count     = 1
  initial_node_count = 1
  gce_pd_csi_driver = true
}