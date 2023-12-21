# Class: corp104_cron_exporter
# ===========================
#
# Full description of class corp104_apache_exporter here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'corp104_cron_exporter':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class corp104_cron_exporter (
  String $scrape_uri,
  Optional[String] $extra_options,
  Optional[String] $download_url,
  String $install_method,
  String $version,
  String $bin_dir,
  String $package_ensure,
  String $package_name,
  String $service_ensure,
  String $service_name,
  Boolean $service_enable,
  Optional[String] $http_proxy,
  Boolean $manage_user,
  String $user,
  Boolean $manage_group,
  String $group,
  Optional[Array] $extra_groups,
  String $init_style,
  String $env_file_path,
  Hash[String, Scalar] $env_vars = {},
){
  contain corp104_cron_exporter::install
  contain corp104_cron_exporter::service

  Class['::corp104_cron_exporter::install']
  ~> Class['::corp104_cron_exporter::service']
}
