#!/bin/sh
set -e
#set -x

DOKUWIKI_USERDATA_REPOS_DEST="$DOKUWIKI_DEST/repos"
DOKUWIKI_USER_REAL_NAME="John Doe"
DOKUWIKI_USER_EMAIL="john@doe.com"

if [ ! -f /.ssh/id_rsa ]
then
    [ -z "$SSH_KEY" ] && echo "SSH_KEY must be given" && exit 1
    mkdir /.ssh/ && echo "$SSH_KEY" > /.ssh/id_rsa && chown -R nobody:nobody /.ssh && chmod 600 /.ssh/*
fi

if [ ! -d "$DOKUWIKI_USERDATA_REPOS_DEST" ]
then
    [ -z "$DOKUWIKI_USERDATA_REPOS" ] && echo "DOKUWIKI_USERDATA_REPOS must be given" && exit 1
    GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /.ssh/id_rsa" git clone "$DOKUWIKI_USERDATA_REPOS" "$DOKUWIKI_USERDATA_REPOS_DEST"
    git config --system user.email "$DOKUWIKI_USER_EMAIL" && git config --system user.name "$DOKUWIKI_USER_REAL_NAME"
cat << EOF > $DOKUWIKI_DEST/conf/local.php
<?php
\$conf['title'] = 'mywiki';
\$conf['license'] = 'cc-zero';
\$conf['savedir'] = './data';
\$conf['useacl'] = 1;
\$conf['superuser'] = '@admin';
\$conf['disableactions'] = 'register';
\$conf['plugin']['gitbacked']['pushAfterCommit'] = 1;
\$conf['plugin']['gitbacked']['periodicPull'] = 1;
\$conf['plugin']['gitbacked']['periodicMinutes'] = 15;
\$conf['plugin']['gitbacked']['repoPath'] = "./repos";
\$conf['plugin']['gitbacked']['repoWorkDir'] = "./repos";
\$conf['plugin']['gitbacked']['gitPath'] = 'GIT_SSH_COMMAND=\'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /.ssh/id_rsa\' /usr/bin/git';
\$conf['plugin']['authmysql']['TablesToLock'] = array();
\$conf['datadir'] = "$DOKUWIKI_USERDATA_REPOS_DEST/pages";
\$conf['mediadir'] = "$DOKUWIKI_USERDATA_REPOS_DEST/media";
EOF
cat << EOF > $DOKUWIKI_DEST/conf/plugins.local.php
<?php
\$plugins['authad']    = 0;
\$plugins['authldap']  = 0;
\$plugins['authmysql'] = 0;
\$plugins['authpgsql'] = 0;
EOF
cat << EOF > $DOKUWIKI_DEST/conf/acl.auth.php
# acl.auth.php
# <?php exit()?>
# Don't modify the lines above
#
# Access Control Lists
*               @ALL          8
EOF
cat << EOF > $DOKUWIKI_DEST/conf/users.auth.php
# users.auth.php
# <?php exit()?>
# Don't modify the lines above
# Userfile
# Format:
# login:passwordhash:Real Name:email:groups,comma,seperated
admin:\$1\$i1GWPLBu\$lyt51MM2oZqYvGFJuThxc0:$DOKUWIKI_USER_REAL_NAME:$DOKUWIKI_USER_EMAIL:admin,user
EOF
fi

chown -R nobody "$DOKUWIKI_DEST"

su -s /bin/sh nobody -c 'php7 /dokuwiki/bin/indexer.php -c'

echo "CMD=$@"
exec "$@"
