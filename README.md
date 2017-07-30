## Usage

#### Login Details

You won't need them right away, but I'll put them at the top since if you get 
it running it's probably why you're here :-)

```
username: admin  
password: admin
```

You can change the password in the `civibuild` command in the Dockerfile.

#### Building

Clone this repo locally using

```bash
git clone git@github.com:mickadoo/civicrm-docker.git
```

Then from inside the cloned directory build the image:

```bash
docker build -t civicrm-test .
```

#### Running

Run the container with:

```bash
docker run -p 8000:8000 civicrm-test
```

You should be able to see the site at http://localhost:8000

#### Using Your Own Code

If you would like to use your local copy of the CiviCRM core code 
for development instead run (from your local civicrm-core directory)

```bash
docker run -v $PWD:/var/www/civicrm -p 8000:8000 civicrm-test
```

The entrypoint script will detect that something is mounted at 
`/var/www/civicrm` and replace the CiviCRM core code with this.

## Extensions

#### Using Local Extensions

If you want to use certain local extensions then you can mount them to
`/var/www/extensions` in the contain. The entrypoint script will find and
auto-enable any extensions in this directory.

## Testing

#### Running The Tests

If you have a container running you can use docker exec to get a 
shell in it and run tests as normal.

You can also run the tests in a designated container with:

```bash
docker run --entrypoint=civitest civicrm-test
```

#### Testing Your Own Code

If you want to test your local CiviCRM code you'll need to mount
it in `/opt/buildkit/builds/test-build/sites/all/modules/civicrm`. 
In order to use your local code you'll need to run some setup, such
as running composer, npm and bower. This is handled automatically 
when you run the command from "Using Your Own Code" above. You can 
also check the `entrypoint.sh` file in this repo to see what 
happens (hint: it's mostly `bin/setup.sh` in CiviCRM core that 
does the work).

#### Using civitest

The `civitest` command is just a thin wrapper for `phpunit4`. 
It accepts parameters which are passed straight on to `phpunit4`,
 so you can specify specific tests just as you would if calling it
directly. It just makes sure that `mysql` is running before the tests
start.

#### From PHPStorm

It is possible to run the tests from within PHPStorm but I
haven't found a way to start MySQL in the container. The PHPStorm
command will bypass the entrypoint and so the tests will fail because
MySQL isn't running. A hacky way to fix this is add 
`exec('service mysql start)` to the bootstrap file, or you could 
ignore the actual PHPUnit integration and just run a the civitest
command, but it would definitely be nicer to have the extra functionality
that the offered by PHPStorm for PHPUnit.
