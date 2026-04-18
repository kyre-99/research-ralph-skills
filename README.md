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

## The Flow At A Glance

```text
init.sh
  -> /research-plan
  -> /research-implement
  -> implement.sh
  -> /research-optimize
  -> optimize.sh
```

After the initial setup, most ongoing iteration should happen in the optimization loop. Think of planning as choosing the mountain, implementation as building the gear, and optimization as climbing it without falling into a ravine. 🧗

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

## Step By Step

### 1. Initialize the workspace

```bash
./scripts/research-bot/init.sh
```

This creates the minimal `research/`, `optimization/`, and `runtime/` structure if it does not already exist.

### 2. Create or refine the plan

```text
/research-plan "your research topic"
```

This should create or update:

- `research/plan.md`
- `research/plan-history.md`

Use `research-plan` when you are defining the problem, changing direction, or tightening the scope before code starts flying everywhere.

### 3. Prepare the first implementation run

```text
/research-implement "build the first runnable baseline"
```

This should refresh:

- `research/implementation/tasks.json`
- `research/implementation/progress.md`
- `runtime/RESEARCH_STATE.json`

Important:

- `/research-implement` prepares the run
- `implement.sh` executes the repeated loop
- `research/implementation/CLAUDE.md` should remain a stable protocol file

Then run the loop:

```bash
./scripts/research-bot/implement.sh 10
```

That means: run up to 10 bounded implementation rounds.

`implement.sh` will:

1. Read `research/implementation/CLAUDE.md`
2. Feed it to Claude Code
3. Expect updates to `tasks.json` and `progress.md`
4. Repeat until completion, task exhaustion, or the iteration cap

### 4. Prepare the optimization run

```text
/research-optimize "improve [metric] under [constraints]"
```

This should maintain:

- `optimization/prd.json`
- `optimization/progress.md`
- `optimization/CLAUDE.md`
- `runtime/RESEARCH_STATE.json`

Important:

- `/research-optimize` sets the objective and task decomposition
- `optimize.sh` runs the loop
- `optimization/CLAUDE.md` should remain the stable per-round protocol

Then run:

```bash
./scripts/research-bot/optimize.sh 10
```

That means: run up to 10 optimization rounds.

`optimize.sh` will:

1. Read `optimization/CLAUDE.md`
2. Feed it to Claude Code
3. Expect updates to `prd.json` and `progress.md`
4. Repeat until the objective is complete, tasks are done, or the iteration cap is reached

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

This keeps old work recoverable without muddying the current loop. Past-you did the work; future-you deserves to find it. 📦

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
