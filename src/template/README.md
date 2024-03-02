<h1 align="center"><img width=240 alt="Logo" src="https://raw.githubusercontent.com/Nurdoidz/AnnwnUnchained/master/img/square-logo.png"/><br>Annwn Unchained</h1>

Annwn Unchained is a carefully-crafted Minecraft modpack for [CurseForge](https://www.curseforge.com/) in the theme of steampunk and medieval, in a pre-industrial era.

## Mod List

<!-- MODLIST -->

## Building

The following are requirements for building the project:

- [PowerShell](https://github.com/PowerShell/PowerShell) v7+, available as `pwsh` in `PATH` or as the shell for running the scripts in this project.
- [7-zip](https://sourceforge.net/projects/sevenzip/files/7-Zip/) v23+, available as `7z` in `PATH`.
- [jq](https://github.com/jqlang/jq) v1.7+, available as `jq` in `PATH`.
- [ripgrep](https://github.com/BurntSushi/ripgrep) v14+, available as `rg` in `PATH`.

To build the project, first clone the project to a local directory. Then, navigate to the cloned project directory in a shell and run the following command:

```shell
pwsh -ExecutionPolicy Bypass -NoProfile -File ./build.ps1
```

Alternatively, launch PowerShell, navigate to the cloned project directory, and run the following command:

```powershell
. .\build.ps1 -ExecutionPolicy Bypass -NoProfile
```

The generated artifacts will be available in `build/artifacts/` and can be imported directly into the CurseForge launcher.
