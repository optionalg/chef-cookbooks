#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2013, Gene Wood
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

include_recipe "base::hostname"

remote_file "#{Chef::Config[:file_cache_path]}/epel-release-6-8.noarch.rpm" do
  source "http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"
end

package "epel-release" do
  source "#{Chef::Config[:file_cache_path]}/epel-release-6-8.noarch.rpm"
end

package "nano"

cookbook_file "/etc/ssh/sshd_config" do
  source "etc/ssh/sshd_config"
  owner "root"
  group "root"
  mode "0600"
end  

directory "/root/.ssh" do
  owner "root"
  group "root"
  mode "0700"
end

remote_file "/root/.ssh/authorized_keys" do
  backup false
  source "https://github.com/#{node[:github_user]}.keys"
  owner "root"
  group "root"
  mode "0600"
end

file "/var/www/html/index.html" do
  owner "root"
  group "root"
  mode "0644"
  content "ok"
end

package "postfix"

execute "select_postfix_mta" do
  command "/usr/sbin/alternatives --set mta /usr/sbin/sendmail.postfix"
  not_if "/usr/sbin/alternatives --display mta | grep \"link currently points to /usr/sbin/sendmail.postfix\""
end

service "sendmail" do
  action [:disable, :stop]
end

service "postfix" do
  action [:enable, :start]
end
  
