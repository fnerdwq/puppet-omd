
#Puppet omd Module

[![Build Status](https://travis-ci.org/fnerdwq/puppet-omd.svg?branch=master)](https://travis-ci.org/fnerdwq/puppet-omd)

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What omd affects](#what-omd-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with omd](#beginning-with-omd)
4. [Usage](#usage)
5. [Limitations](#limitations)
6. [TODOs](#TODOs)

##Overview

This module installs and configures the [Open Monitoring
Distirbution](http://omdistro.org/) on a server. It also installs the
corresponding Check\_MK agent on client systems.

In the installation (multiple) OMD site(s) can be setup and the client nodes
can be exported as monitored hosts. The hosts are gathered in a WATO manageable
way.

##Module Description

See [Overview](#overview) for now.

##Setup

###What omd affects

* On the OMD server the repository from <http://labs.consol.de/> is installed.
* Webserver configuration: In case you are using the puppetlabs-apache module
  to purge the non-managed configuration, be sure to include the OMD
  configuration.
* As default the xinetd configuration on the clients is adjusted to allow acces
  to the check\_mk\_agent.

###Setup Requirements

For ``omd::client`` a specific version of the ``check_mk_agent`` *must* be given (unluckily no default is sensefull). See the download page of the [check\_mk\_agent](https://mathias-kettner.de/check_mk_download.html).

###Beginning with omd	

Installing the server with a default site:
```puppet
include omd::server
```

Installing a client with host export to the ``default`` site  - into the folder
``collected_nodes``
```puppet
class { 'omd::client':
  check_mk_version => '1.2.4p5-1',
}
```

##Usage

Installing server and client see [Beginning with omd](#beginning-with-omd).

To create additional sites use
```puppet
omd::site { 'newsite':
  config_hosts_folders => ['important_nodes', 'test_nodes']
}
```
As default a ``Omd::Site`` is collecting hosts for all the configured folders!

To export a client as additional host use
```puppet
omd::host { 'newsite':
  folder => 'important_nodes',
  tags   => ['production', 'important'],
}
```
This will be collected into the ``important_nodes`` folder in the
``newsite`` site. It receives two extra tags. This host could be exported to
an additional site in an arbitray folder but *not* to the same site again.

**Remark** The best way to create sites and hosts is via the corresponding
parameters in omd::server and omd::client!

```puppet
class { 'omd::server':
  sites => { 
    'mysite'    => {},
    'othersite' => {
      'config_hosts_folders' => ['otherfolder'],
    },
  }
}

class { 'omd::client':
  check_mk_version => '1.2.4p5-1',
  hosts            => {
    'mysite'    => {},
    'othersite' => { 'folder' => 'otherfolder' }
  }
}

```

##Limitations:

Explicitly tested on:
* Debian 7
* CentOS 6

Other Debian and RedHat like systems may/should work.

##TODOs:

* add distribution of checks (with MRPE)
* add nagios\_service like behavior
* host/servicegroups
* configurable check over ssh instead of xinetd
* ...

Please open an issue on github if you have any suggestions.
