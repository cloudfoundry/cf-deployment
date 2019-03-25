# Promoting/Deprecating ops files

Quick note on "Experimental" Ops-file: Expirmental Ops-file represent configurations that we expect to promote to blessed configuration eventually, meaning that, once the configurations have been sufficiently validated, they will either become default (inlined into the base manifest), or GA'd as an optional feature (promoted from experimental to operations directory). The following workflow illustrates the sequence of events to promote an experimental Ops-file.

*_PR process is excluded for brevity._*

## Promoting an experimental Ops-file - Inline Option

```
+------------------------+             +-------------------------+              +----------------------------+
|                        |             |  Inline changes in      |              | Empty content from         |
| Experimental feature   | --------->  |  base manifest file or  |  --------->  | the experimental ops file  |
| is validated.          |             |  in Ops-files under     |              | & add a deprecation notice |
|                        |             |  operations folder.     |              | to readme.                 |
+------------------------+             +-------------------------+              +----------------------------+
                                                                                            |
                                                                                            |
                                                    +---------------------------------------+
                                                    |
                                                    |
                                                    |
                                                    v
                                        +------------------------+
                                        |                        |
                                        |   RelInt cuts a minor  |
                                        |   release.             |
                                        |         (•‿•)          |
                                        +------------------------+
```

## Promoting an experimental ops file - Symlink Option

_Please do not remove the file or it's content._
```
+------------------------+             +-------------------------+              +----------------------------+
|                        |             |  Move the experimental  |              | Add symlink file to the    |
| Experimental feature   | --------->  |  Ops-file from          |  --------->  | promoted Ops-file in the   |
| is validated.          |             |  experimental folder to |              | operations folder to       |
|                        |             |  the operations folder. |              | the experimental folder.   |
+------------------------+             +-------------------------+              +----------------------------+
                                                                                            |
                                                                                            |
                                                    +---------------------------------------+
                                                    |
                                                    |
                                                    |
                                                    v
                                        +------------------------+
                                        |                        |
                                        |   RelInt cuts a minor  |
                                        |   release.             |
                                        |         (•‿•)          |
                                        +------------------------+
```


> It is critical that you do not remove the experimental ops file during your promotion.

Operators might be still using the experimental ops file as part of their deployment and removing the file will break their automated environments. Once the deprecation notice is posted, the support for experimental ops file will be marked for removal on the next major cf-deployment release.

## Deprecating an experimental ops file

_Please do not remove the file._

```
+------------------------+             +-----------------------------------+
|                        |             |  Replace contents of the Ops-file |
| Experimental feature   | --------->  |  with a deprecation notice as a   |
| is no longer needed.   |             |  comment. Add a deprecation notice|
|                        |             |  for the ops file entry in readme |
+------------------------+             +-----------------------------------+
                                                    |
                                                    |
                                                    |
                                                    |
                                                    v
                                        +------------------------+
                                        |                        |
                                        |   RelInt cuts a minor  |
                                        |   release.             |
                                        |         (•‿•)          |
                                        +------------------------+
```

# RelInt removes all deprecated versions of Ops-files
```
+------------------------+             +---------------------------+
|                        |             |  RelInt removes the       |
| A major                | --------->  |  deprecated experimental  |
| cf-deployment release  |             |  ops file and/or symlinks |
| event happens.         |             |  from experimental folder.|
+------------------------+             +---------------------------+
                                                    |
                                                    |
                                                    |
                                                    |
                                                    v
                                        +------------------------+
                                        |                        |
                                        |   RelInt cuts a major  |
                                        |   release.             |
                                        |        ٩( ᐛ )و         |
                                        +------------------------+
```
