#!/usr/bin/bash
# This setup script will start out with just sfdx commands
# which should be executable on any terminal
# Should future developments include shell specific commands,
# attempts should be made to isolate common scripts into their own files

sfdx force:org:create -s -a sfdc-depl-mgr -f config/project-scratch-def.json
sfdx force:source:push
sfdx force:user:permset:assign -n SalesforceDeploymentManager_Admin