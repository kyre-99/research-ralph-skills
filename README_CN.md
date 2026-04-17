# Research Bot

一个面向 Claude Code 的最小持久化研究工作流，设计思路参考 Ralph 的 file-first loop。

这个仓库的核心原则很简单：流程恢复应该依赖一小组关键文件，而不是依赖聊天上下文。规划、实现、优化、归档状态都落在磁盘上，所以下一轮可以直接接着做。

## 这个仓库提供了什么

- `.claude/skills/` 里的项目级 skills
- 工作区初始化脚本：`scripts/research-bot/init.sh`
- 重复实现循环脚本：`scripts/research-bot/implement.sh`
- 重复优化循环脚本：`scripts/research-bot/optimize.sh`
- 归档脚本：`scripts/research-bot/archive-run.sh`
- 一键安装到项目 `.claude/skills` 的脚本：`scripts/research-bot/install-skills.sh`

## 怎么使用

有两种使用方式：

### 方式 1：直接作为项目 skills 使用

如果你就在这个仓库里工作，Claude Code 可以直接读取 `.claude/skills/`，不需要额外安装。

### 方式 2：安装到其他项目的 `.claude/skills`

如果你想在别的仓库里复用这些 skills：

```bash
./scripts/research-bot/install-skills.sh /path/to/target-project
```

它会把：

- skills 复制到 `.claude/skills/`
- 辅助脚本复制到 `scripts/research-bot/`

也就是说，目标项目会同时拿到 skills 和 runner 脚本。

具体是：

```text
/path/to/target-project/.claude/skills/
/path/to/target-project/scripts/research-bot/
```

如果你当前就在目标项目目录里，也可以省略参数：

```bash
cd /path/to/target-project
/path/to/reasearch-bot/scripts/research-bot/install-skills.sh
```

## 整体流程

推荐链路是：

```text
init.sh -> /research-plan -> /research-implement -> implement.sh -> /research-optimize -> optimize.sh
```

进入优化阶段之后，大部分持续迭代都应该留在 `/research-optimize` 里完成。

## 最小文件模型

系统只保留恢复工作所需的核心文件。

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

- `research/plan.md`
- `research/plan-history.md`

`research-plan` 主要用于最开始建题，或者当研究问题本身发生变化时重新收敛方向。

### 3. 做出第一版可运行实现

```text
/research-implement "build the first runnable baseline"
```

它应该更新：

- `research/implementation/tasks.json`
- `research/implementation/progress.md`
- `research/implementation/CLAUDE.md`

这里的目标是把当前计划拆成很多可逐步完成的实现任务，并把实现循环准备好。默认情况下，`/research-implement` 不应该在当前会话里把整轮实现自己跑掉。

#### 然后运行实现循环

```bash
./scripts/research-bot/implement.sh 10
```

意思是：最多跑 10 轮实现。

`implement.sh` 做的事情是：

1. 读取 `research/implementation/CLAUDE.md`
2. 把它交给 Claude Code
3. 让 Claude 执行一轮有边界的实现
4. 期待 Claude 更新 `tasks.json` 和 `progress.md`
5. 持续重复，直到：
   - Claude 返回 `<promise>IMPLEMENTATION_COMPLETE</promise>`，或者
   - `research/implementation/tasks.json` 里的任务都完成，或者
   - 达到最大轮数

注意：`implement.sh` 只是循环执行器。真正负责设定实现任务分解和 prompt 的是 `research-implement`。

换句话说：

- `/research-implement`
  - 负责准备或刷新实现产物
  - 应该停在“建议你执行 `./scripts/research-bot/implement.sh <N>`”
  - 不应该默认把整个实现循环在当前会话里跑完
- `./scripts/research-bot/implement.sh 10`
  - 负责执行多轮 fresh implementation rounds

### 4. 进入优化阶段

先运行：

```text
/research-optimize "improve [metric] under [constraints]"
```

这个 skill 负责准备并维护优化 run。它负责这些文件：

- `optimization/prd.json`
- `optimization/progress.md`
- `optimization/CLAUDE.md`

它的职责是“准备循环”，而不是“自己就是循环”。

#### 这些文件分别是什么

- `optimization/prd.json`
  - 优化任务分解：目标、主指标、停止条件、baseline，以及一组可在单轮内完成的任务。
- `optimization/progress.md`
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
4. 期待 Claude 更新 `prd.json` 和 `progress.md`
5. 持续重复，直到：
   - Claude 返回 `<promise>OPTIMIZATION_COMPLETE</promise>`，或者
   - `optimization/prd.json` 里的任务都完成，或者
   - 达到最大轮数

注意：`optimize.sh` 只是循环执行器，不负责思考优化策略。真正负责设定任务分解和 prompt 的是 `research-optimize`。

换句话说：

- `/research-optimize`
  - 负责准备或刷新优化产物
  - 负责判断是继续当前 run，还是归档后开启新 run
  - 应该把仓库准备到可以交给 shell runner 的状态
- `./scripts/research-bot/optimize.sh 10`
  - 负责把 `optimization/CLAUDE.md` 交给 Claude Code，最多重复执行 10 轮

如果你之前只安装了 skills，没有把 scripts 一起带过去，那么目标项目里确实不会有 `optimize.sh`。现在安装脚本已经把这点补上了。

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
2. 用 `research-implement` 创建或刷新 implementation run。
3. 用 `implement.sh` 执行多轮实现，直到 baseline 准备好。
4. 用 `research-optimize` 创建或刷新优化 run。
5. 用 `optimize.sh` 执行多轮优化。
6. 后续优化方向变化，尽量留在 `research-optimize` 内部处理。
7. 当优化目标实质变化时，再归档旧 run。

## 当前已经完整的部分

这套仓库目前已经完整支持最小 artifact-first workflow：

- planning 持久化
- implementation 持久化
- `implement.sh` 驱动的重复实现循环
- optimization 持久化
- runtime 恢复索引
- archive 支持
- `optimize.sh` 驱动的重复优化循环
- 可选的安装到其他项目 `.claude/skills`

## 当前刻意不包含的部分

- 远程任务调度
- watchdog 守护进程
- 多 agent review loop
- 自动实验基础设施

这些可以以后继续扩展，但它们不属于这个最小第一版的范围。
