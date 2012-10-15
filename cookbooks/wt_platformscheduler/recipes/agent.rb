#
# Cookbook Name:: wt_platformscheduler
# Recipe:: default
# Author:: Kendrick Martin
#
# Copyright 2012, Webtrends
#
# All rights reserved - Do Not Redistribute
# This recipe installs VDM Scheduler Agent
#
if ENV["deploy_build"] == "true" then
  log "The deploy_build value is true so un-deploy first"  
 # include_recipe "wt_platformscheduler::agent_uninstall"
else
  log "The deploy_build value is not set or is false so we will only update the configuration"
end

# destinations
install_dir = node['wt_common']['install_dir_windows']
log_dir     = node['wt_common']['install_log_dir_windows']

# get data bag items
auth_data = data_bag_item('authorization', node.chef_environment)
svcuser = auth_data['wt_common']['system_user']
svcpass = auth_data['wt_common']['system_pass']

# get parameters
master_host = node['wt_masterdb']['master_host']
sched_host = node['wt_masterdb']['sched_host']

log "Source URL: #{node['wt_platformscheduler']['agent']['download_url']}"

# create the log directory
directory log_dir do
	recursive true
	action :create
end

# create the install directory
directory install_dir do
	recursive true
	action :create
end

if ENV["deploy_build"] == "true" then

	# execute the VDM scheduler Agent MSI
	windows_package "Webtrends VDM Scheduler Agent" do
		source node['wt_platformscheduler']['agent']['download_url']
		options "/l*v \"#{log_dir}\\PlatformSchedulerAgent-Install.log\" SERVICEACCT=#{svcuser} SERVICEPASS=#{svcpass} AGENTMANAGERADDRESS=agentmanager.1@#{sched_host} BASEFOLDER=#{install_dir} LOGTOFILE=true FILELOGGINGLEVEL=4 SCHEDULERADDRESS=scheduler2@#{sched_host} MASTER_HOST=#{master_host} STANDALONE=TRUE INSTALLDIR=\"#{install_dir}\\agent\\common\""
		action :install
	end
	
	share_wrs
end
