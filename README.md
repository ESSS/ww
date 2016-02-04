# ww - The multiple-workspace batch script

More information in the [Confluence Page](https://eden.esss.com.br/confluence/display/EDEN/Dealing+with+multiple+workspace+on+conda)

## Minimum folder structure for an environment

- env_number
    - aa_conf
        - aasimar10.conf
    - envs
    - Projects
    - tmp

Environment variables that can be previously defined (suggestion: define them as system variables)

WW_SHARED_DIR:      point to PATH of Shared used by aa. Default: D:\Shared
WW_PROJECTS_SUBDIR: subdirectory of workspace where projects are clones. Default: Projects
WW_QUIET:           if defined, ww will not print normal messages (only error ones).
WW_CREATE:          if defined, ww will create every PATH it tries to access (but not the root one)

## Usage

Just create the minimum folder structure for each workspace and then run:

```
ww <number>
```

To show detailed information about the current workspace:

```
ww
```
