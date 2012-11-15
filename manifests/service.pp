# == Class jmxtrans::service
#
class jmxtrans::service {
	service { "jmxtrans":
		ensure => "running",
		enable => true,
	}
}