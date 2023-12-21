class corp104_cron_exporter::install inherits corp104_cron_exporter {

  $options = "${corp104_cron_exporter::scrape_uri} ${corp104_cron_exporter::extra_options}"
  $os_arch = $facts['architecture'] ? {
  'i386'   => 'amd64',
  'x86_64' => 'amd64',
  'amd64'  => 'amd64',
  default  => 'amd64',
  }
  $proxy_server = empty($corp104_cron_exporter::http_proxy) ? {
    true    => undef,
    default => $corp104_cron_exporter::http_proxy,
  }
  # install
  case $corp104_cron_exporter::install_method {
    'url': {
      archive { "/tmp/${corp104_cron_exporter::package_name}-${corp104_cron_exporter::version}.tar.gz":
        ensure          => present,
        extract         => true,
        extract_path    => '/opt',
        source          => $corp104_cron_exporter::download_url,
        checksum_verify => false,
        creates         => "/opt/${corp104_cron_exporter::package_name}-${corp104_cron_exporter::version}.linux-${os_arch}/${corp104_cron_exporter::package_name}",
        cleanup         => true,
        proxy_server    => $proxy_server,
      }
      file { "/opt/${corp104_cron_exporter::package_name}-${corp104_cron_exporter::version}.linux-${os_arch}/${corp104_cron_exporter::package_name}":
          owner => 'root',
          group => 0, # 0 instead of root because OS X uses "wheel".
          mode  => '0555',
      }
      -> file { "${corp104_cron_exporter::bin_dir}/${corp104_cron_exporter::service_name}":
          ensure => link,
          notify => Service['cron-exporter'],
          target => "/opt/${corp104_cron_exporter::package_name}-${corp104_cron_exporter::version}.linux-${os_arch}/${corp104_cron_exporter::package_name}",
      }
    }
    'package': {
      package { $corp104_cron_exporter::package_name:
        ensure => $corp104_cron_exporter::package_ensure,
      }
      if $corp104_cron_exporter::manage_user {
        User[$corp104_cron_exporter::user] -> Package[$corp104_cron_exporter::package_name]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${corp104_cron_exporter::install_method} is invalid")
    }
  }

  # manage user and group
  if $corp104_cron_exporter::manage_user {
    ensure_resource ('user', [ $corp104_cron_exporter::user ], {
      ensure => 'present',
      system => true,
      groups => $corp104_cron_exporter::extra_groups,
    })

    if $corp104_cron_exporter::manage_group {
      Group[$corp104_cron_exporter::group] -> User[$corp104_cron_exporter::user]
    }
  }
  if $corp104_cron_exporter::manage_group {
    ensure_resource ('group', [ $corp104_cron_exporter::group ], {
      ensure => 'present',
      system => true,
    })
  }

  # manage init type
  if $corp104_cron_exporter::init_style {
    case $corp104_cron_exporter::init_style {
      'upstart' : {
        file { "/etc/init/${corp104_cron_exporter::package_name}.conf":
          mode    => '0444',
          owner   => 'root',
          group   => 'root',
          content => template("${module_name}/daemon.upstart.erb"),
          notify  => Service['cron-exporter'],
        }
        file { "/etc/init.d/${corp104_cron_exporter::package_name}":
          ensure => link,
          target => '/lib/init/upstart-job',
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
        }
      }
      'systemd' : {
        include 'systemd'
        systemd::unit_file {"${corp104_cron_exporter::service_name}.service":
          content => template("${module_name}/daemon.systemd.erb"),
          notify  => Service['cron-exporter'],
        }
      }
      'sysv' : {
        file { "/etc/init.d/${corp104_cron_exporter::service_name}":
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template("${module_name}/daemon.sysv.erb"),
          notify  => Service['cron-exporter'],
        }
      }
      'redhat' : {
        if $facts['os']['family'] == 'RedHat' {
          if $facts['os']['release']['major'] == '5' {
            file { "/etc/init.d/${corp104_cron_exporter::service_name}":
              mode    => '0555',
              owner   => 'root',
              group   => 'root',
              content => template("${module_name}/daemon.sysv.bash3.erb"),
              notify  => Service['cron-exporter'],
            }
          }
          else {
            file { "/etc/init.d/${corp104_cron_exporter::service_name}":
              mode    => '0555',
              owner   => 'root',
              group   => 'root',
              content => template("${module_name}/daemon.sysv.erb"),
              notify  => Service['cron-exporter'],
            }
          }
        }
      }
      'debian' : {
        file { "/etc/init.d/${corp104_cron_exporter::service_name}":
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template("${module_name}/daemon.debian.erb"),
          notify  => Service['cron-exporter'],
        }
      }
      default : {
        fail("I don't know how to create an init script for style ${corp104_cron_exporter::init_style}")
      }
    }
  }

  if $corp104_cron_exporter::env_file_path != undef {
    file { "${corp104_cron_exporter::env_file_path}/${corp104_cron_exporter::service_name}":
      mode    => '0644',
      owner   => 'root',
      group   => '0', # Darwin uses wheel
      content => template("${module_name}/daemon.env.erb"),
      notify  => Service['cron-exporter'],
    }
  }

}
