# == Class jmxtrans::install
#
class jmxtrans::install {
	package { "jmxtrans": 
		ensure => "installed",
	}
}