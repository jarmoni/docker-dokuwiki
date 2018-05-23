# docker-dokuwiki
## Motivation
[Dokuwiki](https://www.dokuwiki.org/dokuwiki) is quite useful in small (personal) environments. But migration of existing installations sometimes become painfull:
- OS-Update/-Change
- Data-Migration
- ...
## Goals
- Personal use only (kind of 'desktop-app-replacement')
- Lightweight Docker-based Dokuwiki-container which runs on all machines (Desktop, Notebook, 2nd Notebook,....)
- Content is kept in GIT by use of [gitbacked](https://www.dokuwiki.org/plugin:gitbacked)
- Short-term live-cycle:
  - No content on file-system of local machine
  - No migration - just rebuild container
- Should work "from scratch"
  - No manual installation steps
  - (Re-) build container and use Dokuwiki immediately

## Building-blocks
- Alpine-Linux
- Nginx
- PHP
- Supervisor
- Dokuwiki

## Run container
```bash
#docker run -d --name dokuwiki -p <LOCAL_PORT>:80 -e SSH_KEY="$(cat <SSH_KEY>)" -e DOKUWIKI_USERDATA_REPOS=<GIT_REPOS> jarmini/docker-dokuwiki:latest
# e.g.
docker run -d --name dokuwiki -p 1113:80 -e SSH_KEY="$(cat ~/.ssh/id_rsa_dokuwiki)" -e DOKUWIKI_USERDATA_REPOS="git@bitbucket.org:johndoe/my_repos.git" jarmoni/docker-dokuwiki:latest
```

## Resources
I'm not the PHP-guy, so I needed some inspiration....
- <https://www.nginx.com/resources/wiki/start/topics/recipes/dokuwiki/>
- <https://github.com/nginxinc/docker-nginx>
- <https://github.com/istepanov/docker-dokuwiki>
- <https://github.com/crazy-max/docker-dokuwiki>