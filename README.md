# LaTeX Paper Template

This repository is a reusable starting point for a single LaTeX/Overleaf
project. It includes one devcontainer, VS Code build recipes, helper scripts,
and a manuscript layout that supports shared assets across multiple journal
versions.

## Layout

```text
latex-template/
├── .devcontainer/
├── .vscode/
├── scripts/
│   ├── build_latex.sh
│   ├── build_docker_image.sh
│   ├── clean_latex.sh
│   ├── setup_overleaf_project.sh
│   └── setup_git_credentials.sh
├── paper/
│   ├── bibliography/
│   │   └── references.bib
│   ├── figures/
│   │   └── example_figure.tex
│   └── default/
│       └── main.tex
├── Dockerfile
├── requirements.txt
└── .env_template
```

Use `paper/default/` for an initial manuscript. For a journal submission,
duplicate or replace it with a format-specific directory while retaining
shared assets:

```text
paper/
├── bibliography/
├── figures/
├── ieee_taes/
│   └── main.tex
└── aiaa_jsr/
    └── main.tex
```

## VS Code Workflow

Build the named development image once on the host:

```bash
./scripts/build_docker_image.sh
```

This creates `mylatex-template:dev`, which `.devcontainer/devcontainer.json`
uses directly instead of asking VS Code to generate an image name.

Then open the repository in VS Code and reopen it in the devcontainer. The
LaTeX Workshop recipes in `.vscode/settings.json` operate on the active `.tex`
document:

- `latexmk (script)` builds into an `out/` directory beside the document.
- `clean build` removes intermediate build files while retaining the PDF.

Build the example directly from a terminal with:

```bash
./scripts/build_latex.sh paper/default/main.tex
./scripts/clean_latex.sh paper/default/main.tex
```

The build script searches `paper/bibliography/` and `paper/figures/`, allowing
all journal-specific manuscript folders to use the same assets.

The active manuscript intentionally lives under `paper/<variant>/main.tex`.
If an individual Overleaf project requires different placement, adjust that
project after initialization.

## Importing An Overleaf Project

Clone this template from GitHub into the local directory for a new paper, then
run:

```bash
./scripts/setup_overleaf_project.sh
```

The setup script prompts for the Overleaf Git URL, username, and
password/token. After confirmation, it:

- clones the Overleaf project into a temporary directory;
- creates the ignored local `.env` used for later Git authentication inside
  the devcontainer;
- replaces the template checkout's Git metadata with the cloned Overleaf
  project's metadata, discarding the template's GitHub history locally;
- retains the Overleaf Git repository as the normal `origin` remote;
- replaces `paper/default/` with the files currently in the Overleaf project.

The imported manuscript remains uncommitted so it can be reorganized manually.
Open the initialized project in the devcontainer, run
`./scripts/setup_git_credentials.sh`, and then adjust, commit, and publish the
manuscript:

```bash
./scripts/setup_git_credentials.sh
git add -A
git commit -m "Import Overleaf manuscript into template layout"
git push origin HEAD:master
```

The script configures `core.fileMode=false` for the project because Overleaf
does not preserve executable script permissions.

## Git Credentials

`setup_overleaf_project.sh` runs on the host before the devcontainer is
opened. It uses the entered credentials for its temporary clone and writes
them to the ignored `.env`, but does not modify host-global Git credentials.

Once inside the devcontainer, configure credentials there:

```bash
./scripts/setup_git_credentials.sh
```

For a project not initialized by the import script, first copy `.env_template`
to `.env` and set `GIT_REMOTE_URL`, `GIT_USERNAME`, and `GIT_PASSWORD`.

The `.env` file is ignored by Git and must not be committed.

## Container

The Docker image is built from `Dockerfile` by
`scripts/build_docker_image.sh`. The devcontainer uses that locally named image
and includes LaTeX tooling, Codex dependencies, and the common data-analysis
packages listed in `requirements.txt` (NumPy, pandas, Matplotlib, SciPy,
seaborn, openpyxl, and SciencePlots). Re-run the image build script after
changing those dependencies.

The devcontainer `name` value is only a VS Code display label; multiple paper
projects can use the same value without a Docker container-name conflict.

The configuration mounts the host Codex authentication file at
`${HOME}/.codex/auth.json`; adjust that mount on machines that do not use this
location.
