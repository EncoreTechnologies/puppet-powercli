# powercli

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with powercli](#setup)
    * [What powercli affects](#what-powercli-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with powercli](#beginning-with-powercli)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

Puppet module that manages the install of [VMware PowerCLI](https://www.vmware.com/support/developer/PowerCLI/)
on a Windows host. Once PowerCLI is installed we can then use it to manage VMware ESX and vCenter
with Puppet resources.

## How it works

``` shell
+---------------+    +----------------+        +---------+
| Puppet Master | -> | PowerCLI Proxy | -----> | vCenter |---------+
+---------------+    +----------------+   |    +---------+         v
                                          |                     +-----+
                                          +-------------------> | ESX |
                                                                +-----+
```

## Setup

### Requirements

- This module requires PowerShell (Core) 6 to be installed on the PowerCLI Proxy. Windows Server 2016 is highly recommended
to avoid Windows Server 2012r2 PowerShell heartaches.
- `powershell.exe` must be available in the system PATH

### Beginning with PowerCLI

[VMware PowerCLI](https://www.vmware.com/support/developer/PowerCLI/) is a command-line scripting tool built on PowerShell to manage VMWare environments.
This `puppet-powercli` module uses the [PowerShell Provider](https://forge.puppet.com/puppetlabs/powershell) to run PowerCLI commands within Puppet `exec` blocks.

The latest version of PowerCLI is installed onto the PowerCLI proxy at the beginning of every puppet agent run via the `powercli` class within `init.pp` in this module.

## Usage

This basic resource example will install a license key onto an ESXi host.

You run:
``` puppet
powercli::esx::license {'my-vmware-host.fqdn.tld':
  key => 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX'
}
```

Resource:
``` puppet
define powercli::esx::license (
  $key,
) {
  # including our vcenter connection class
  include powercli::vcenter::connection
  # $_connect = "Connect-VIServer"
  $_connect = $powercli::vcenter::connection::connect

  exec { "License host - ${name}:":
    # Install license
    command  => "${_connect}; Get-VMHost -Name '${name}' | Set-VMHost -LicenseKey ${key}",
    # Use PowerShell to run the above command
    provider => 'powershell',
    # Only run the above command if the below 'onlyif' returns '0' 
    onlyif   => template('powercli/powercli_esx_license_hosts_onlyif.ps1.erb'),
  }
}
```

OnlyIf template "powercli/powercli_esx_license_hosts_onlyif.ps1.erb":
``` puppet
# Connect to vcenter
<%= @_connect %>

# Grab the currently installed license key
$KeyCheck = Get-VMHost -Name '<%= @name %>' | Select-Object -ExpandProperty LicenseKey 

# Host was located in vcenter and license matches the key we want installed, exit 1 so puppet skips host
if($KeyCheck -eq '<%= @key %>'){
    exit 1
}
# Exit 0 so puppet installs license on current host
else{
   exit 0
}
```

## Reference

This section is deprecated. Instead, add reference information to your code as Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your module. For details on how to add code comments and generate documentation with Strings, see the Puppet Strings [documentation](https://puppet.com/docs/puppet/latest/puppet_strings.html) and [style guide](https://puppet.com/docs/puppet/latest/puppet_strings_style.html)

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the root of your module directory and list out each of your module's classes, defined types, facts, functions, Puppet tasks, task plans, and resource types and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

  * The data type, if applicable.
  * A description of what the element does.
  * Valid values, if the data type doesn't make it obvious.
  * Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.
