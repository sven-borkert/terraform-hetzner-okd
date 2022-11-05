
provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "key" {
  name = var.ssh_public_key_name
  public_key = file(var.ssh_public_key_file)
}

resource "hcloud_server" "server" {
  
  # Interate over serverlist
  for_each = { for server in var.serverlist: server.name => server }

  name = each.key
  server_type = each.value.server_type
  datacenter = each.value.datacenter

  labels = { "os" = "coreos" }
  
  image = "fedora-36" # Ignored but required
  rescue = "linux64" # Boot into rescue mode

  ssh_keys = [hcloud_ssh_key.key.id]

  # Connect as root to the rescue system
  connection {
    host = self.ipv4_address
    timeout = "5m"
    agent = true
    user = "root"
  }

  # Copy config.yaml onto the system and replace $ssh_public_key variable
  provisioner "file" {
    content = replace(file("config.yaml"), "$ssh_public_key", trimspace(file(var.ssh_public_key_file)))
    destination = "/root/config.yaml"
  }

  # Copy coreos-installer binary onto the system
  provisioner "file" {
    source = "bin/coreos-installer"
    destination = "/usr/local/bin/coreos-installer"
  }

  # Install Fedora CoreOS via coreos-installer and config.yaml
  provisioner "remote-exec" {
    inline = [
      "set -x",
      # Download Butane and make the binary executable
      "wget -O /usr/local/bin/butane 'https://github.com/coreos/butane/releases/download/v${var.tools_butane_version}/butane-x86_64-unknown-linux-gnu'",
      "chmod +x /usr/local/bin/butane",
      "chmod +x /usr/local/bin/coreos-installer",
      # Translate human readable Butane config into machine readable ignition config
      "butane --strict < config.yaml > config.ign",
      #"apt install openssl",      
      # Install Fedora CoreOS to /dev/sda
      "coreos-installer install /dev/sda -i /root/config.ign",
      # Exit rescue mode and boot into coreos
      "reboot"
    ]
  }

  # Configure CoreOS after installation
  provisioner "remote-exec" {
    connection {
      #host = hcloud_server.server[each.key].ipv4_address
      host = self.ipv4_address
      timeout = "1m"
      agent = true
      user = "core"
    }
    inline = [
      "sudo hostnamectl set-hostname ${self.name}"
      # Add additional commands if needed
    ]
  }
}
