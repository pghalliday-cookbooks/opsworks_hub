actions :upsert_and_notify
default_action :upsert_and_notify

attribute :opsworks_hub_stack_id, name_attribute: true, kind_of: String, required: true
attribute :access_key_id, kind_of: String, required: true
attribute :secret_access_key, kind_of: String, required: true
attribute :recipes, kind_of: String, required: true
