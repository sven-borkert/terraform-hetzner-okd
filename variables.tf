
variable "hcloud_token" {
  # Use environment variable TF_VAR_hcloud_token= to not have to enter this every time.
  description = "Hetzner Cloud API Token"
  type = string  
}

variable "ssh_public_key_file" {
  description = "Local path to your public key"
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_public_key_name" {
  description = "Name of your public key to identify at Hetzner Cloud portal"
  type = string
  default = "Sven Borkert <sven@borkert.net>"
}

# Update version to the latest release of butane (formerly the Fedora CoreOS Config Transpiler, FCCT)
variable "tools_butane_version" {
  description = "See https://github.com/coreos/butane/releases for available versions"
  type = string
  default = "0.16.0"
}

variable "serverlist" {
  description = "List of servers to deploy."
  type        = list(any)

  default = [
    {
        name            = "demo1",
        server_type     = "cx11",
        datacenter      = "fsn1-dc14"
    }
  ]
}