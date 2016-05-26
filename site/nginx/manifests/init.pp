class nginx (
  $root = undef,
) {
  case $::osfamily {
    'redhat','debian' : {
      $package = 'nginx'
      $owner   = 'root'
      $group   = 'root'
#     $docroot = '/var/www'
      $confdir = '/etc/nginx'
      $logdir  = '/var/log/nginx'
      $default_docroot = '/var/www'
    }
    'windows' : {
      $package = 'nginx-service'
      $owner   = 'Administrator'
      $group   = 'Administrators'
      #$docroot = 'C:/ProgramData/nginx/html'
      $confdir = 'C:/ProgramData/nginx'
      $logdir  = 'C:/ProgramData/nginx/logs'
      $default_docroot = 'C:/ProgramData/nginx/html'
    }
    default   : {
      fail("Module ${module_name} is not supported on ${::osfamily}")
    }
  }
 # user the service will run as. Used in the nginx.conf.erb template
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
    owner => $owner,
    group => $root,
    mode  => '0664',
  }

  package { $package:
    ensure => present,
  }

  file { $docroot:
    ensure => directory,
  }

  file  { "${docroot}/index.html":
    ensure => file,
    source => 'puppet:///modules/nginx/index.html',
  }

  file { "${confdir}/nginx.conf":
    ensure  => file,
    content => template('nginx/nginx.conf.erb'),
    notify  => Service['nginx'],
  }

  file { "${confdir}/conf.d/default.conf":
    ensure  => file,
    content => template('nginx/default.conf.erb'),
    notify  => Service['nginx'],
  }

  service { 'nginx':
    ensure => running,
    enable => true,
  }
}
