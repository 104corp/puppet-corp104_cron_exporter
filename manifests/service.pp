class corp104_cron_exporter::service inherits corp104_cron_exporter {

  $real_provider = $corp104_cron_exporter::init_style ? {
    'sles'  => 'redhat',  # mimics puppet's default behaviour
    'sysv'  => 'redhat',  # all currently used cases for 'sysv' are redhat-compatible
    default => $corp104_cron_exporter::init_style,
  }

  service { 'cron-exporter':
    ensure   => $corp104_cron_exporter::service_ensure,
    name     => $corp104_cron_exporter::service_name,
    enable   => $corp104_cron_exporter::service_enable,
    provider => $real_provider,
  }

}
