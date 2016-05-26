class nginx (
  $root = undef,
) {
  case $::osfamily {
    'redhat','debian' : {
      $package  = 'nginx'
      $owner    = 'root'
      $group    = 'root'
      #$docroot  = '/var/www'
      $default_docroot  = '/var/www'
      $confdir  = '/etc/nginx'
      $blockdir = '/etc/nginx/conf.d'
      $logdir   = '/var/log/nginx'
    }
    default   : {
      fail("Module ${module_name} is not supported on ${::osfamily}")
    }
  }

  $user = $::osfamily ? {
    'redhat'  => 'nginx',
    'debian'  => 'www-data',
    'windows' => 'nobody',
  }

  $docroot = $root ? {
    undef   => $default_docroot,
    default => $root,
  }

  File {
    ensure => file,
    owner  => $owner,
    group  => $root,
    mode   => '0664',
  }

  package { $package:
    ensure => present,
  }

  file { $docroot:
    ensure => directory,
  }

  file  { "${docroot}/index.html":
    source => 'puppet:///modules/nginx/index.html',
  }

  file { "${confdir}/nginx.conf":
    content => template('nginx/nginx.conf.erb'),
  }

  file { "${blockdir}/default.conf":
    content => template('nginx/default.conf.erb'),
  }

  service { 'nginx':
    ensure    => running,
    enable    => true,
    subscribe => [File["${confdir}/nginx.conf"],File["${blockdir}/default.conf"]],
  }
}
