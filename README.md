# NSO Sample Policies

This repository contains various samples on how NSO can be used for configuration governance and policy compliance

More docs coming soon...

# Requirements

* NSO 4.7 - [Free Evaluation](https://developer.cisco.com/site/nso/)


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

## Adding Policies to NSO

The scripts located in [./policies]  are files which describe the intended policy, and associated compliance/enforcement. These files are written in XML
and can be used as payloads against, the NSO REST API, configured via CLI.

In a pinch, you can also just `load merge` them from ncs_cli

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

```
