# PHP-LARAVEL Container
php-fpm + nginx container for containerizing the website

# Configuration
* Environment configuration only unless `.env` and other config (e.g. `auth.json`) provided in bind mount to `/home/container/app`
* `/home/container/app` is the workdir
* All modifiable configuration should ONLY be modified in `/home/container/config`, configuration in other directories may be overwritten due to usage of `envsubst` for substitution of sensitive/configurable data
* SSL configuration requires modification of `nginx.conf` to enable it

# Example local usage:
## Lazy (and insecure) for a private repo
```
docker run \
    --rm \
    -it \
    -p 80:80 \
    -e "SETUPCMD=rm -rf /home/container/app && cp -r /root/.ssh-host ~/.ssh && chmod 600 ~/.ssh/id_rsa && chmod 644 ~/.ssh/id_rsa.pub && git clone git@github.com:example/LaravelWebsite.git /home/container/app" \
    --env-file=./your-env-file-here.env \
    -v "/home/your-home-directory/.ssh:/root/.ssh-host" \
    php-laravel
```
For the above, ensure:
* Your ssh key in your home directory if the repo you want to run is private
* Your your-env-file-here.env is the .env you would like to use
* If your website uses Laravel Nova - add THESE to the END of your your-env-file-here.env:
  * `NOVA_USERNAME`=<nova username>
  * `NOVA_PASSWORD`=<nova password>
* Your port 80 isn't in use by another container
* Remember `localhost` in the container is not the same as on your host (you might have to use your local network address)
## Public repo
```
docker run \
    --rm \
    -it \
    -p 80:80 \
    -e "SETUPCMD=rm -rf /home/container/app && git clone git@github.com:example/LaravelWebsite.git /home/container/app" \
    --env-file=./your-env-file-here.env \
    php-laravel
```