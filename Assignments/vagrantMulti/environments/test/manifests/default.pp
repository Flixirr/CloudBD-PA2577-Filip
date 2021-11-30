node 'appserver' {
    include nodejs::app, ipaddress::append
}

node 'dbserver' {
    include mysql::server, ipaddress::append
}

node 'web' {
    include nginx::server, ipaddress::append
}

node /^tst\d+$/ {
    exec { 'apt-get update':
        command => "/usr/bin/apt-get update";
    }

    include ipaddress::append
}

node 'default' {
    exec { 'apt-get update':
        command => "/usr/bin/apt-get update";
    }
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

class nginx::server {
    exec { 'apt-get update':
        command => "/usr/bin/apt-get update";
    }

    package { 'nginx':
        ensure => installed,
        require => Exec['apt-get update'],
    }

    service { 'nginx':
        ensure => running,
        require => Package['nginx'],
    }
}

class ipaddress::append (
        $ipaddress = $facts[networking][interfaces][eth1][ip],
        $hostname = $facts[networking][hostname],
    ) {
    file { 'hosts':
        ensure => present,
        path => '/vagrant/hosts/hosts',
    }

    exec { 'append line':
        require => File['hosts'],
        command => "echo \"${ipaddress} ${hostname}\" >> /vagrant/hosts/hosts",
        unless => "grep -qxF \"${ipaddress} ${hostname}\" /vagrant/hosts/hosts",
        path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    }
}
