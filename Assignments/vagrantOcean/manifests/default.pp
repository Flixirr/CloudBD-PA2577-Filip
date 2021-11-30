node 'appserver' {
    include nodejs::app
}

node 'dbserver' {
    include mysql::server
}

class nodejs::app {
    exec { 'apt-get update':
        command => "/usr/bin/apt-get update";
    }

    package { 'curl':
        ensure => present,
        require => Exec['apt-get update'],
    }

    exec { 'curl nodesource':
        command => "curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -",
        require => Package['curl'],
        path => '/usr/bin',
    }

    package { 'nodejs':
        ensure => installed,
        require => Exec['curl nodesource'],
    }
}

class mysql::server {
    exec { 'apt-get update':
        command => "/usr/bin/apt-get update";
    }

    package { 'mysql-server':
        ensure => installed,
        require => Exec['apt-get update'],
    }

    service { 'mysql':
        ensure => running,
        require => Package['mysql-server'],
    }
}
