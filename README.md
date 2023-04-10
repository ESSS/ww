# ww - The multiple-workspace batch script

## Requirements

You must have a conda installation before continuing.
See [Conda Intallation](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) 


## Installing

Run the following command in your conda base environment (that is, you must 'deactivate' from any current environment different from 'base')

```
conda install ww
```

### Change default workspaces location

`ww` will create new workspaces on a default location, but that location must exist. If one does not, you can either create it or tell `ww` you want it to create workspaces on a different (and existent) location.

#### Windows

The default location for workspace creation is the root of the volume `W:`. 
To change default workspace location you need to override the environment variable `WW_DEFAULT_VOLUMES`

```
setx WW_DEFAULT_VOLUMES <VOLUME>
set WW_DEFAULT_VOLUMES=<VOLUME>
```

The `setx` command will persist the change between sessions while the `set` command will make the change for the current session.

#### Linux

On linux the default location for workspace creation is the folder at `~/w`. 
To change default workspace location you need to override the environment variable `WW_DEFAULT_PATH`

```
export WW_DEFAULT_PATH=<path>
```


## Folder structure of a workspace

- ```workspace_name/``` (Example: 1/)
    - ```envs/```
    - ```Projects/```
    - ```tmp/```

envs/ is used by conda to create local environment  
tmp/ dir will override the common temp dir (%TMP% and %TEMP% global environment variables), so watch out for that (It shouldn't be a big deal).  
Projects/ dir will contain your projects later.


## Configuration

Environment variables that can be previously defined (Suggestion: Define them as system variables)  
```WW_SHARED_DIR```:      point to PATH of Shared used by aa. Default: D:\Shared  
```WW_PROJECTS_SUBDIR```: subdirectory of workspace where projects are clones. Default: Projects  
```WW_QUIET```:           if defined, ww will not print normal messages (only error ones).  
```WW_CREATE```:          if defined, ww will create every PATH it tries to access (but not the root one)


## Usage

### Create workspace

To create a workspace run:

```
ww -c <name>
```

### Activate workspace

Activating a workspace will change your current location to `<workspace_default_location>/<workspace_name>/Projects` folder

#### Windows
On `Windows` just run:

```
ww <workspace_name>
```

#### Linux

On `Linux` you need to `source` the workspace. Just run:

```
source ww <workspace_name>
```

##### Activate current

It is also possible to activate a workspace from a subdir of a workspace root. If the cwd is at <workspace_name>/Projects/myproject for example, just run:

```
source ww .
```

The `<workspace_name>` will be activated without navigating to the workspace root folder. The cwd will still be at `<workspace_name>/Projects/myproject`.

Note: This is a Linux-Only feature. 


### Get active workspace information 

To show detailed information about the current workspace:

```
ww
```
