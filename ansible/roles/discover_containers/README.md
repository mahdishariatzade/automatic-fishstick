
Role Name
=========

Discover Docker Containers

Description
-----------

This Ansible role lists all Docker containers on the target host, extracts their names and labels, applies optional filters based on container names and labels (which can be single strings or lists), stores the result in the 'filtered_containers' variable, and prints it using debug.

Requirements
------------

- Docker must be installed and running on the target host.
- The role uses the 'shell' module to run 'docker ps', so no additional Python packages are required beyond Ansible's defaults.

Role Variables
--------------

name_filter:
  - description: Optional filter for container names. Can be a string (regex pattern) or a list of strings (joined with '|' for OR matching).
  - type: string or list
  - default: none

label_filter:
  - description: Optional filter for container labels. Can be a string or a list of strings. Containers with at least one matching label are kept.
  - type: string or list
  - default: none

filtered_containers:
  - description: The final list of filtered containers (output of the role). This is a list of dictionaries with 'name' and 'labels' keys.
  - type: list

Dependencies
------------

None.

Example Playbook
----------------
```
- hosts: localhost
  roles:
    - role: discover_containers
      vars:
        name_filter: ['web', 'app']
        label_filter: ['prod', 'test']
```
License
-------

BSD

Author Information
------------------

This role was created to assist in discovering and filtering Docker containers for automation tasks.
