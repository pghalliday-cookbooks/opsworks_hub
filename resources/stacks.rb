actions :upsert_and_notify
default_action :upsert_and_notify

attribute :access_key_id, kind_of: String, required: true
attribute :secret_access_key, kind_of: String, required: true
attribute :nodes, kind_of: Hash, required: true
