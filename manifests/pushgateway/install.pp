# Class prometheus::pushgateway::install
#
class prometheus::pushgateway::install {
  case $::prometheus::pushgateway::manage_as {
    'container' : {
      docker::run { $::prometheus::pushgateway::package_name:
        image           => $::prometheus::pushgateway::container_image,
        command         => inline_template("<%= scope.function_template(['prometheus/_pushgateway.erb']) %>"),
        volumes         => ["${::prometheus::pushgateway::persistence_file}/${::prometheus::pushgateway::persistence_file}"],
        net             => 'host',
        restart_service => true,
        detach          => false,
        manage_service  => false,
        docker_service  => true,
      }
    }
    default     : {
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
      package { $::prometheus::pushgateway::package_name:
          ensure  => $::prometheus::pushgateway::package_ensure,
          require => $requiredrepo,
      }
    }
  }
}
