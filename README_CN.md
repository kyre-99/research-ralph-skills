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

## 整体流程，一眼看懂

```text
init.sh
  -> /research-plan
  -> /research-implement
  -> implement.sh
  -> /research-optimize
  -> optimize.sh
```

简单理解：

- `research-plan` 负责想清楚问题
- `research-implement` 负责把问题拆成能做的实现任务
- `implement.sh` 负责重复推进实现
- `research-optimize` 负责定义优化目标和实验回路
- `optimize.sh` 负责反复跑优化轮次

规划像定方向，实装像搭底盘，优化像拧性能。别一上来就调参，否则很容易在空气里造火箭。🧪

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

## 分步骤使用

### 1. 初始化工作区

```bash
./scripts/research-bot/init.sh
```

这会在缺失时创建最小的 `research/`、`optimization/`、`runtime/` 结构。

### 2. 创建或收敛研究计划

```text
/research-plan "你的研究主题"
```

它应该创建或更新：

- `research/plan.md`
- `research/plan-history.md`

适合在这些时候使用：

- 刚开始立题
- 研究问题发生变化
- 方向太散，需要重新收敛

### 3. 准备第一轮实现

```text
/research-implement "build the first runnable baseline"
```

它应该刷新：

- `research/implementation/tasks.json`
- `research/implementation/progress.md`
- `runtime/RESEARCH_STATE.json`

这里要注意：

- `/research-implement` 的职责是准备实现轮次
- `implement.sh` 的职责是执行多轮循环
- `research/implementation/CLAUDE.md` 应尽量保持为稳定协议文件

然后执行：

```bash
./scripts/research-bot/implement.sh 10
```

意思是：最多跑 10 轮实现。

`implement.sh` 会：

1. 读取 `research/implementation/CLAUDE.md`
2. 把它交给 Claude Code
3. 期待 Claude 更新 `tasks.json` 和 `progress.md`
4. 持续循环，直到完成目标、任务清空，或达到轮数上限

### 4. 准备优化轮次

```text
/research-optimize "improve [metric] under [constraints]"
```

它应该维护：

- `optimization/prd.json`
- `optimization/progress.md`
- `optimization/CLAUDE.md`
- `runtime/RESEARCH_STATE.json`

这里也一样：

- `/research-optimize` 负责定义目标和任务拆解
- `optimize.sh` 负责执行循环
- `optimization/CLAUDE.md` 应尽量保持为稳定的单轮协议文件

然后执行：

```bash
./scripts/research-bot/optimize.sh 10
```

意思是：最多跑 10 轮优化。

`optimize.sh` 会：

1. 读取 `optimization/CLAUDE.md`
2. 把它交给 Claude Code
3. 期待 Claude 更新 `prd.json` 和 `progress.md`
4. 持续循环，直到目标完成、任务结束，或达到轮数上限

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

这样旧工作还能追溯，当前工作也不会越跑越糊。过去的你已经很努力了，未来的你值得一个找得到的历史记录。📦

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
