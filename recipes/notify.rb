opsworks_hub_stacks node['opsworks']['stack']['id'] do
  access_key_id node['opsworks_hub']['access_key_id']
  secret_access_key node['opsworks_hub']['secret_access_key']
  nodes node['opsworks_hub']['incoming']
  action :upsert_and_notify
end
