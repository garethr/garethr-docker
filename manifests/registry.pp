# == Class: docker::registry
#
# Module to configure private docker registries from which to pull Docker images
# If the registry does not require authentication, this module is not required.
#
# === Parameters
# [*server*]
#   The hostname and port of the private Docker registry. Ex: dockerreg:5000
#
# [*homedir*]
#   Home directory of the use to configure the docker registry credentials for.
#   Default: '/root'
#
# [*ensure*]
#   Whether or not you want to login or logout of a repository
#   Default: 'present'
#
# [*username*]
#   Username for authentication to private Docker registry.  Required if ensure
#   is set to present.
#
# [*password*]
#   Password for authentication to private Docker registry. Required if ensure
#   is set to present.
#
# [*email*]
#   Email for registration to private Docker registry. Required if ensure is
#   set to present.
#
# [*show_diff*]
#   Whether or not to show diff when applying augeas resources.  Setting this
#   to true may expose sensitive information.
#   Default: false
#
define docker::registry(
  $server      = $title,
  $homedir     = '/root',
  $ensure      = 'present',
  $username    = undef,
  $password    = undef,
  $email       = undef,
  $show_diff   = false,
) {
  include docker::params

  validate_re($ensure, '^(present|absent)$')

  if $ensure == 'present' {
    validate_string($username)
    validate_string($password)
    validate_string($email)

    $auth_string = base64('encode', "${username}:${password}")

    # We can't manage the directory and config file directly here since we'd
    # end up with multiple resources managing the same files, and there isn't
    # another great place to put this.
    exec { "Create ${homedir}/.docker for ${title}":
      command => "mkdir -m 0700 -p ${homedir}/.docker",
      creates => "${homedir}/.docker",
    }

    -> exec { "Create ${homedir}/.docker/config.json for ${title}":
      command => "echo '{}' > ${homedir}/.docker/config.json; chmod 0600 ${homedir}/.docker/config.json",
      creates => "${homedir}/.docker/config.json",
    }

    -> augeas { "Create config in ${homedir} for ${title}":
      incl      => "${homedir}/.docker/config.json",
      lens      => 'Json.lns',
      show_diff => $show_diff,
      changes   => [
        "set dict/entry[. = 'auths'] 'auths'",
        "set dict/entry[. = 'auths']/dict/entry[. = '${server}'] '${server}'",
        "set dict/entry[. = 'auths']/dict/entry[. = '${server}']/dict/entry[. = 'email'] email",
        "set dict/entry[. = 'auths']/dict/entry[. = '${server}']/dict/entry[. = 'email']/string ${email}",
        "set dict/entry[. = 'auths']/dict/entry[. = '${server}']/dict/entry[. = 'auth'] auth",
        "set dict/entry[. = 'auths']/dict/entry[. = '${server}']/dict/entry[. = 'auth']/string ${auth_string}",
      ],
    }
  } else {
    augeas { "Remove auth entry in ${homedir} for ${title}":
      incl    => "${homedir}/.docker/config.json",
      lens    => 'Json.lns',
      changes => [
        "rm dict/entry[. = 'auths']/dict/entry[. = '${server}']",
      ],
    }
  }
}
