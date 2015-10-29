class docker::firewall {
    # Firewall configuration

    firewallchain { "DOCKER:filter:IPv4":
        ensure => present,
        purge  => false,
    }
    ->
    firewallchain { "DOCKER:nat:IPv4":
        ensure => present,
        purge  => false,
    }
    ->

    # NAT Rules

    firewall { "09000 DOCKER PREROUTING LOCAL":
        table       => 'nat',
        chain       => 'PREROUTING',
        proto       => 'all',
        dst_type    => 'LOCAL',
        jump        => 'DOCKER',
    }
    ->
    firewall { "09001 DOCKER OUTPUT LOCAL":
        table       => 'nat',
        chain       => 'OUTPUT',
        dst_type    => 'LOCAL',
        destination => '! 127.0.0.0/8',
        jump        => 'DOCKER',
    }
    ->
    firewall { "09002 DOCKER POSTROUTING MASQUERADE":
        table       => 'nat',
        chain       => 'POSTROUTING',
        proto       => 'all',
        source      => '172.17.0.0/16',
        outiface    => '! docker0',
        jump        => 'MASQUERADE',
    }
#    ->
    # FILTER Rules
#    firewall { "09010 DOCKER FORWARD":
#        table       => 'filter',
#        chain       => 'FORWARD',
#        proto       => 'all',
#        outiface    => 'docker0',
#        jump        => 'DOCKER',
#    }
#    ->
#    firewall { "09011 DOCKER FORWARD ACCEPT RELATED,ESTABLISHED":
#        table       => 'filter',
#        chain       => 'FORWARD',
#        proto       => 'all',
#        outiface    => 'docker0',
#        ctstate     => ['RELATED', 'ESTABLISHED'],
#        action      => 'accept', 
#    }
#    ->
#    firewall { "09012 DOCKER FORWARD i docker0 ! o docker0 ACCEPT":
#        table       => 'filter',
#        chain       => 'FORWARD',
#        proto       => 'all',
#        iniface     => 'docker0',
#        outiface    => '! docker0',
#        action      => 'accept',
#    }
#    ->
#    firewall { "09013 DOCKER FORWARD i docker0 o docker0 ACCEPT":
#        table       => 'filter',
#        chain       => 'FORWARD',
#        proto       => 'all',
#        outiface    => 'docker0',
#        iniface     => 'docker0',
#        action      => 'accept',
#    }
}
