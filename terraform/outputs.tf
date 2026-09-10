output "network_id" {
  value = module.vpc.network_id
}

output "subnet_id" {
  value = module.vpc.subnet_id
}

output "subnet_zone" {
  value = module.vpc.subnet_zone
}

output "instance_id" {
  value = module.compute.instance_id
}

output "instance_name" {
  value = module.compute.instance_name
}

output "external_ip" {
  value = module.compute.external_ip
}

output "internal_ip" {
  value = module.compute.internal_ip
}
