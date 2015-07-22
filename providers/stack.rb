require 'json'

def whyrun_supported?
  true
end

use_inline_resources

def aws_authentication
  if new_resource.access_key_id
    [
      "AWS_ACCESS_KEY_ID=#{new_resource.access_key_id}",
      "AWS_SECRET_ACCESS_KEY=#{new_resource.secret_access_key}"
    ].join(' ')
  else
    ''
  end
end

def create_deployment_command
  stack_data = {
    opsworks_hub: {
      incoming: {
        data: {
          stack: node['opsworks']['stack'],
          layers: node['opsworks']['layers'],
          recipes: new_resource.recipes
        },
        id: node['opsworks']['stack']['id']
      }
    }
  }.to_json
  command = {
    Name: 'execute_recipes',
    Args: {
      recipes: [
        'opsworks_hub::notify'
      ]
    }
  }.to_json
  [
    aws_authentication,
    'aws opsworks --region us-east-1 create-deployment',
    "--stack-id #{new_resource.opsworks_hub_stack_id}",
    '--command',
    "\"#{command.gsub(/"/, '\"')}\"",
    '--custom-json',
    "\"#{stack_data.gsub(/"/, '\"')}\""
  ].join ' '
end

action :upsert_and_notify do
  bash "Sending stack configuration to hub #{new_resource.opsworks_hub_stack_id}" do
    code create_deployment_command
  end
end
