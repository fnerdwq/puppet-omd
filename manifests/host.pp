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
  $folder = 'collected_hosts',
  $tags   = [],
) {
  validate_re($name, '^\w+$')
  # folder/tags are validated in subclass omd::client::export

  include 'omd::client'

 # grab all the interesting tags from facter to be used within
  # omd, each fact of (key, vale) will create a tag key_value
  $tags_from_facts = inline_template('
   <%= 
    obj = scope.to_hash.reject {|k,v|  \
      k.to_s =~ /^(uptime.*|rubysitedir|_timestamp|memoryfree.*|swapfree.*|title|name|caller_module_name|module_name|mac.*|[0-9]|netmask.*|blockdevice.*|mtu.*|hostname)$/  \
      or v.to_s =~ / |{|=/  \
      or v.to_s.length > 20 }

    arr = obj.sort
    out = ""
    arr.each do |k, v|
      out += sprintf("%s_%s,", k, v)
    end
   
    # Extra support for amazon resources
    obj = scope.to_hash.reject {|k,v|  k.to_s !~ /^ec2_network_interfaces_macs_/ }
    arr = obj.sort
    arr.each do |k, v|
      k = k.gsub(/.*:[0-9a-f][0-9a-f]_/, "")
      k = k.gsub(/_ids_[0-9]/, "")
      k = k.gsub(/_[0-9]/, "")
      if k =~ /mac/
        next
      end
      out += sprintf("%s_%s,", k, v)
    end

    out

   %>')

  # convert our string into an array for concat()
  $tags_from_facts_array = split(strip($tags_from_facts), ',')
  # join the 2 arrays together
  $new_tags = concat($tags, $tags_from_facts_array)


  @@omd::host::export{ "${name} - ${::fqdn}":
    folder => $folder,
    tags   => $new_tags,
    tag    => "omd_host_site_${name}_folder_${folder}",
  }

}
