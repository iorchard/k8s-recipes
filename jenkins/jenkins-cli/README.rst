jenkins-cli
============

Build jenkins-cli image.::

    $ docker build -t jenkins-cli .
    

Go to jenkins and create your api token.

#. Log into Jenkins.
#. Click your name at the upper-right corner.
#. Click Configure at the left menu.
#. Click "Add new Token".
#. Copy your token.

Create env file.::

   $ vi myenv
   JENKINS_URL=<jenkins_url>
   JENKINS_USER_ID=<jenkins_user_id>
   JENKINS_API_TOKEN=<your_api_token>

Create alias and source it.::

   $ vi ~/.bash_aliases
   alias	jcli="docker run --env-file=${HOME}/.jenkins.env jenkins-cli"

   $ source ~/.bashrc

Run jenkins-cli.::

   $ jcli help
   $ jcli version
   2.176.2

