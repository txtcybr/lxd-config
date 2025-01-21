terraform {
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
    }
  }
}

provider "lxd" {
  generate_client_certificates = true
  accept_remote_certificate    = true
}

variable "vm_names" {
  type    = list(string)
  default = ["vm1", "vm2", "vm3"]
}

resource "lxd_instance" "myvm" {
  for_each  = toset(var.vm_names)
  name      = each.value
  image     = "ubuntu-minimal:22.04"
  type      = "virtual-machine"
  ephemeral = false
  config = {
    "boot.autostart" = true
    "user.user-data" = <<-EOF
      #cloud-config
      users:
        - name: user
          passwd: passwd
          shell: /bin/bash
          sudo: ['ALL=(ALL) NOPASSWD:ALL']
          ssh_authorized_keys:
            - ssh-rsa <insert pubkey>
      ssh_pwauth: true
      EOF
  }
  limits = {
    cpu    = 2
    memory = "4GiB"  # Updated memory limit to 4 GB
  }
}
