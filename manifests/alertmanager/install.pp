# Class prometheus::alert_manager::install
#
class prometheus::alertmanager::install {
  case $::prometheus::alertmanager::manage_as {
    'container' : {
      if $::prometheus::alertmanager::storage_path {
        $vol_storage_path = "${::prometheus::alertmanager::storage_path}:${::prometheus::alertmanager::storage_path}"
      } else {
        $vol_storage_path = undef
      }
      $config_file = "${::prometheus::alertmanager::config_dir}/${::prometheus::alertmanager::config_file}"

      docker::run { $::prometheus::alertmanager::package_name:
        image           => $::prometheus::alertmanager::container_image,
        command         => inline_template("<%= scope.function_template(['prometheus/_alertmanager.erb']) %>"),
        volumes         => delete_undef_values(["${config_file}:${config_file}", $vol_storage_path,]),
        net             => 'host',
        restart_service => true,
        detach          => false,
        manage_service  => false,
        docker_service  => true,
      }
    }
    default : {
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
      package { $::prometheus::alertmanager::package_name:
          ensure  => $::prometheus::alertmanager::package_ensure,
          require => $requiredrepo,
      }
    }
  }
}
