# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # Digital Ocean Deployment Instructions
  # =====================================
  # 1. Install the DigitalOcean Vagrant Provider plugin:
  #    $ vagrant plugin install vagrant-digitalocean
  # 2. Make the installation files available over the web. For example, upload the files to Dropbox and create a
  #    shareable link.
  # 3. Update the config.properties with the shareable link and any other customizations.
  # 4. Generate a personal access token. See https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2
  # 5. Update this file (Vagrantfile) with the token.
  # 6. Run Vagrant:
  #    $ vagrant up
  config.vm.define "oxar" do |config|
    config.vm.provider :digital_ocean do |provider, override|
      # Generate a personal access token.
      # See https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2
      provider.token = '<YOUR TOKEN>'
      provider.image = 'centos-7-x64'
      # For list of available regions, run: vagrant digitalocean-list regions <YOUR TOKEN>
      provider.region = 'sfo2'
      # For list of available size, run: vagrant digitalocean-list sizes <YOUR TOKEN>
      provider.size = 's-1vcpu-1gb'
      provider.ssh_key_name = 'OXAR'
      override.vm.box = 'digital_ocean'
      # Make sure to generate the SSH keypair prior to launch.
      override.ssh.private_key_path = '~/.ssh/id_rsa'
    end
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
  config.vm.provision "shell", inline: <<-SHELL
    export OOS_DEPLOY_TYPE="VAGRANT"

    if [ -n "$(command -v yum)" ]; then
      echo; echo \* Installing rsync with yum \*
      yum install rsync -y
    elif [ -n "$(command -v apt-get)" ]; then
      echo; echo \* Installing rsync with apt-get \*
      apt-get install rsync -y
    else
      echo; echo \* No known package manager found \*
    fi

    # [apng, 2016-07-01] A different approach to detecting and executing distro
    #                    specific code.
    #                    Information about os-release: http://0pointer.de/blog/projects/os-release.html
    if [ -f '/etc/os-release' ]; then
      echo; echo \* Source os-release for OS information \*
      . /etc/os-release

      # If the timezone is not set, Tomcat will not run as the JVM requires this to be set.
      if [ $ID == 'ubuntu' ]; then
        sed -i s/^.*$/UTC/ /etc/timezone;
      fi
    fi

    rsync -rtv --exclude='files' --exclude='.*' /vagrant/ /tmp/vagrant-deploy

    cd /tmp/vagrant-deploy

    nohup ./build.sh > nohup.out &
  SHELL
end
