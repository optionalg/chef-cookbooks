#
# Cookbook Name:: nagios
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

iptables_rule "iptables-nrpe"

package "httpd"
service	"httpd"	do
  action [:enable, :start]
end

package "nagios"
package "nagios-plugins-all"
package "nagios-plugins-nrpe"

file "/etc/nagios/passwd" do
  content "#{node[:nagios][:web_username]}:#{node[:nagios][:web_password]}\n"
  owner "root"
  group "apache"
  mode "0640"
end

template "/etc/httpd/conf.d/nagios.conf" do
  source "etc/httpd/conf.d/nagios.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[httpd]", :delayed
end

package "bc"

git "#{Chef::Config[:file_cache_path]}/check_traffic" do
  repository "https://github.com/cloved/check_traffic.git"
  reference "v1.4.0"
end

file "#{Chef::Config[:file_cache_path]}/check_traffic/check_traffic.sh" do
  owner "root"
  group "root"
  mode "0755"
end

link "/usr/lib64/nagios/plugins/check_traffic.sh" do
  to "#{Chef::Config[:file_cache_path]}/check_traffic/check_traffic.sh"
end

package "openssl-perl"
package "perl-libwww-perl"
package "perl-Crypt-SSLeay"

remote_file "/usr/local/bin/nma.pl" do
  source "https://www.notifymyandroid.com/files/nma.pl"
  owner "root"
  group "root"
  mode "0755"
end

package "nrpe"

service "nrpe" do
  action [:enable, :start]
end

cookbook_file "/etc/nrpe.d/custom.cfg" do
  source "etc/nrpe.d/custom.cfg"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[nrpe]", :delayed
end

template "/etc/nagios/nrpe.cfg" do
  source "etc/nagios/nrpe.cfg.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[nrpe]", :delayed
end

group "nagios" do
  # This is so the nrpe process can read the nagios status.dat
  # to enable the check_nagios plugin
  action :modify
  append true
  members "nrpe"
  notifies :restart, "service[nrpe]", :delayed
end
