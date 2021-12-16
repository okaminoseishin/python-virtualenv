# python-virtualenv
Automatic Python .venv activation in current project

When current text editor changes, package searches for *.venv/bin/activate* file, sources it and modifies PATH for the Atom process.

Currently only *.venv* is supported, since it's most widely used name for in-project virtualenv and many tools use it, such as [Poetry](https://python-poetry.org).

You can not deactivate virtualenv, but please open an issue if this is an essential feature.

You can see which project's virtualenv is currently active in the status bar at the bottom.

> **NOTE**: There are one caveat that you can notice: there may be virtualenv and editor mismatch on Atom startup if files from different projects was opened at editor shutdown.
> 
> This is because there are packages, such as [ide-python](https://atom.io/packages/ide-python), that execute their logic for each opened editor and require virtualenv for each of them in order to spawn matching [python-language-server](https://github.com/palantir/python-language-server), but lack the discovery. For example, if you don't have **python-language-server** installed globally (only within project's *.venv*), this *.venv* must be activated when **ide-python** attempts to spawn it. And if I ensure that current project is processed last by this package, **ide-python** will use it's **python-language-server** (if it's installed) for any other python files from any project that currently have text editor opened.
> 
> AFAIK opened editors processing order is undefined, so I can not be sure that *.venv* used by **ide-python** right now and project for one particular opened file match. Only solution is on **ide-python** side - implement *.venv* discovery on their own.
