actions :upsert_and_notify
default_action :upsert_and_notify

attribute :nodes, kind_of: Hash, required: true
attribute :access_key_id, kind_of: String
attribute :secret_access_key, kind_of: String
