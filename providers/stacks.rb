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

def create_deployment_command (stack_id, stacks, recipes)
  stacks_data = {
    opsworks_hub: {
      stacks: stacks
    }
  }.to_json
  command = {
    Name: 'execute_recipes',
    Args: {
      recipes: recipes
    }
  }.to_json
  [
    aws_authentication,
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
    aws_authentication,
    "AWS_SECRET_ACCESS_KEY=#{new_resource.secret_access_key}",
    'aws opsworks --region us-east-1 update-stack',
    "--stack-id #{node['opsworks']['stack']['id']}",
    '--custom-json',
    "\"#{custom_json.gsub(/"/, '\"')}\""
  ].join(' ')
end

def describe_command
  [
    aws_authentication,
    "AWS_DEFAULT_OUTPUT=json",
    'aws opsworks --region us-east-1 describe-stacks',
    "--stack-ids #{node['opsworks']['stack']['id']}"
  ].join(' ')
end

action :upsert_and_notify do
  stack_data = new_resource.nodes
  raise "invalid stack data - need stack" if stack_data['stack'].nil?
  raise "invalid stack data - need name" if stack_data['stack']['name'].nil?
  raise "invalid stack data - need id" if stack_data['stack']['id'].nil?
  stack_name = stack_data['stack']['name']
  description_json = Mixlib::ShellOut.new(describe_command)
  description_json.run_command
  description_json.error!
  description = JSON.parse(description_json.stdout)
  custom_json = description['Stacks'][0]['CustomJson']
  custom = JSON.parse(custom_json)
  custom['opsworks_hub'] ||= {}
  customHubData = custom['opsworks_hub']
  customHubData['stacks'] ||= {}
  stacks = customHubData['stacks']
  if stacks[stack_name] != stack_data
    stacks[stack_name] = stack_data
    bash "set custom json for stack #{node['opsworks']['stack']['id']}" do
      code update_command(custom.to_json)
    end
    stacks.each do |name, stack|
      unless stack['recipes'].nil? || stack['recipes'].empty?
        bash "notify stack #{name} with current stack states" do
          code create_deployment_command(stack['stack']['id'], stacks, stack['recipes'])
        end
      end
    end
  end
end
