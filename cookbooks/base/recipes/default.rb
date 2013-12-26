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

package "nano"

cookbook_file "/etc/ssh/sshd_config" do
  source "etc/ssh/sshd_config"
  owner "root"
  group "root"
  mode "0600"
end  

remote_file "/root/.ssh/authorized_keys" do
  backup false
  source "https://github.com/#{node[:github_user]}.keys"
  owner "root"
  group "root"
  mode "0600"
end
