define nginx::vhost (
  $port       = '80',
  $servername = $title,
  $docroot    = "${nginx::docroot}/vhosts/${title}",
  ) {
}
