# Class prometheus::install
#
class prometheus::install {
  case $::prometheus::manage_as {
    'container' : {
      $config_file = "${::prometheus::config_dir}/${::prometheus::config_file}"

      docker::run { $::prometheus::package_name:
        image           => $::prometheus::container_image,
        command         => inline_template("<%= scope.function_template(['prometheus/_prometheus.erb']) %>"),
        volumes         => delete_undef_values([
            "${config_file}:${config_file}",
            "${::prometheus::storage_local_path}:${::prometheus::storage_local_path}",
        ]),
        net             => 'host',
        restart_service => true,
        detach          => false,
        manage_service  => false,
        docker_service  => true,
      }
    }
    'repo' : {
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
          fail("Repo installation method is not supported on: ${::osfamily}")
        }
      }
      package { $::prometheus::package_name:
          ensure  => $::prometheus::package_ensure,
          require => $requiredrepo,
      }
    }
  }
}
