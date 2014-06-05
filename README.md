[![Build Status](https://travis-ci.org/zekus/hooker.svg)](https://travis-ci.org/zekus/hooker)

Hooker: a GitHub Puppet Hook
======================================

This hooker is a rack application that will automatically create puppet environments based on the branches present in your puppet repository when receive an hook from github.

To be useful, you need to setup your puppet master to use environments as described in the official documentation http://docs.puppetlabs.com/guides/environment.html

Setup using Passenger and Apache
--------------------------------
To setup the hook, install passenger and create a virtual host for the application like the following:
```apache
Listen 5555

<VirtualHost *:5555>
        ServerName puppet.example.com
        ServerAdmin devops@example.com

        PassengerLogLevel 3
        PassengerHighPerformance on
        
        SetEnv PUPPET_ENVIRONMENTS_ROOT /etc/puppet/environments
        SetEnv PUPPET_LOCAL_REPO /etc/puppet/repo
        SetEnv PUPPET_GIT_REPO git@github.com:example/puppet.git

        DocumentRoot /var/www/hooker/public/
        <Directory /var/www/hooker/public/>
                Options None
                Order allow,deny
                allow from all
        </Directory>

        CustomLog ${APACHE_LOG_DIR}/hooker.access.log combined
        ErrorLog ${APACHE_LOG_DIR}/hooker.error.log

        LogLevel warn
        ServerSignature On
</VirtualHost>
```
then drop the code in /var/www/hooker/public/.

To make the script work and checkout the new code from GitHub, you need to add the ssh key of the user that have access to the GitHub puppet repository in /var/www/.ssh .

### debugging ###

To debug the application start it with
```bash
rackup config.ru
```
and you will be able to access the application via the port 9292

LICENSE
-------

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
