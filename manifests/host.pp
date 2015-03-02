# == Define: omd::host
#
# This define expots a host to an omd::site.
# The host ist placed in the given wato folder and takes
# the listed tags.
#
# === Parameters
#
# [*folder*]
#   Folder in which the hosts are collected (must be created with omd::site)
#   defaults to _collected_hosts_
#
# [*tags*]
#   List of additional tags for the host in Check_MK/wato. The hosts alwas
#   get the 'puppet_generated' tag.
#   defaults to _[]_
#
# [*cluster_member*]
#   Is this host member of a cluster definition in this folder?
#   defaults to _false_
#
# === Examples
#
# omd::host { 'site_name':
#   folder => 'myhosts',
#   tags   => ['tag1', 'tag2'],
# }
#
# === Authors
#
# Frederik Wagner <wagner@wagit.de>
#
# === Copyright
#
# Copyright 2014 Frederik Wagner
#
define omd::host (
  $folder         = 'collected_hosts',
  $tags           = [],
  $cluster_member = false,
) {
  validate_re($name, '^\w+$')
  # folder/tags are validated in subclass omd::client::export

  include 'omd::client'

  @@omd::host::export{ "${name} - ${::fqdn}":
    folder         => $folder,
    tags           => $tags,
    cluster_member => $cluster_member,
    tag            => "omd_host_site_${name}_folder_${folder}",
  }

}
