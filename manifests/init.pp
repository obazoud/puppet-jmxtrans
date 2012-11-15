# == Class jmxtrans
# 
class jmxtrans {
	include jmxtrans::install
	include jmxtrans::service
}

# == Class jmxtrans::metrics
#
# TODO:  Think of a better name for this
define jmxtrans::metrics(
	$jmx,
	$queries,
	$jmx_username         = undef,
	$jmx_password         = undef,
	$resultAlias          = undef,
	$ganglia              = undef,
	$ganglia_group_name   = undef,
	$graphite             = undef,
	$graphite_root_prefix = undef,
	$outfile              = undef
	)
{
	file { "/var/lib/jmxtrans/${title}.json":
		content => template("jmxtrans/jmxtrans.json.erb"),
		notify  => Service["jmxtrans"],
		require => Package["jmxtrans"],
	}
}