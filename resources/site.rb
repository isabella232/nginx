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

property :config_dir, String,
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

action :create do
  unless ::Dir.exist?(::File.dirname(new_resource.config_dir))
    directory ::File.dirname(new_resource.config_dir) do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end
  end

  template ::File.join(new_resource.config_dir, "#{new_resource.name}.conf") do
    cookbook new_resource.cookbook
    source   new_resource.template
    variables(
      new_resource.variables
    )
  end
end

action :delete do
  file new_resource.config_file do
    action :delete
  end
end
