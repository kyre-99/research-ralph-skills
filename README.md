# Research Bot 🔬

**File-first research workflow** — Your AI research project survives context resets. Close the laptop, come back tomorrow, it still knows where it was. 🧠⚡

Chinese version: [README_CN.md](README_CN.md)

---

## ✨ Core Features

**🎯 One command, hours of autonomous work**

```bash
./scripts/research-bot/implement.sh 10  # Runs 10 implementation rounds autonomously
./scripts/research-bot/optimize.sh 10   # Runs 10 optimization rounds autonomously
```

Claude works through complex tasks in repeated loops — planning, executing, evaluating, improving — without you babysitting each step.

**🚀 From idea → working project → optimized solution**

| Phase | What happens |
|-------|--------------|
| `/research-plan` | Turn vague idea into structured plan |
| `/research-implement` + `implement.sh` | Build working baseline, iterate until solid |
| `/research-optimize` + `optimize.sh` | Tune metrics under constraints |

One workflow, end-to-end. No jumping between tools.

**🔄 Files survive context resets**

Close your laptop mid-run. Open a fresh session tomorrow. Say `/research-pipeline continue`. It picks up exactly where you left off — because all state lives in files, not chat memory.

---

## 🚀 Two Ways to Use

### Option 1: Use directly in this repo

Claude Code reads `.claude/skills/` directly. No installation needed. 🎉

### Option 2: Install into another project

```bash
./scripts/research-bot/install-skills.sh /path/to/your-project
```

Creates:
- `.claude/skills/` — skill definitions
- `scripts/research-bot/` — helper scripts

---

## 📋 Three Key Patterns

### 🆕 Start new project

```bash
./scripts/research-bot/init.sh
```

```
/research-plan “your topic”
/research-implement “build first runnable baseline”
./scripts/research-bot/implement.sh 10
/research-optimize “improve [metric] under [constraints]”
./scripts/research-bot/optimize.sh 10
```

### 🔄 Resume existing work (recommended)

Fresh session? Just say:

```
/research-pipeline continue the current research
```

It reads `RESEARCH_STATE.json`, detects current phase, routes to the right next step. 🧭

### 🔀 Switch to new direction

When research direction changes materially:

```bash
./scripts/research-bot/archive-run.sh new-topic
/research-plan “the new direction”
```

---

## 🗂️ File Structure

```
research/
├── plan.md, plan-history.md          # Planning phase
├── implementation/
│   └── tasks.json, progress.md       # Implementation phase
├── optimization/
│   └── prd.json, progress.md         # Optimization phase

runtime/
├── RESEARCH_STATE.json               # 🔑 Entry point for fresh session
├── MANIFEST.md

archive/                              # Historical runs
```

---

## 💡 Best Practices

- 📝 Keep `RESEARCH_STATE.json` short and current
- 🧠 Treat files as memory, not chat history
- 🎯 Plan first, then implement, then optimize
- 📦 Archive when direction changes

---

## 🎯 Who This Is For

- Long-running AI-assisted research projects
- Projects that need to survive context resets
- Implement → Evaluate → Improve loop workflows
- Researchers who prefer lean structure over big frameworks

---

## 🛠️ Quick Reference

| Command | Purpose |
|---------|---------|
| `/research-plan` | Define research direction |
| `/research-implement` | Prepare implementation phase |
| `/research-optimize` | Prepare optimization phase |
| `/research-pipeline` | 🌟 Fresh session entry point |
| `implement.sh N` | Run N implementation rounds |
| `optimize.sh N` | Run N optimization rounds |
| `archive-run.sh` | Archive entire run |
