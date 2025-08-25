To loop the example with defaults:

```sh
/scripts/animate/run.lua /scripts/animate/+hello-world/ 
```

To play only once slowly:

```sh
/scripts/animate/run.lua /scripts/animate/+hello-world/ 2 0
```

or...

```sh
/scripts/animate/run.lua /scripts/animate/+hello-world/ 2 false
```

Add it to startup.lua maybe?

```sh
shell.run("/scripts/animate/run.lua /scripts/animate/+hello-world/ 12 false")
```