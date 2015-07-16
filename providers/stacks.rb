require 'json'

def whyrun_supported?
  true
end

use_inline_resources

def create_deployment_command (stack_id, stacks, recipe)
  stacks_data = {
    opsworks_hub: {
      stacks: stacks
    }
  }.to_json
  command = {
    Name: 'execute_recipes',
    Args: {
      recipes: [
        recipe
      ]
    }
  }.to_json
  [
    "AWS_ACCESS_KEY_ID=#{new_resource.access_key_id}",
    "AWS_SECRET_ACCESS_KEY=#{new_resource.secret_access_key}",
    'aws opsworks --region us-east-1 create-deployment',
    "--stack-id #{stack_id}",
    '--command',
    "\"#{command.gsub(/"/, '\"')}\"",
    '--custom-json',
    "\"#{stacks_data.gsub(/"/, '\"')}\""
  ].join ' '
end

def update_command (custom_json)
  [
    "AWS_ACCESS_KEY_ID=#{new_resource.access_key_id}",
    "AWS_SECRET_ACCESS_KEY=#{new_resource.secret_access_key}",
    'aws opsworks --region us-east-1 update-stack',
    "--stack-id #{node['opsworks']['stack']['id']}",
    '--custom-json',
    "\"#{custom_json.gsub(/"/, '\"')}\""
  ].join(' ')
end

def describe_command
  [
    "AWS_ACCESS_KEY_ID=#{new_resource.access_key_id}",
    "AWS_SECRET_ACCESS_KEY=#{new_resource.secret_access_key}",
    'aws opsworks --region us-east-1 describe-stacks',
    "--stack-ids #{node['opsworks']['stack']['id']}"
  ].join(' ')
end

action :upsert_and_notify do
  stack_data = node['opsworks_hub']['incoming']
  raise "invalid stack data - need id" if stack_data['id'].nil?
  raise "invalid stack data - need data" if stack_data['data'].nil?
  raise "invalid stack data - need recipe" if stack_data['recipe'].nil?
  stack_id = stack_data['id']
  description_json = Mixlib::ShellOut.new(describe_command)
  description_json.run_command
  description_json.error!
  description = JSON.parse(description_json.stdout)
  custom_json = description['CustomJson']
  custom = JSON.parse(custom_json)
  stacks = custom['opsworks_hub']['stacks']
  stacks[stack_id] = stack_data['data']
  bash "set custom json for stack #{node['opsworks']['stack']['id']}" do
    code update_command(custom.to_json)
  end
  stacks.each do |id, stack|
    if not id.eql?(stack_id)
      bash "notify stack #{id} with new stack states" do
        code create_deployment_command(id, stacks, stack['recipe'])
      end
    end
  end
end
