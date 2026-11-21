resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../Ansible/inventory.yml"
  content = templatefile("${path.module}/templates/inventory.yml.tftpl", {
    app_key_name            = var.app_key_name
    web_server_01_public_ip = module.application.web_server_01_public_ip
    web_server_02_public_ip = module.application.web_server_02_public_ip
    backend_01_private_ip   = module.application.backend_01_private_ip
    backend_02_private_ip   = module.application.backend_02_private_ip
  })
  file_permission = "0644"
}
