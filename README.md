# How to setup a host to use these cookbooks

```
curl -L https://www.opscode.com/chef/install.sh | bash
mkdir -p /var/chef/cache /etc/chef
yum install -y git
git clone https://github.com/gene1wood/chef-cookbooks.git /root/chef
git clone https://github.com/opscode-cookbooks/iptables.git /var/chef/cookbooks/iptables
ln -s /root/chef/solo.rb /etc/chef/solo.rb
cat > /etc/chef/node.json <<End-of-message
{
  "run_list": [ "recipe[base]" ],
  "github_user": "gene1wood"
}
End-of-message
chmod 600 /etc/chef/node.json
chef-solo -c /etc/chef/solo.rb -j /etc/chef/node.json
```
