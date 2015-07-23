layer_name = node['opsworks_hub']['layer_name']
first_ip =  node['opsworks']['layers'][layer_name]['instances'].first[1]['ip']
my_ip = node['opsworks']['instance']['ip']
if my_ip == first_ip
  opsworks_hub_stacks node['opsworks']['stack']['id'] do
    access_key_id node['opsworks_hub']['access_key_id']
    secret_access_key node['opsworks_hub']['secret_access_key']
    nodes node['opsworks_hub']['incoming']
    action :upsert_and_notify
  end
end
