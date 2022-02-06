# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
	config.vm.box = 'koalephant/debian9-amd64'

	config.vm.define 'Shell-Script-Library-Debian' do |debian|
		debian.vm.hostname = 'shell-script-library-debian.packaging.koalephant.com'
	end

	config.vm.provision 'setup', type: :shell, privileged: true, inline: '/vagrant/install-deps.sh --dev'

	config.vm.provision 'build', type: :shell, privileged: false, run: :never, inline: <<-BUILD
		cd /vagrant;
		./configure
		make distclean
		./configure
		make
	BUILD

	config.vm.provision 'test', type: :shell, privileged: false, run: :never, inline: <<-TEST
		cd /vagrant;
		make test
	TEST

	config.vm.provision 'test-release', type: :shell, privileged: false, run: :never, inline: <<-TEST_RELEASE
		cd /vagrant;
		./configure
		make distclean
		./configure
		make release
		
		cd "$(mktemp -d)"
		find /vagrant -name "*.tar.gz" -newer /vagrant/Makefile -print0 | xargs -0 tar -xvf;
		./configure
		make
		make test
	TEST_RELEASE



end
