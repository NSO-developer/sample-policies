# NSO Sample Policies

This repository contains various samples on how NSO can be used for configuration governance and policy compliance

More docs coming soon...

# Requirements

* NSO 4.7 - [Free Evaluation](https://developer.cisco.com/site/nso/)
* cisco-ios and cisco-nx Network Element Drivers (NEDs) which ship with NSO evaluation


# Installing


## NSO / Netsim

Assuming you have NSO installed on your system, you can
create a local dev environment to play around with.

The following commands will get you started quickly

```
source /path/to/your/.ncsrc
make netsim
make nso
```

**NOTE:** these commands should be run from the root of this repository.


## Adding Policies to NSO

The scripts located in [./policies](./policies)  are files which describe the intended policy, and associated compliance/enforcement. These files are written in XML
and can be used as payloads against the NSO REST API, configured via CLI, or
in a pinch, you can also just `load merge` them from ncs_cli

```
ncs_cli -u admin -C

admin@ncs# config t
Entering configuration mode terminal

admin@ncs(config)# load merge policies/Device_Groups.xml
Loading.
852 bytes parsed in 0.00 sec (211.33 KiB/sec)
admin@ncs(config)# load merge policies/DNS_Server_Policy.xml
Loading.
2.39 KiB parsed in 0.00 sec (753.97 KiB/sec)
admin@ncs(config)# load merge policies/Telnet_is_Disabled.xml
Loading.
2.00 KiB parsed in 0.01 sec (136.80 KiB/sec)
admin@ncs(config)# load merge policies/Proactively_Enforce_Interface_Descriptions.xml
Loading.
1.04 KiB parsed in 0.00 sec (393.33 KiB/sec)
admin@ncs(config)# commit
Commit complete.

```

**HINT:** this can be automated by running ./install_policies.sh


## Verifying policies

### Single API

All of the CLI steps outlined below can also be executed in Postman click the button to get started

[![Run in Postman](https://run.pstmn.io/button.svg)](https://app.getpostman.com/run-collection/f9d64ed367d243419f95#?env%5Blocal%20NSO%5D=W3siZW5hYmxlZCI6dHJ1ZSwia2V5IjoidXNlcm5hbWUiLCJ2YWx1ZSI6ImFkbWluIiwidHlwZSI6InRleHQifSx7ImVuYWJsZWQiOnRydWUsImtleSI6InBhc3N3b3JkIiwidmFsdWUiOiJhZG1pbiIsInR5cGUiOiJ0ZXh0In0seyJlbmFibGVkIjp0cnVlLCJrZXkiOiJzZXJ2ZXIiLCJ2YWx1ZSI6ImxvY2FsaG9zdCIsInR5cGUiOiJ0ZXh0In0seyJlbmFibGVkIjp0cnVlLCJrZXkiOiJwb3J0IiwidmFsdWUiOiI4MDgwIiwidHlwZSI6InRleHQifV0=)

Also, make sure to checkout the [API docs](https://documenter.getpostman.com/view/23187/RWgqWK3D) for the same workflow and to generate your own code to consume these services.

### Single CLI

The following steps are used to test the policies via CLI workflow

#### Sync From devices
```
admin@ncs# devices sync-from
sync-result {
    device ios1
    result true
}
sync-result {
    device nx1
    result true
}
```

#### Run Compliance Check

```
admin@ncs# compliance reports report DNS_Servers_Configured run
id 1
compliance-status violations
info Checking 2 devices and no services
location http://localhost:8080/compliance-reports/report_1_admin_1_2018-10-12T0:43:57:0.xml
```

#### Apply Device Template (with validation)
```
admin@ncs(config)# devices device-group all-devices apply-template template-name Standard_DNS_Servers
apply-template-result {
    device ios1
    result ok
}
apply-template-result {
    device nx1
    result ok
}
admin@ncs(config)# commit dry-run outformat cli   
The following warnings were generated:
  Interface 101/1/1 on nx1 needs description
Proceed? [yes,no] yes
cli {
    local-node {
        data  devices {
                  device ios1 {
                      config {
                          ios:ip {
                              name-server {
             +                    # first
             +                    name-server 8.8.8.8;
                              }
                          }
                      }
                  }
                  device nx1 {
                      config {
                          nx:ip {
                              name-server {
             +                    servers 8.8.8.8;
                              }
                          }
                      }
                  }
              }
    }
}
admin@ncs(config)#
admin@ncs(config)#

```

#### Commit Changes

Notice how other policies are being checked as well...

```
admin@ncs(config)# commit
The following warnings were generated:
  Interface 101/1/1 on nx1 needs description
Proceed? [yes,no] yes
Commit complete.

```

#### Re-Run Compliance Check

Now that our remediating templates have been applied, the compliance check should
pass with `no-violation`

```
admin@ncs# compliance reports report DNS_Servers_Configured run
id 2
compliance-status no-violation
info Checking 2 devices and no services
location http://localhost:8080/compliance-reports/report_2_admin_0_2018-10-15T10:45:58:0.xml
```

#### Get your rollback on...

Since we have the benefits of models and transactions, NSO automatically generates a rollback patch.

These will be stored as `logs/rollback<trans_number>` files that contain JSON data which can be applied via UI, CLI, or API to
undo the change..

Here's an example of it's contents...

**NOTE:** make sure you exit out of `ncs_cli` and execute from terminal prompt.

`cat logs/rollback10008`
```
# Created by: admin
# Date: 2018-10-12 00:49:00
# Via: cli
# Type: delta
# Label:
# Comment:
# No: 10008

ncs:devices {
    ncs:device ios1 {
        ncs:config {
            ios:ip {
                ios:name-server {
                    delete:
                    ios:name-server-list 8.8.8.8;
                }
            }
        }
    }
    ncs:device nx1 {
        ncs:config {
            nx:ip {
                nx:name-server {
                    delete:
                    nx:servers 8.8.8.8;
                }
             }
         }
     }
 }
```

#### Cleanup

To reset your environment, a `clean` target is defined in the [Makefile](./Makefile)

From your terminal prompt you can execute `make clean` to reset your environment
