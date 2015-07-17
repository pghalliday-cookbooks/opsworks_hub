opsworks_hub_stack node['opsworks_hub']['hub_stack_id'] do
  access_key_id node['opsworks_hub']['access_key_id']
  secret_access_key node['opsworks_hub']['secret_access_key']
  recipe node['opsworks_hub']['callback_recipe']
  action :upsert_and_notify
end
