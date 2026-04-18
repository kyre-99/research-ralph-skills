# Research Bot

A file-first research workflow for Claude Code that is a little more stubborn than chat memory, and a lot easier to resume. 🧠⚙️

Instead of hoping the next session remembers everything, this repo keeps the important state on disk: plans, implementation tasks, optimization logs, and runtime handoff files. Close the laptop, lose the context window, come back tomorrow — the workflow still knows where it was. ✨

Chinese version: [README_CN.md](README_CN.md)

## Why This Exists

Most AI workflows feel great right up until the moment the context disappears.

This repo is built around a different rule:

- persist the research state in files
- let each stage leave a clean handoff
- make every new session able to restart from the repo, not from memory

If you like Ralph-style loops, long-running experiment work, or resumable agent pipelines, this project is very much in that lane. 🚂

## What You Get

- Project skills in `.claude/skills/`
- Bootstrap script: `scripts/research-bot/init.sh`
- Implementation loop runner: `scripts/research-bot/implement.sh`
- Optimization loop runner: `scripts/research-bot/optimize.sh`
- Full-run archive helper: `scripts/research-bot/archive-run.sh`
- Implementation archive helper: `scripts/research-bot/archive-implementation.sh`
- Optimization archive helper: `scripts/research-bot/archive-optimization.sh`
- Installer for reusing the setup in another repo: `scripts/research-bot/install-skills.sh`

## Two Ways To Use It

### 1. Use it directly in this repo

If you are working inside this repository, Claude Code can use the skills in `.claude/skills/` directly. No installation ceremony required. 🎉

### 2. Install it into another repo

If you want the same workflow somewhere else:

```bash
./scripts/research-bot/install-skills.sh /path/to/target-project
```

That copies both:

- skills into `.claude/skills/`
- helper scripts into `scripts/research-bot/`

Result:

```text
/path/to/target-project/.claude/skills/
/path/to/target-project/scripts/research-bot/
```

If you are already inside the target repo:

```bash
cd /path/to/target-project
/path/to/reasearch-bot/scripts/research-bot/install-skills.sh
```

## Main Usage

```text
New project:
  init.sh
  -> /research-plan
  -> /research-implement
  -> implement.sh
  -> /research-optimize
  -> optimize.sh

Resume an existing project:
  /research-pipeline

Start a materially new direction:
  archive current run
  -> /research-plan
```

Most of the time, you only need these three entry patterns:

### 1. Start a new project

```bash
./scripts/research-bot/init.sh
```

```text
/research-plan "your research topic"
/research-implement "build the first runnable baseline"
./scripts/research-bot/implement.sh 10
/research-optimize "improve [metric] under [constraints]"
./scripts/research-bot/optimize.sh 10
```

### 2. Resume in a fresh session

```text
/research-pipeline continue the current research run
```

### 3. Start a new direction

```bash
./scripts/research-bot/archive-run.sh my-topic
```

```text
/research-plan "the new research direction"
```

## What `research-pipeline` Actually Does

`/research-pipeline` is the resume-and-route entrypoint for a fresh session.

Use it when you do not want to manually decide which skill should run next.

It will:

- read `runtime/RESEARCH_STATE.json` first
- inspect the key files listed there
- figure out whether the project should continue planning, implementation, optimization, or runtime repair
- route the workflow to the right stage instead of restarting from scratch

In plain English: if you open a brand new session and ask “please continue the current work,” `research-pipeline` is the right first move. 🧭

Recommended prompt:

```text
/research-pipeline continue the current research run
```

ℹ️ If `runtime/RESEARCH_STATE.json` is current, this gives the new session a reliable file-based handoff instead of depending on chat memory.

## Minimal File Model

The whole system is intentionally small. The point is not to save everything. The point is to save the few things the next round truly needs.

### Planning

- `research/plan.md`
- `research/plan-history.md`

### Implementation

- `research/implementation/tasks.json`
- `research/implementation/progress.md`
- `research/implementation/CLAUDE.md`

### Optimization

- `optimization/prd.json`
- `optimization/progress.md`
- `optimization/CLAUDE.md`

### Runtime

- `runtime/RESEARCH_STATE.json`
- `runtime/MANIFEST.md`

### Archives

- `archive/<timestamp>-<slug>/`
- `archive/implementation/<timestamp>-<slug>/`
- `archive/optimization/<timestamp>-<slug>/`

## The Most Important File

`runtime/RESEARCH_STATE.json` is the lightweight entrypoint for a fresh AI round.

It should summarize only:

- active phase
- current goal
- current status
- next step
- key files to read next

Treat it like a snapshot, not a diary. Overwrite the latest state summary instead of piling history into it. Sharp, current, useful. 🪄

## Quick Notes

- `/research-plan` defines the research direction
- `/research-implement` prepares implementation artifacts
- `./scripts/research-bot/implement.sh 10` runs repeated implementation rounds
- `/research-optimize` prepares optimization artifacts
- `./scripts/research-bot/optimize.sh 10` runs repeated optimization rounds
- `/research-pipeline` is the best way to resume in a new session

## Archiving Without Drama

When the direction changes enough that the new run is no longer comparable to the current one, archive first.

Archive the whole run:

```bash
./scripts/research-bot/archive-run.sh my-topic
```

Archive only the implementation state:

```bash
./scripts/research-bot/archive-implementation.sh implementation-reset
```

Archive only the optimization state:

```bash
./scripts/research-bot/archive-optimization.sh optimization-reset
```

This keeps old work recoverable without muddying the current loop. 📦

## Good Habits

- Keep `RESEARCH_STATE.json` short and current
- Treat files as the memory surface, not the chat transcript
- Let planning define direction before implementation expands scope
- Let implementation make things runnable before optimization starts tuning
- Archive when the goal changes materially instead of pretending two different runs are the same thing

## Who This Is For

This repo is a nice fit if you want:

- a durable AI-assisted research workflow
- a project that survives context resets
- repeated implement/evaluate/improve loops
- a minimal but opinionated structure instead of a giant framework

If that sounds like your kind of chaos, welcome. 🔬
