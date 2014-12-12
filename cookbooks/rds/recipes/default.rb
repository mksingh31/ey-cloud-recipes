#
# Cookbook Name:: rds
# Recipe:: default
#
# Configure application servers to use an Amazon RDS database (or any external ActiveRecord-compatible database)
# Note: This recipe does not make any changes to Engine Yard-provisioned databases

if ['solo', 'app_master', 'app', 'util'].include?(node[:instance_role])
  # for each application
  node.engineyard.apps.each do |app|
    # retrieve attributes
    attributes = node[app.name]

    # skip if there are no attributes for this app
    next if attributes.nil?

    ey_cloud_report "RDS" do
      message "RDS - Replacing database.yml for #{app.name}"
    end

    # create new database.yml with attributes
    template "/data/#{app.name}/shared/config/database.yml" do
      owner node[:owner_name]
      group node[:owner_name]
      backup false
      mode 0644
      source 'database.yml.erb'
      variables({
        :environment => node[:environment][:framework_env],
        :adapter => 'mysql2',
        :database => app[:database_name],
        :username => node[:users][0][:username],
        :password => node[:users][0][:password],
        :host => node[:db_host]
      })
    end
  end
end