resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../../../Ansible/inventory.yml"
  content = templatefile("${path.module}/templates/inventory.yml.tftpl", {
    app_key_name            = var.key_name
    web_server_01_public_ip = aws_instance.web_server_01.public_ip
    web_server_02_public_ip = aws_instance.web_server_02.public_ip
    backend_01_private_ip   = aws_instance.backend_01.private_ip
    backend_02_private_ip   = aws_instance.backend_02.private_ip
  })
  file_permission = "0644"
}
