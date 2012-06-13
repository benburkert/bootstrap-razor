#!/bin/bash

# install ruby & git
if [[ "$(which git)" == "" ]] ; then
  apt-get install -q -y  git-core
fi

if [[ "$(which ruby)" == "" ]] ; then
  apt-get install -q -y ruby rubygems
fi

# install puppet
if [[ "$(which puppet)" == "" ]] ; then
  gem install puppet --no-rdoc --no-ri
fi

# update the puppetlabs modules
modules="apt mongodb nodejs razor stdlib tftp vcsrepo"
for module in $modules ; do
  if [[ ! -d modules/$module ]] ; then
    git clone git://github.com/puppetlabs/puppetlabs-$module.git modules/$module
  else
    ( cd modules/$module ; git pull ) >/dev/null
  fi
done

# update the sudo module
if [[ ! -d modules/sudo ]] ; then
  git clone git://github.com/saz/puppet-sudo.git modules/sudo
else
  ( cd modules/sudo ; git pull ) >/dev/null
fi

# work-around for bug in puppet: http://projects.puppetlabs.com/issues/9862
if ! ( grep -q puppet /etc/group ) ; then
  groupadd puppet
fi

# run puppet
puppet apply init.pp --modulepath=modules --verbose $@
