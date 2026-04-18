# Research Bot

一个给 Claude Code 用的 file-first 研究工作流：比聊天记忆更稳，比“我应该还记得上次做到哪了吧”更靠谱。🧠⚙️

它的核心思路很直接：不要把连续研究流程寄托在上下文窗口上，而是把关键状态落到文件里。计划、实现拆解、优化日志、运行时摘要都在磁盘上，所以你今天关掉会话，明天回来，项目还是接得上。✨

English version: [README.md](README.md)

## 这东西是干嘛的

很多 AI 工作流一开始都很丝滑，直到上下文没了，或者模型“似曾相识但又完全不对劲”。

这个仓库换了个思路：

- 用文件保存研究状态
- 让每个阶段都留下明确交接物
- 让新会话靠仓库恢复，而不是靠聊天记忆硬撑

如果你喜欢 Ralph 风格循环、长线实验、可恢复的 agent 工作流，这个仓库基本就是冲着这个方向来的。🚂

## 仓库里有什么

- `.claude/skills/` 里的项目级 skills
- 初始化脚本：`scripts/research-bot/init.sh`
- 实现循环 runner：`scripts/research-bot/implement.sh`
- 优化循环 runner：`scripts/research-bot/optimize.sh`
- 整体归档脚本：`scripts/research-bot/archive-run.sh`
- 实现阶段归档脚本：`scripts/research-bot/archive-implementation.sh`
- 优化阶段归档脚本：`scripts/research-bot/archive-optimization.sh`
- 安装脚本：`scripts/research-bot/install-skills.sh`

## 两种使用方式

### 1. 直接在当前仓库里用

如果你就在这个仓库里工作，Claude Code 可以直接读取 `.claude/skills/`，不需要额外安装。开箱即用，少折腾一点就是幸福。🎉

### 2. 安装到别的项目里

如果你想在其他仓库复用这套流程：

```bash
./scripts/research-bot/install-skills.sh /path/to/target-project
```

它会同时复制：

- skills 到 `.claude/skills/`
- 辅助脚本到 `scripts/research-bot/`

目标项目最终会得到：

```text
/path/to/target-project/.claude/skills/
/path/to/target-project/scripts/research-bot/
```

如果你已经在目标项目目录里，也可以省略参数：

```bash
cd /path/to/target-project
/path/to/reasearch-bot/scripts/research-bot/install-skills.sh
```

## 主要用法

```text
新项目：
  init.sh
  -> /research-plan
  -> /research-implement
  -> implement.sh
  -> /research-optimize
  -> optimize.sh

恢复已有项目：
  /research-pipeline

切换到新的研究方向：
  archive current run
  -> /research-plan
```

大多数时候，你只需要记住这三种入口：

### 1. 开一个新项目

```bash
./scripts/research-bot/init.sh
```

```text
/research-plan "你的研究主题"
/research-implement "build the first runnable baseline"
./scripts/research-bot/implement.sh 10
/research-optimize "improve [metric] under [constraints]"
./scripts/research-bot/optimize.sh 10
```

### 2. 在新 session 里继续

```text
/research-pipeline continue the current research run
```

### 3. 开一个新的研究方向

```bash
./scripts/research-bot/archive-run.sh my-topic
```

```text
/research-plan "新的研究方向"
```

## `research-pipeline` 到底是干嘛的

`/research-pipeline` 是一个“恢复现场 + 自动分流”的入口 skill。

适合在这些时候用：

- 你开了一个全新的 session
- 你不想自己判断下一步该跑哪个 skill
- 你只想说一句“继续当前工作”

它会：

- 先读 `runtime/RESEARCH_STATE.json`
- 再读里面列出来的关键文件
- 判断当前应该继续 planning、implementation、optimization，还是先修复 runtime 状态
- 把流程路由到合适的下一阶段，而不是每次都从头猜

说白一点：如果你新开一个 session，只想让它接着做，`research-pipeline` 就是最适合的入口。🧭

推荐的新 session 用法：

```text
/research-pipeline continue the current research run
```

ℹ️ 只要 `runtime/RESEARCH_STATE.json` 维护得比较新，这个 skill 就能用文件里的状态把新会话接上，而不是依赖聊天记忆。

## 最小文件模型

整个系统故意保持很小。目标不是“什么都记”，而是“把下一个 round 真正需要的东西记下来”。

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

## 最关键的那个文件

`runtime/RESEARCH_STATE.json` 是 fresh session 的轻量入口文件。

它只需要概括：

- 当前阶段
- 当前目标
- 当前状态
- 下一步动作
- 接下来该读哪些关键文件

把它当“快照”，不要把它当“流水账”。保持短、准、新，比堆一大坨历史更有用。🪄

## 快速说明

- `/research-plan`：定义研究方向
- `/research-implement`：准备实现任务和实现状态
- `./scripts/research-bot/implement.sh 10`：执行多轮实现
- `/research-optimize`：准备优化目标和优化状态
- `./scripts/research-bot/optimize.sh 10`：执行多轮优化
- `/research-pipeline`：新 session 恢复现场时优先用它

## 归档，别硬糊在一起

当目标发生实质变化，新一轮已经不能和当前 run 相提并论时，先归档，再继续。

归档整个 run：

```bash
./scripts/research-bot/archive-run.sh my-topic
```

只归档实现阶段：

```bash
./scripts/research-bot/archive-implementation.sh implementation-reset
```

只归档优化阶段：

```bash
./scripts/research-bot/archive-optimization.sh optimization-reset
```

这样旧工作还能追溯，当前工作也不会越跑越糊。📦

## 推荐习惯

- 让 `RESEARCH_STATE.json` 始终简短、最新
- 把文件当作记忆表面，而不是把聊天记录当数据库
- 先把计划收敛，再扩展实现
- 先把实现跑起来，再谈优化
- 目标变了就归档，不要把两条完全不同的实验线硬说成同一个 run

## 适合谁用

这套仓库很适合下面这些情况：

- 你想做一个可恢复的 AI 辅助研究流程
- 你不想每次上下文一断就从头解释项目
- 你需要反复 implement / evaluate / improve 的闭环
- 你想要的是“小而硬”的结构，不是大而全的框架

如果这些点戳中了你，那这仓库多半能帮上忙。🔬
