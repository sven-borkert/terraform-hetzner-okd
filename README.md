# terraform-hetzner-okd
Terraform configuration to set up Fedora CoreOS servers in Hetzner Cloud. (To hopefully be able to install OKD on them later) 

## Build coreos-installer
To build the coreos-installed, best pick a linux distribution coming with openssl-1.x, as the created binary dynamically links openssl and the Hetzer rescue system comes with openssl-1.x. 

1. Install the Rust package manager cargo
2. Build coreos-installer `$ cargo install coreos-installer`
3. If any required tools/libs are missing, install them and repeat 2. until successful.
4. Find the created binary in ~/.cargo/bin/coreos-installer and put it under bin/ in this project, or modify main.tf to take it from that path.

## Deploy to Hetzner cloud
1. Create a project in Hetzner cloud
2. In the security settings of the project, create an API token with read-write permissions. Remeber the token, but NEVER put it into a config file you might later check into Git agin.
3. Set an environment variable TF_VAR_hcloud_token to contain your token, so you don't have to always enter it when running Terrafom. (export TF_VAR_hcloud_token=xxx
4. Check and modify the serverlist variable in variables.tf to contain the servers you want to create.
5. Run `$ terraform init` to download the provider modules.
6. Run `$ terraform apply` to deploy the servers to Hetzner cloud.

