# attributes used by the hub and client stacks
default['opsworks_hub']['access_key_id'] = nil
default['opsworks_hub']['secret_access_key'] = nil

# attributes used by client stacks
default['opsworks_hub']['hub_stack_id'] = nil
default['opsworks_hub']['callback_recipes'] = []

# attributes used by the hub stack
default['opsworks_hub']['layer'] = nil

# attributes used internally by the hub (do not need to set these)
default['opsworks_hub']['incoming'] = {}
default['opsworks_hub']['stacks'] = {}
