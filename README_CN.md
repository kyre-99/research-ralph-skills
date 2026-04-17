# Research Bot

一个面向 Claude Code 的最小持久化研究工作流，设计思路参考 Ralph 的 file-first loop。

这个仓库的核心原则很简单：流程恢复应该依赖一小组关键文件，而不是依赖聊天上下文。规划、实现、优化、归档状态都落在磁盘上，所以下一轮可以直接接着做。

## 这个仓库提供了什么

- `.claude/skills/` 里的项目级 skills
- 工作区初始化脚本：`scripts/research-bot/init.sh`
- 重复优化循环脚本：`scripts/research-bot/optimize.sh`
- 归档脚本：`scripts/research-bot/archive-run.sh`
- 一键全局安装 skills 的脚本：`scripts/research-bot/install-skills.sh`

## 怎么使用

有两种使用方式：

### 方式 1：直接作为项目 skills 使用

如果你就在这个仓库里工作，Claude Code 可以直接读取 `.claude/skills/`，不需要额外安装。

### 方式 2：安装为全局 skills

如果你想在别的仓库里也复用这些 skills：

```bash
./scripts/research-bot/install-skills.sh
```

它会把 skills 复制到 `~/.claude/skills`。

也可以安装到自定义目录：

```bash
./scripts/research-bot/install-skills.sh /path/to/skills
```

## 整体流程

推荐链路是：

```text
init.sh -> /research-plan -> /research-implement -> /research-optimize -> optimize.sh
```

进入优化阶段之后，大部分持续迭代都应该留在 `/research-optimize` 里完成。

## 最小文件模型

系统只保留恢复工作所需的核心文件。

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

## 分步骤使用

### 1. 初始化工作区

```bash
./scripts/research-bot/init.sh
```

这会在缺失时创建最小的 `research/`、`optimization/`、`runtime/` 文件集合。

### 2. 建立初始研究计划

```text
/research-plan "你的研究主题"
```

它应该填写或更新：

- `research/brief.md`
- `research/plan.md`
- `research/plan-state.json`
- `research/plan-progress.md`

`research-plan` 主要用于最开始建题，或者当研究问题本身发生变化时重新收敛方向。

### 3. 做出第一版可运行实现

```text
/research-implement "build the first runnable baseline"
```

它应该更新：

- `research/implementation/IMPLEMENTATION.md`
- `research/implementation/IMPLEMENTATION_STATE.json`
- `research/implementation/IMPLEMENTATION_LOG.md`

这里的目标不是无止境优化，而是先得到一个能跑、能测的 baseline。

### 4. 进入优化阶段

先运行：

```text
/research-optimize "improve [metric] under [constraints]"
```

这个 skill 负责准备并维护优化循环。它负责这些文件：

- `optimization/OBJECTIVE.md`
- `optimization/QUEUE.md`
- `optimization/STATE.json`
- `optimization/PROGRESS.md`
- `optimization/CLAUDE.md`

#### 这些文件分别是什么

- `optimization/OBJECTIVE.md`
  - 优化合同：目标、指标、目标值、约束、允许改动范围。
- `optimization/QUEUE.md`
  - 当前优化待办：active、pending、accepted、rejected、blocked。
- `optimization/STATE.json`
  - 当前优化 run 的机器可读状态快照。
- `optimization/PROGRESS.md`
  - 追加式优化日志，记录每轮改了什么、怎么评估、结果如何、下一步是什么。
- `optimization/CLAUDE.md`
  - 给 Claude Code 每一轮执行时使用的 prompt，`optimize.sh` 会反复把它交给 Claude。

#### 然后运行循环

```bash
./scripts/research-bot/optimize.sh 10
```

意思是：最多跑 10 轮优化。

`optimize.sh` 做的事情是：

1. 读取 `optimization/CLAUDE.md`
2. 把它交给 Claude Code
3. 让 Claude 执行一轮有边界的优化
4. 期待 Claude 更新 `QUEUE.md`、`STATE.json`、`PROGRESS.md`
5. 持续重复，直到：
   - Claude 返回 `<promise>OPTIMIZATION_COMPLETE</promise>`，或者
   - `optimization/STATE.json` 里标记完成/停止，或者
   - 达到最大轮数

注意：`optimize.sh` 只是循环执行器，不负责思考优化策略。真正负责设定目标、队列和 prompt 的是 `research-optimize`。

## 如何归档

当优化目标发生实质变化，新的 run 与当前 run 已经不可比时，先归档当前状态：

```bash
./scripts/research-bot/archive-run.sh my-topic
```

它会把：

- `research/`
- `optimization/`
- `runtime/`

复制到：

```text
archive/<timestamp>-my-topic/
```

在这套流程里，归档主要属于 `research-optimize` 的职责，而不是 `research-plan`。

## 推荐使用习惯

1. 用 `research-plan` 一次性定义研究问题和里程碑。
2. 用 `research-implement` 做出第一版可运行 baseline。
3. 用 `research-optimize` 创建或刷新优化 run。
4. 用 `optimize.sh` 执行多轮优化。
5. 后续优化方向变化，尽量留在 `research-optimize` 内部处理。
6. 当优化目标实质变化时，再归档旧 run。

## 当前已经完整的部分

这套仓库目前已经完整支持最小 artifact-first workflow：

- planning 持久化
- implementation 持久化
- optimization 持久化
- runtime 恢复索引
- archive 支持
- `optimize.sh` 驱动的重复优化循环
- 可选的全局 skills 安装

## 当前刻意不包含的部分

- 远程任务调度
- watchdog 守护进程
- 多 agent review loop
- 自动实验基础设施

这些可以以后继续扩展，但它们不属于这个最小第一版的范围。
