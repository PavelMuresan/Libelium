# README

**Attention**

This project uses custom sensor types added to the Waspmote Frames.

In order for it to compile (and work correctly) you need to replace your `WaspFrameContstantsv15.h` file with the one in the `lib-changes` folder.

## Where to find the `WaspFrameContstantsv15.h` file?

### Windows

On Windows, the file can be found relative to your Waspmote IDE installation folder at:
```
libraries/Frame/WaspmoteFrameConstantsv15.h
```

### MacOS

If Waspmote IDE is installed on the default (`Applications`) folder, the file to edit can be found at:

```
/Applications/Waspmote.app/Contents/Java/libraries/Frame/WaspFrameConstantsv15.h
```

## Other OS

In any operating system, it can be a good idea to search for the file by its name:

```
find / -name "WaspFrameConstantsv15.h"
```
