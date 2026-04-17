# Research Bot

Minimal persistent research workflow for Claude Code, inspired by Ralph's file-first loop.

This repo is built around one idea: the workflow should resume from a small set of files, not from chat memory. Planning, implementation, optimization, and archive state are all persisted on disk so the next round can continue cleanly.

See the Chinese guide in [README_CN.md](README_CN.md).

## What this repo gives you

- Project skills in `.claude/skills/`
- A workspace bootstrap script: `scripts/research-bot/init.sh`
- A repeated optimization runner: `scripts/research-bot/optimize.sh`
- An archive helper: `scripts/research-bot/archive-run.sh`
- A one-command global installer for the skills: `scripts/research-bot/install-skills.sh`

## How to use it

There are two ways to use the skills:

### Option 1: Use as project skills

If you are working inside this repo, Claude Code can use the skills from `.claude/skills/` directly. No installation is required.

### Option 2: Install as global skills

If you want to reuse these skills in other repos:

```bash
./scripts/research-bot/install-skills.sh
```

This copies the skills into `~/.claude/skills`.

You can also install to a custom directory:

```bash
./scripts/research-bot/install-skills.sh /path/to/skills
```

## The workflow

The intended flow is:

```text
init.sh -> /research-plan -> /research-implement -> /research-optimize -> optimize.sh
```

After that, most ongoing iteration should stay inside `/research-optimize`.

## Minimal file model

The system keeps only the core files needed to resume work.

### Planning

- `research/brief.md`
- `research/plan.md`
- `research/plan-state.json`
- `research/plan-progress.md`

### Implementation

- `research/implementation/IMPLEMENTATION.md`
- `research/implementation/IMPLEMENTATION_STATE.json`
- `research/implementation/IMPLEMENTATION_LOG.md`

### Optimization

- `optimization/OBJECTIVE.md`
- `optimization/QUEUE.md`
- `optimization/STATE.json`
- `optimization/PROGRESS.md`
- `optimization/CLAUDE.md`

### Runtime

- `runtime/RESEARCH_STATE.json`
- `runtime/MANIFEST.md`

### Archive

- `archive/<timestamp>-<slug>/`

## Step by step

### 1. Initialize the workspace

```bash
./scripts/research-bot/init.sh
```

This creates the minimal `research/`, `optimization/`, and `runtime/` files if they do not already exist.

### 2. Create the initial plan

```text
/research-plan "your research topic"
```

This should fill or refine:

- `research/brief.md`
- `research/plan.md`
- `research/plan-state.json`
- `research/plan-progress.md`

Use `research-plan` mainly at the beginning or when the research problem itself changes.

### 3. Build the first runnable implementation

```text
/research-implement "build the first runnable baseline"
```

This should update:

- `research/implementation/IMPLEMENTATION.md`
- `research/implementation/IMPLEMENTATION_STATE.json`
- `research/implementation/IMPLEMENTATION_LOG.md`

The goal here is not endless refinement. The goal is to create a runnable baseline that optimization can work on.

### 4. Start optimization

First run:

```text
/research-optimize "improve [metric] under [constraints]"
```

This is the skill that should prepare and maintain the optimization loop. It owns:

- `optimization/OBJECTIVE.md`
- `optimization/QUEUE.md`
- `optimization/STATE.json`
- `optimization/PROGRESS.md`
- `optimization/CLAUDE.md`

#### What these files mean

- `optimization/OBJECTIVE.md`
  - The optimization contract: goal, metric, target, constraints, allowed search space.
- `optimization/QUEUE.md`
  - The current backlog of optimization ideas: active, pending, accepted, rejected, blocked.
- `optimization/STATE.json`
  - The machine-readable snapshot of the current optimization run.
- `optimization/PROGRESS.md`
  - The append-only history of rounds, changes, evaluations, and decisions.
- `optimization/CLAUDE.md`
  - The per-round execution prompt that `optimize.sh` feeds into Claude Code.

#### Then run the loop

```bash
./scripts/research-bot/optimize.sh 10
```

This means: run up to 10 optimization rounds.

What `optimize.sh` does:

1. Reads `optimization/CLAUDE.md`
2. Sends it to Claude Code
3. Lets Claude execute one bounded optimization round
4. Expects Claude to update `QUEUE.md`, `STATE.json`, and `PROGRESS.md`
5. Repeats until:
   - Claude returns `<promise>OPTIMIZATION_COMPLETE</promise>`, or
   - `optimization/STATE.json` says the run is complete/stopped, or
   - the max iteration count is reached

Important: `optimize.sh` is only the loop runner. It does not invent the strategy. `research-optimize` is responsible for setting the objective, queue, and prompt.

## Archiving runs

When the optimization objective changes materially and the new run is not comparable to the current one, archive the current state first:

```bash
./scripts/research-bot/archive-run.sh my-topic
```

This copies:

- `research/`
- `optimization/`
- `runtime/`

into:

```text
archive/<timestamp>-my-topic/
```

In this workflow, archiving is mainly part of `research-optimize`, not `research-plan`.

## Recommended usage pattern

1. Use `research-plan` once to define the problem and milestones.
2. Use `research-implement` to create a runnable baseline.
3. Use `research-optimize` to create or refresh the optimization run.
4. Use `optimize.sh` to execute repeated rounds.
5. Stay inside `research-optimize` for ongoing direction changes in the optimization loop.
6. Archive when the optimization target changes materially.

## What is complete today

This repo is complete for a minimal artifact-first workflow:

- persistent planning
- persistent implementation
- persistent optimization
- runtime index for recovery
- archive support
- repeated optimization rounds through `optimize.sh`
- optional global skill installation

## What is intentionally not included

- remote job orchestration
- watchdog daemons
- multi-agent review loops
- automatic experiment infrastructure

Those can be added later, but they are intentionally outside the minimal first version.
