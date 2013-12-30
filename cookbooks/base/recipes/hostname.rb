#
# Cookbook Name:: base
# Recipe:: hostname
#
# Copyright 2013, Gene Wood
#
# All rights reserved - Do Not Redistribute
#
# This is all done at compile time and not during convergence so that the
# new node[:fqdn] is available on the first run for use. To accomplish this
# we must 1) add the fqdn to /etc/hosts 2) update the hostname with the
# hosname command 3) reload ohai
# Ohai determines the node[:fqdn] by running "hostname --fqdn" which depends
# on 1) and 2)
#
# Inspiration from
# https://github.com/opscode-cookbooks/ohai/blob/master/recipes/default.rb

reload_ohai=false

# Note max hostname length : 64
hostname=node[:host][:hostname]
domain=node[:host][:domain]
fqdn=hostname + "." + domain
res = template "/etc/hosts" do
        source "etc/hosts.erb"
        variables(
          :hostname => hostname,
          :fqdn => fqdn
        )
        user "root"
        group "root"
        mode 0644
      end
res.run_action(:create)
reload_ohai ||= res.updated?

res = execute "hostname #{hostname}" do
        not_if {node[:hostname] == hostname}
      end
res.run_action(:run)
reload_ohai ||= res.updated?

if reload_ohai then
  res = ohai "reload"
  res.run_action(:reload)
end

ruby_block "inject_hostname" do
  block do
    f = Chef::Util::FileEdit.new("/etc/sysconfig/network")
    f.search_file_replace_line(/^HOSTNAME=/, "HOSTNAME=#{hostname}")
    f.write_file
  end
  not_if do
    open('/etc/sysconfig/network') { |f| f.lines.find { |line| line.include?("HOSTNAME=#{hostname}") } }
  end
end
