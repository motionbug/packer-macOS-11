source "vmware-iso" "macOS_11" {
  iso_url = "install_bits/macOS_11.iso"
  iso_checksum = "sha1:328b55e4ad3e7aeab8dec7dbd0b077a1b14c2168"
  ssh_username = "packer"
  ssh_password = "packer"
  shutdown_command = "shutdown -h now"
  guest_os_type = "darwin20-64"
  cdrom_adapter_type = "sata"
  disk_size = "100000"
  disk_adapter_type = "nvme"
  http_directory = "http"
  network_adapter_type = "e1000e"
  disk_type_id = "0"
  boot_wait = "140s"
  usb = "true"
  version = "18"
  vmx_data = {
    "smc.present" = "TRUE",
    "smbios.restrictSerialCharset" = "TRUE",
    "board-id.reflectHost" = "TRUE",
    "ich7m.present" = "TRUE"
  }
  boot_command = [
    "<enter>",
"<wait10s>",
"<leftSuperon><f5><leftSuperoff>",
"<wait3>",
"<leftCtrlon><f2><leftCtrloff>",
 "u",
 "<down><down><down>",
 "<enter>",
 "<leftSuperon><f5><leftSuperoff>",
 "<wait3>",
"curl -o ~/bootstrap.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/bootstrap.sh<enter>",
"chmod +x ~/bootstrap.sh",
"~/bootstrap.sh
 ]
  cpus = "4"
  cores = "4"
  memory = "16384"
}

build {
  sources = ["sources.vmware-iso.macOS_11"]
}

