#!/bin/bash
ncs_load -l -m policies/Device_Groups.xml
ncs_load -l -m policies/DNS_Server_Policy.xml
ncs_load -l -m policies/Proactively_Enforce_Interface_Descriptions.xml
ncs_load -l -m policies/Telnet_is_Disabled.xml
