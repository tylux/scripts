#An ansible script to add all non system users to a group, useful for adding all devs on a box to www-data or apache2 group, tested on Ubuntu

# edit group-add.yml user and group vars with your favorite editor then run like so
```
ansible-playbook -i 'your-ip,' group-add.yml
```
