data "template_file" "cloud_init_cloudwatch_agent" {
  template = file("${path.module}/templates/cloud_init.yaml")

  vars = {
    cloudwatch_agent_configuration = var.metrics_config == "standard" ? base64encode(data.template_file.cloudwatch_agent_configuration_standard.rendered) : base64encode(data.template_file.cloudwatch_agent_configuration_advanced.rendered)
  }
}

data "template_file" "cloudwatch_agent_configuration_advanced" {
  template = file("${path.module}/templates/cloudwatch_agent_configuration_advanced.json")

  vars = {
    aggregation_dimensions      = jsonencode(var.aggregation_dimensions)
    cpu_resources               = var.cpu_resources
    disk_resources              = jsonencode(var.disk_resources)
    metrics_collection_interval = var.metrics_collection_interval
    log_file_path               = var.log_file_path
    log_group_name              = var.log_group_name
    log_stream_name              = var.log_stream_name
  }
}

data "template_file" "cloudwatch_agent_configuration_standard" {
  template = file("${path.module}/templates/cloudwatch_agent_configuration_standard.json")

  vars = {
    aggregation_dimensions      = jsonencode(var.aggregation_dimensions)
    cpu_resources               = var.cpu_resources
    disk_resources              = jsonencode(var.disk_resources)
    metrics_collection_interval = var.metrics_collection_interval
    log_file_path               = var.log_file_path
    log_group_name              = var.log_group_name
    log_stream_name              = var.log_stream_name
  }
}

data "template_cloudinit_config" "cloud_init_merged" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "userdata_part_cloudwatch.cfg"
    content      = data.template_file.cloud_init_cloudwatch_agent.rendered
    content_type = "text/cloud-config"
  }

  part {
    filename     = "userdata_part_caller.cfg"
    content      = var.userdata_part_content
    content_type = var.userdata_part_content_type
    merge_type   = var.userdata_part_merge_type
  }
}
