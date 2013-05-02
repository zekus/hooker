Hooker: yet another GitHub Puppet Hook
------------------

To setup the hook, install passenger and setup a virtual host for the application then drop this in.
To make apache works, you need to add the github ssh key in /var/www/.ssh following the github help pages.

To debug the application start it with
```bash
rackup config.ru
```
and you will be able to access the application via the port 9292
