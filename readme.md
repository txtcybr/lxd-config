## LXD Terraform Provider Learning Notes 


### What I Learn while writing this lxd config to setup lab environments
1. Don't be too lazy to read the docs: [Documentation](https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs)
2. Watch this if you're confused: [Youtube](https://www.youtube.com/watch?v=ul_UxJOHiKM&t=916s)

## How to use

1\. Install terraform from this site:

[Terraform Install](https://developer.hashicorp.com/terraform/install)

2\. Make a directory for the config

```
mkdir lxd-vmname
cd lxd-vmname
```

3\. Copy/define your configurations in main.tf to lxd-vmname directory, choose the suitable config, single node or multi-node then Initiate the terraform:

```
nano main.tf
```

```main.tf 
#single-node Config
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

resource "lxd_instance" "myvm"{
  name   = "myvm"
  image  = "ubuntu:22.04"
  type   = "virtual-machine"
  ephemeral = false
  config = {
    "boot.autostart" = true
  }
  limits = {
    cpu    = 2 # limit CPU to 2 Cores
    memory = "4GiB"  # limit memory to 4 GB
  }
}

```

```main.tf
#multi-node config
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
```

```
terraform init
```

4\.  Check your config, then apply/launch your instance (vm/container)

```
terraform plan 
terraform apply
```


