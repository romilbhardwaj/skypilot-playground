# skypilot-playground
Creates a public playground for people to play with SkyPilot

```console
sky launch -c playground playground.yaml
```

## Notes
* Make sure port 7681 is open on your remote VM!
* Make sure you have a directory named `skypilot_credentials` in your home directory containing the appropriate credentials (`aws` and `.config` dirs).
* This sets up a very basic username password based auth. Use with caution!
