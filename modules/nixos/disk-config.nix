_: {
  # This formats the disk with the ext4 filesystem
  # Other examples found here: https://github.com/nix-community/disko/tree/master/example
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/mmcblk0";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
              priority = 1; # Needs to be first partition
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
      storage = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/mnt/storage";
                mountOptions = [
                  "defaults"
                  "noatime"
                  "nodiratime"
                  "discard"
                  "errors=remount-ro"
                ];
                postMountHook = ''
                  mkdir -p /mnt/mnt/storage/media
                  ln -s /mnt/mnt/storage/media /mnt/media
                  chown 0:3000 /mnt/mnt/storage
                  chmod 2770 /mnt/mnt/storage
                  setfacl -d -m g::rwx /mnt/mnt/storage
                  setfacl -d -m o::rx /mnt/mnt/storage
                '';
              };
            };
          };
        };
      };
    };
  };
}
