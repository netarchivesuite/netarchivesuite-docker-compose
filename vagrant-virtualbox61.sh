#!/usr/bin/env bash

#Run this script to install vagrant with virtualbox 6.1 and fix it
sudo dnf install vagrant VirtualBox -y
sudo dnf remove vagrant-libvirt -y


# https://github.com/oracle/vagrant-boxes/issues/178#issue-536720633

#/usr/share/vagrant/gems/gems/vagrant-2.2.6/plugins/providers/virtualbox/
file=/usr/share/vagrant/gems/gems/vagrant-2.2.6/plugins/providers/virtualbox/plugin.rb
grep -q '  autoload :Version_6_1, File.expand_path("../driver/version_6_1", __FILE__)' $file || \
sed 's|\(autoload :Version_6_0, File.expand_path("../driver/version_6_0", __FILE__)\)|\1\n      autoload :Version_6_1, File.expand_path\("../driver/version_6_1", __FILE__\)|g' $file -i


file=/usr/share/vagrant/gems/gems/vagrant-2.2.6/plugins/providers/virtualbox/driver/meta.rb
grep -q '6.1" => Version_6_1,' $file || \
sed 's|\(  "6.0" => Version_6_0,\)|\1\n            "6.1" => Version_6_1,|g' $file -i


cat > /usr/share/vagrant/gems/gems/vagrant-2.2.6/plugins/providers/virtualbox/driver/version_6_1.rb <<EOF
require File.expand_path("../version_6_0", __FILE__)

module VagrantPlugins
  module ProviderVirtualBox
    module Driver
      # Driver for VirtualBox 6.1.x
      class Version_6_1 < Version_6_0
        def initialize(uuid)
          super

          @logger = Log4r::Logger.new("vagrant::provider::virtualbox_6_1")
        end
      end
    end
  end
end
EOF