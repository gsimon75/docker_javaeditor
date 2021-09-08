## Overview

[JavaEditor ](http://javaeditor.org) is a handy and nice IDE for learning Java, but it's available for Windows only.

Of course it runs fine with [Wine](http://winehq.org), but ... setting up Wine with all its dependencies and keeping it up-to-date can be painful on some distros.
So here's a plain Ubuntu container with Wine and JavaEditor and all the deps, without polluting your localhost. (And also my favorite fonts [ProggyTiny and ProggyClean](http://proggyfonts.net) )

Running GUI programs in a container is still not trivial, but I needed this IDE only for local use, so I've used a shameful hack: as X11 programs by default communicate with the display via `/tmp/.X11-unix/...`, I've just bind-mounted`/tmp` into the container. (I know, safety and security and all that. It's indeed a hack, so don't use it if you can't tolerate it.)

Moreover, you probably want to keep your sources and the builds persistently on your host, so we also need to bind-mount a host folder into `/root` in the container, because Wine will show that as "My Documents" folder.

And yes, the container is running as root, another serious security flaw. It's not a necessity, a plain user would do as well, just then we'd have to ensure that should be writable is actually writable, etc. This is not a production grade stuff, but a localhost-only hack to get this IDE running, so if/when this starts bothering me in any way, I'll put the efforts to use a plain user.

Having said all these, the command to launch this container is:
```
xhost +
docker run --rm -it -v /tmp:/tmp -v $HOME/my_java_work_folder:/root gsimon75/javaeditor
```

If you do this frequently, it's worth to add an alias for it in your `~/.bashrc`...


### External prerequisites

* [OpenJDK](https://www.openlogic.com/openjdk-downloads)
* [JavaEditor](http://javaeditor.org/doku.php?id=en:download) installer
* Optional: [ProggyTiny and ProggyClean](http://www.proggyfonts.net) fonts
    NOTE: For better EEU support I've added some accented glyphs (latin2)


### Build

Sorry, JavaEditor is a Windows program and need manual installation anyway, so it can't be automated. (OK, it could be, it's just not worth the effort.)

Create a `wine/` folder.

Download into `wine/`:
* [OpenJDK](https://www.openlogic.com/openjdk-downloads)
    ... and unzip it, and you may remove the .zip
* [JavaEditor](http://javaeditor.org/doku.php?id=en:download) installer

Enable X11 programs to connect from anywhere who can access your `/tmp/.X11-unix/`:
```
xhost +
```

Start a **temporary** Ubuntu container with these bind-mounts:
* `/tmp` on the host as `/tmp` in the container
* `$PWD/wine` on the host as `/wine` in the container
```
docker run --rm -it -v /tmp:/tmp -v $PWD/wine:/wine ubuntu
```

Install `wine`:
```
export DEBIAN_FRONTEND=noninteractive
export DISPLAY=:0
export WINEPREFIX=/wine
apt-get update
apt-get upgrade
apt-get install wine64
```

Set up wine:
```
wineboot -u
```

Optional: Copy the .ttf fonts into `/wine/drive_c/windows/Fonts`

Run the JavaEditor installer: `wine64-stable /wine/JavaEditor64.19.20Setup.exe`
For JDK folder choose that `c:/openjdk-8u292-b10` or similar that you extracted from the OpenJDK .zip archive. Optional: set up the fonts, too.
After that, you may remove the installer.

Terminate the container (Ctrl-D).
Now you have a Wine home folder with the JDK and JavaEditor installed in it.

Create a tarball from this Wine home (note the `sudo`, most files in it are owned by root):
```
sudo tar cjf slash_wine.tar.bz2 wine/
sudo docker build -t javaeditor:19.20.1 .
```

And now build the JavaEditor container and tag it as latest:
```
sudo docker build -t gsimon75/javaeditor:19.20.1 .
docker tag gsimon75/javaeditor:19.20.1 gsimon75/javaeditor:latest
```

Test it:
```
docker run --rm -it -v /tmp:/tmp -v $HOME/my_java_work_folder:/root gsimon75/javaeditor
```

If it seems OK, then push it to Docker Hub:
```
docker push gsimon75/javaeditor:19.20.1
docker push gsimon75/javaeditor:latest
```

