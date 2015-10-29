class docker::compose (
    $install_compose = hiera('docker::install_compose', true),
    $compose_version = hiera('docker::compose_version'),
) {
    if ( $install_compose == true ) {
        file { "/etc/docker_compose_version":
            ensure  => 'present',
            owner   => 'root',
            group   => 'root',
            mode    => 644,
            content => "$compose_version",
        }
        ~>
        exec { "install_docker_compose":
            command => "/usr/bin/curl -L https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose",
            refreshonly => true,
        }
    }
}
