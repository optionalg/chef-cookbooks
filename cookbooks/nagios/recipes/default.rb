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

package "httpd"
service	"httpd"	do
  action [:enable, :start]
end

package "nagios"
package "nagios-plugins-all"

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
