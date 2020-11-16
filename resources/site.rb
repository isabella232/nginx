#
# Cookbook:: nginx
# Resource:: site
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

property :conf_dir, String,
          description: 'Which site to enable or disable.',
          default: lazy { nginx_config_site_dir }

property :cookbook, String,
          description: 'Which cookbook to use for the template.',
          default: 'nginx'

property :template, [String, Array],
          description: 'Which template to use for the site.',
          default: 'site-template.erb'

property :variables, Hash,
          description: 'Additional variables to include in site template.',
          default: {}

action_class do
  include Nginx::Cookbook::ResourceHelpers

  def config_file
    ::File.join(new_resource.conf_dir, "#{new_resource.name}.conf")
  end
end

action :create do
  unless ::Dir.exist?(::File.dirname(new_resource.conf_dir))
    directory ::File.dirname(new_resource.conf_dir) do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end
  end

  template config_file do
    cookbook new_resource.cookbook
    source   new_resource.template

    owner 'root'
    group nginx_user
    mode '0640'

    variables(
      new_resource.variables.merge({ name: new_resource.name })
    )
  end

  add_to_list_resource(
    new_resource.conf_dir,
    config_file
  )
end

action :delete do
  file config_file do
    action :delete
  end

  remove_from_list_resource(
    new_resource.conf_dir,
    config_file
  )
end
