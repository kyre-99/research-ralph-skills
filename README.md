# Research Bot

Minimal persistent research workflow for Claude Code, inspired by Ralph's file-first loop.

This repo is built around one idea: the workflow should resume from a small set of files, not from chat memory. Planning, implementation, optimization, and archive state are all persisted on disk so the next round can continue cleanly.

See the Chinese guide in [README_CN.md](README_CN.md).

## What this repo gives you

- Project skills in `.claude/skills/`
- A workspace bootstrap script: `scripts/research-bot/init.sh`
- A repeated implementation runner: `scripts/research-bot/implement.sh`
- A repeated optimization runner: `scripts/research-bot/optimize.sh`
- An archive helper: `scripts/research-bot/archive-run.sh`
- A one-command installer for project skills: `scripts/research-bot/install-skills.sh`

## How to use it

There are two ways to use the skills:

### Option 1: Use as project skills

If you are working inside this repo, Claude Code can use the skills from `.claude/skills/` directly. No installation is required.

### Option 2: Install into another project's `.claude/skills`

If you want to reuse these skills in another repo:

```bash
./scripts/research-bot/install-skills.sh /path/to/target-project
```

This copies:

- the skills into `.claude/skills/`
- the helper scripts into `scripts/research-bot/`

So the target project receives both the skills and the runner scripts.

Specifically:

```text
/path/to/target-project/.claude/skills/
/path/to/target-project/scripts/research-bot/
```

If you run it from inside the target project, you can omit the argument:

```bash
cd /path/to/target-project
/path/to/reasearch-bot/scripts/research-bot/install-skills.sh
```

## The workflow

The intended flow is:

```text
init.sh -> /research-plan -> /research-implement -> implement.sh -> /research-optimize -> optimize.sh
```

After that, most ongoing iteration should stay inside `/research-optimize`.

## Minimal file model

The system keeps only the core files needed to resume work.

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

- `research/plan.md`
- `research/plan-history.md`

Use `research-plan` mainly at the beginning or when the research problem itself changes.

### 3. Build the first runnable implementation

```text
/research-implement "build the first runnable baseline"
```

This should update:

- `research/implementation/tasks.json`
- `research/implementation/progress.md`
- `research/implementation/CLAUDE.md`

The goal here is to split the current plan into bounded implementation tasks and prepare the implementation loop. By default, `/research-implement` should not start running the whole implementation in the current session.

#### Then run the implementation loop

```bash
./scripts/research-bot/implement.sh 10
```

This means: run up to 10 implementation rounds.

What `implement.sh` does:

1. Reads `research/implementation/CLAUDE.md`
2. Sends it to Claude Code
3. Lets Claude execute one bounded implementation round
4. Expects Claude to update `tasks.json` and `progress.md`
5. Repeats until:
   - Claude returns `<promise>IMPLEMENTATION_COMPLETE</promise>`, or
   - all tasks in `research/implementation/tasks.json` are complete, or
   - the max iteration count is reached

Important: `implement.sh` is only the loop runner. `research-implement` is responsible for setting the implementation task decomposition and prompt.

In other words:

- `/research-implement`
  - prepares or refreshes the implementation artifacts
  - should stop by recommending `./scripts/research-bot/implement.sh <N>`
  - should not silently execute the whole implementation loop
- `./scripts/research-bot/implement.sh 10`
  - runs repeated fresh implementation rounds

### 4. Start optimization

First run:

```text
/research-optimize "improve [metric] under [constraints]"
```

This is the skill that should prepare and maintain the optimization run. It owns:

- `optimization/prd.json`
- `optimization/progress.md`
- `optimization/CLAUDE.md`

Its job is to prepare the loop, not to be the loop.

#### What these files mean

- `optimization/prd.json`
  - The optimization task decomposition: objective, primary metric, stop condition, baseline, and bounded tasks.
- `optimization/progress.md`
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
4. Expects Claude to update `prd.json` and `progress.md`
5. Repeats until:
   - Claude returns `<promise>OPTIMIZATION_COMPLETE</promise>`, or
   - all tasks in `optimization/prd.json` are complete, or
   - the max iteration count is reached

Important: `optimize.sh` is only the loop runner. It does not invent the strategy. `research-optimize` is responsible for setting the task decomposition and prompt.

In other words:

- `/research-optimize`
  - prepares or refreshes the optimization artifacts
  - decides whether to continue the current run or archive and start a new one
  - should leave the repo ready for the shell runner
- `./scripts/research-bot/optimize.sh 10`
  - runs repeated fresh rounds by feeding `optimization/CLAUDE.md` into Claude Code up to 10 times

If you installed only the skills but not the scripts, the target project would not have `optimize.sh`. The installer now copies both.

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
2. Use `research-implement` to create or refresh the implementation run.
3. Use `implement.sh` to execute repeated implementation rounds until the baseline is ready.
4. Use `research-optimize` to create or refresh the optimization run.
5. Use `optimize.sh` to execute repeated optimization rounds.
6. Stay inside `research-optimize` for ongoing direction changes in the optimization loop.
7. Archive when the optimization target changes materially.

## What is complete today

This repo is complete for a minimal artifact-first workflow:

- persistent planning
- persistent implementation
- repeated implementation rounds through `implement.sh`
- persistent optimization
- runtime index for recovery
- archive support
- repeated optimization rounds through `optimize.sh`
- optional installation into another project's `.claude/skills`

## What is intentionally not included

- remote job orchestration
- watchdog daemons
- multi-agent review loops
- automatic experiment infrastructure

Those can be added later, but they are intentionally outside the minimal first version.
