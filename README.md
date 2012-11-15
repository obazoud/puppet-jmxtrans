# puppet-jmxtrans

A Puppet module for [jmxtrans](https://github.com/lookfirst/jmxtrans).

This module assumes that a 'jmxtrans' package is available for
puppet to install.  There are some prebuilt packages over at
the jmxtrans github [download page](https://github.com/lookfirst/jmxtrans/downloads).

Including the ```jmxtrans``` class will install jmxtrans and ensure
that it is running.  Use the ```jmxtrans::metrics``` define to install
jmxtrans JSON query config files.  See the [jmxtrans wiki](https://github.com/lookfirst/jmxtrans/wiki/Queries)
if you are not familiar with jmxtrans queries.

```jmxtrans::metrics``` abstracts much of the repetitive JSON structures
needed to build jmxtrans queries.  It currently supports KeyOutWriter,
GangliaWriter and GraphiteWriter.  You specify the JMX connection info
and the queries, and configuration information about each output writer
you would like to use.  You should use a single ```jmxtrans::metrics```
define for each JVM you would like query.  This will keep JMX queries
to a single JVM bundled together.  See jmxtrans
[best practices](https://github.com/lookfirst/jmxtrans/wiki/BestPractices)
for more information.

# Usage 
## Hadoop NameNode with multiple jmxtrans outputs

Query a Hadoop NameNode for some stats, and write the metrics to
/tmp/namenode.jmx.out, Ganglia, and Graphite.

```puppet
include jmxtrans

jmxtrans::metrics { "hadoop-hdfs-namenode":
	jmx                   => "127.0.0.1:9980",
	outfile               => "/tmp/namenode.jmx.out",
    ganglia               => "127.0.0.1:8649",
    ganglia_group_name    => "hadoop",
	graphite              => "127.0.0.1:2003",
	graphite_root_prefix  => "hadoop",
	queries => [ 
		{
			"obj"    => "Hadoop:service=NameNode,name=NameNodeActivity",
			"attr"   => ["FileInfoOps", "FilesCreated", "FilesDeleted"],
		},
		{
			"obj"    => "Hadoop:service=NameNode,name=FSNamesystem",
			"attr"   => ["BlockCapacity", "BlocksTotal", "TotalFiles"],
		},
	],
}
```

## Kafka Broker with jmxtrans Ganglia output

```puppet
include jmxtrans

# Since we have multiple hosts sharing the same queries,
# we define a $jmx_kafka_queries variable to hold them.
# This will be passed as the queries parameter to each Kafka host.
$jmx_kafka_queries = [ 
	{
		"obj"    => "kafka:type=kafka.BrokerAllTopicStat",
		"attr"   => [ "BytesIn", "BytesOut", "FailedFetchRequest", "FailedProduceRequest", "MessagesIn" ]
	},
	{
		"obj"    => "kafka:type=kafka.LogFlushStats",
		"attr"   => [ "AvgFlushMs", "FlushesPerSecond", "MaxFlushMs", "NumFlushes", "TotalFlushMs" ]
	},
	{
		"obj"    => "kafka:type=kafka.SocketServerStats",
		"attr"   => [ 
		    "AvgFetchRequestMs",
		    "AvgProduceRequestMs",
		    "BytesReadPerSecond",
		    "BytesWrittenPerSecond",
		    "FetchRequestsPerSecond",
		    "MaxFetchRequestMs",
		    "MaxProduceRequestMs",
		    "NumFetchRequests",
		    "NumProduceRequests",
		    "ProduceRequestsPerSecond",
		    "TotalBytesRead",
		    "TotalBytesWritten",
		    "TotalFetchRequestMs",
		    "TotalProduceRequestMs"
		]
	}
]

# query kafka1 for its JMX metrics
jmxtrans::metrics { "kafka1":
    jmx     => "kafka1:9999",
    ganglia => "192.168.10.50:8469",
    queries => $jmx_kafka_queries,
}

# query kafka2 for its JMX metrics
jmxtrans::metrics { "kafka2":
    jmx     => "kafka2:9999",
    ganglia => "192.168.10.50:8469",
    queries => $jmx_kafka_queries,
}
```