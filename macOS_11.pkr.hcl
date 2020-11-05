variable "iso_file_checksum" {
  type    = string
  default = "file:install_bits/macOS_1101_installer.shasum"
}

variable "iso_filename" {
  type    = string
  default = "install_bits/macOS_1101_installer.iso"
}

variable "user_password" {
  type    = string
  default = "packer"
}

variable "user_username" {
  type    = string
  default = "packer"
}

# Full build 
build {
  name    = "full"
  sources = ["sources.vmware-iso.macOS_11"]

  provisioner "shell" {
    expect_disconnect = true
    pause_before      = "2m" # needed for the first provisioner to let the OS finish booting
    script            = "scripts/os_settings.sh"
  }

  provisioner "file" {
    sources     = ["install_bits/Xcode_12.2_Release_Candidate.xip", "install_bits/Command_Line_Tools_for_Xcode_12.2_Release_Candidate.dmg", "/Applications/VMware Fusion.app/Contents/Library/isoimages/darwin.iso"]
    destination = "~/"
  }
  provisioner "shell" {
    expect_disconnect = true
    scripts = [
      "scripts/vmw_tools.sh",
      "scripts/xcode.sh"
#      "scripts/softwareupdate.sh"
    ]
  }

}

source "vmware-iso" "macOS_11" {
  display_name         = "macOS 11"
  vm_name              = "macOS_11"
  vmdk_name            = "macOS_11"
  iso_url              = "${var.iso_filename}"
  iso_checksum         = "${var.iso_file_checksum}"
  output_directory     = "output/{{build_name}}"
  ssh_username         = "${var.user_username}"
  ssh_password         = "${var.user_password}"
  shutdown_command     = "sudo shutdown -h now"
  guest_os_type        = "darwin20-64"
  cdrom_adapter_type   = "sata"
  disk_size            = "100000"
  disk_adapter_type    = "nvme"
  http_directory       = "http"
  network_adapter_type = "e1000e"
  disk_type_id         = "0"
  boot_wait            = "180s"
  ssh_timeout          = "12h"
  usb                  = "true"
  version              = "18"
  vmx_data = {
    "smc.present"                  = "TRUE",
    "smbios.restrictSerialCharset" = "TRUE",
    "board-id.reflectHost"         = "TRUE",
    "ich7m.present"                = "TRUE"
  }
  boot_key_interval      = "20ms"
  boot_keygroup_interval = "2s"
  boot_command = [
    "<enter><wait10s>",
    "<leftSuperon><f5><leftSuperoff>",
    "<leftCtrlon><f2><leftCtrloff>",
    "u<down><down><down>",
    "<enter>",
    "<leftSuperon><f5><leftSuperoff><wait10>",
    "curl -o /var/root/packer.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/packer.pkg<enter>",
    "curl -o /var/root/setupsshlogin.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/setupsshlogin.pkg<enter>",
    "curl -o /var/root/bootstrap.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/bootstrap.sh<enter>",
    "chmod +x /var/root/bootstrap.sh<enter>",
    "/var/root/bootstrap.sh<enter>"
  ]
  cpus   = "6"
  cores  = "6"
  memory = "24576"
}

# Base build
build {
  name    = "base"
  sources = ["sources.vmware-iso.macOS_11_base"]

  provisioner "shell" {
    expect_disconnect = true
    pause_before      = "2m" # needed for the first provisioner to let the OS finish booting
    script            = "scripts/os_settings.sh"
  }

  provisioner "file" {
    source      = "/Applications/VMware Fusion.app/Contents/Library/isoimages/darwin.iso"
    destination = "~/darwin.iso"
  }

  provisioner "shell" {
    expect_disconnect = true
    scripts = [
      "scripts/vmw_tools.sh"
    ]
  }
}

source "vmware-iso" "macOS_11_base" {
  display_name         = "macOS 11 base"
  vm_name              = "macOS_11_base"
  vmdk_name            = "macOS_11_base"
  iso_url              = "${var.iso_filename}"
  iso_checksum         = "${var.iso_file_checksum}"
  output_directory     = "output/{{build_name}}"
  ssh_username         = "${var.user_username}"
  ssh_password         = "${var.user_password}"
  shutdown_command     = "sudo shutdown -h now"
  guest_os_type        = "darwin20-64"
  cdrom_adapter_type   = "sata"
  disk_size            = "100000"
  disk_adapter_type    = "nvme"
  http_directory       = "http"
  network_adapter_type = "e1000e"
  disk_type_id         = "0"
  boot_wait            = "180s"
  ssh_timeout          = "12h"
  usb                  = "true"
  version              = "18"
  vmx_data = {
    "smc.present"                  = "TRUE",
    "smbios.restrictSerialCharset" = "TRUE",
    "board-id.reflectHost"         = "TRUE",
    "ich7m.present"                = "TRUE"
  }
  boot_key_interval      = "20ms"
  boot_keygroup_interval = "2s"
  boot_command = [
    "<enter><wait10s>",
    "<leftSuperon><f5><leftSuperoff>",
    "<leftCtrlon><f2><leftCtrloff>",
    "u<down><down><down>",
    "<enter>",
    "<leftSuperon><f5><leftSuperoff><wait10>",
    "curl -o /var/root/packer.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/packer.pkg<enter>",
    "curl -o /var/root/setupsshlogin.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/setupsshlogin.pkg<enter>",
    "curl -o /var/root/bootstrap.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/bootstrap.sh<enter>",
    "chmod +x /var/root/bootstrap.sh<enter>",
    "/var/root/bootstrap.sh<enter>"
  ]
  cpus   = "6"
  cores  = "6"
  memory = "24576"
}

# Customize build
source "vmware-vmx" "macOS_11_customize" {
  display_name         = "macOS 11 customize"
  vm_name              = "macOS_11_customize"
  vmdk_name            = "macOS_11_customize"
  ssh_username     = "packer"
  ssh_password     = "packer"
  boot_wait        = "30s"
  skip_compaction  = true
  source_path      = "output/macOS_11_base/macOS_11_base.vmx"
  shutdown_command = "sudo shutdown -h now"
  output_directory = "output/{{build_name}}"
}

build {
  name    = "customize"
  sources = ["sources.vmware-vmx.macOS_11_customize"]

  provisioner "file" {
    sources     = ["install_bits/Xcode_12.2_Release_Candidate.xip", "install_bits/Command_Line_Tools_for_Xcode_12.2_Release_Candidate.dmg"]
    destination = "~/"
  }
  provisioner "shell" {
    scripts = [
      "scripts/xcode.sh"
    ]
  }
#  provisioner "shell" {
#    expect_disconnect = true
#    scripts = [
#      "scripts/softwareupdate.sh",
#      "scripts/softwareupdate_complete.sh"
#    ]
#  }
}
