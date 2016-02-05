# ww - The multiple-workspace batch script

## Requirements

You must have configured a Miniconda installation before continuing.
More information in the [Confluence Page](https://eden.esss.com.br/confluence/display/EDEN/EDEn+Quickstart).  
All envs will be created in C:/ or D:/. Each env will be put on a directory with its name. Env
names are usually numbers starting from 0.


## Minimum folder structure for an environment

- ```env_number/``` (Example: 1/)
    - ```aa_conf/```
        - ```aasimar10.conf```
    - ```envs/```
    - ```Projects/```
    - ```tmp/```

aa_conf/ contains aasimar10.conf file, while we still have to configurate aasimar...  
envs/ is used by conda.  
tmp/ dir will override the common temp dir (%TMP% and %TEMP% global environment variables), so watch out for that (It shouldn't be a big deal).  
Projects/ dir will contain your projects later.


## Configuration

Environment variables that can be previously defined (Suggestion: Define them as system variables)  
```WW_SHARED_DIR```:      point to PATH of Shared used by aa. Default: D:\Shared  
```WW_PROJECTS_SUBDIR```: subdirectory of workspace where projects are clones. Default: Projects  
```WW_QUIET```:           if defined, ww will not print normal messages (only error ones).  
```WW_CREATE```:          if defined, ww will create every PATH it tries to access (but not the root one)


## Usage

Just create the minimum folder structure for each workspace and then run:

```
ww <number>
```

To show detailed information about the current workspace:

```
ww
```
