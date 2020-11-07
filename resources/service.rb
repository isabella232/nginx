#
# Cookbook:: nginx
# Resource:: service
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

property :service_name, String,
          default: lazy { default_nginx_service_name },
          description: 'The service name to perform actions upon'

property :config_file, String,
          default: lazy { nginx_config_file },
          description: 'The path to the Nginx server configuration on disk'

property :config_test, [true, false],
          default: true,
          description: 'Perform configuration file test before performing service action'

action_class do
  def do_service_action(resource_action)
    with_run_context(:root) do
      edit_resource(:ruby_block, "Run pre #{new_resource.declared_type} #{resource_action} configuration test") do
        block do
          begin
            cmd = Mixlib::ShellOut.new("#{nginx_binary} -t -c #{new_resource.config_file}")
            cmd.run_command.error!
            Chef::Log.info('Configuration test passed')
          rescue Mixlib::ShellOut::ShellCommandFailed
            delete_resource!(:service, new_resource.service_name)
            raise "Configuration test failed, service action aborted!\n\nError\n-----\n#{cmd.stderr}"
          end
        end

        only_if { ::File.exist?(new_resource.config_file) }
        action :nothing
      end

      edit_resource(:service, new_resource.service_name) do
        notifies(
          :run,
          "ruby_block[Run pre #{new_resource.declared_type} #{resource_action} configuration test]",
          :before
        ) if new_resource.config_test && %i(start restart reload).include?(resource_action)

        action :nothing
        delayed_action resource_action
      end
    end
  end
end

action :start do
  do_service_action(action)
end

action :stop do
  do_service_action(action)
end

action :restart do
  do_service_action(action)
end

action :reload do
  do_service_action(action)
end

action :enable do
  do_service_action(action)
end

action :disable do
  do_service_action(action)
end
