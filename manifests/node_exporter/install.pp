# Class prometheus::node_exporter::install
#
class prometheus::node_exporter::install {

  case $::osfamily {
    'RedHat' : {
      yumrepo { 'prometheus-rpm_release':
        baseurl => "https://packagecloud.io/prometheus-rpm/release/el/${::operatingsystemmajrelease}/\$basearch",
        repo_gpgcheck   => 1,
        gpgcheck        => 0,
        enabled         => 1,
        gpgkey          => 'https://packagecloud.io/prometheus-rpm/release/gpgkey',
        sslverify       => 1,
        sslcacert       => '/etc/pki/tls/certs/ca-bundle.crt',
        metadata_expire => 300,
      }
      $requiredrepo = Yumrepo['prometheus-rpm_release']
    }
    default : {
      $requiredrepo = []
    }
  }

  package { $::prometheus::node_exporter::package_name:
    ensure  => $::prometheus::node_exporter::package_ensure,
    require => $requiredrepo,
    notify  => Service['node_exporter'],
  }
}
