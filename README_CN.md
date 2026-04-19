# Research Bot 🔬

**文件优先的研究工作流** — 关闭电脑，第二天回来，项目依然记得做到哪了。🧠⚡

English version: [README.md](README.md)

---

## ✨ 核心特点

**🎯 一条命令，数小时自主工作**

```bash
./scripts/research-bot/implement.sh 10  # 自动运行10轮实现循环
./scripts/research-bot/optimize.sh 10   # 自动运行10轮优化循环
```

Claude 在循环中自主完成复杂任务——规划、执行、评估、改进——不需要你每一步都盯着。

**🚀 从想法 → 可运行项目 → 优化方案**

| 阶段 | 做什么 |
|------|--------|
| `/research-plan` | 把模糊想法变成结构化计划 |
| `/research-implement` + `implement.sh` | 构建可运行基线，迭代直到稳定 |
| `/research-optimize` + `optimize.sh` | 在约束条件下优化指标 |

一套工作流，从头到尾。不用跳工具。

**🔄 文件记忆，不怕中断**

跑到一半关电脑？第二天新开一个会话，说 `/research-pipeline 继续`。它从断点接续——因为所有状态都在文件里，不靠聊天记忆。

---

## 🚀 两种使用方式

### 方式一：直接在本仓库使用

Claude Code 直接读取 `.claude/skills/`，无需安装 🎉

### 方式二：安装到其他项目

```bash
./scripts/research-bot/install-skills.sh /path/to/your-project
```

创建：
- `.claude/skills/` — 技能定义
- `scripts/research-bot/` — 辅助脚本

---

## 📋 三种典型用法

### 🆕 启动新项目

```bash
./scripts/research-bot/init.sh
```

```
/research-plan “你的研究主题”
/research-implement “构建首个可运行版本”
./scripts/research-bot/implement.sh 10
/research-optimize “在[约束]下优化[指标]”
./scripts/research-bot/optimize.sh 10
```

### 🔄 恢复现有工作（推荐）

新开会话？只需一句：

```
/research-pipeline 继续当前研究
```

它会读取 `RESEARCH_STATE.json`，检测当前阶段，自动路由到下一步 🧭

### 🔀 切换新方向

研究方向发生实质性变化时：

```bash
./scripts/research-bot/archive-run.sh new-topic
/research-plan “新的研究方向”
```

---

## 🗂️ 文件结构

```
research/
├── plan.md, plan-history.md          # 规划阶段
├── implementation/
│   └── tasks.json, progress.md       # 实现阶段
├── optimization/
│   └── prd.json, progress.md         # 优化阶段

runtime/
├── RESEARCH_STATE.json               # 🔑 新会话入口文件
├── MANIFEST.md

archive/                              # 历史归档
```

---

## 💡 最佳实践

- 📝 保持 `RESEARCH_STATE.json` 简洁且最新
- 🧠 把文件当记忆，别依赖聊天记录
- 🎯 先规划，再实现，再优化
- 📦 方向变了就归档

---

## 🎯 适合谁用

- 需要长期运行的 AI 辅助研究项目
- 希望项目在上下文重置后依然存活
- 实现→评估→改进的循环工作流
- 偏好轻量结构而非大框架

---

## 🛠️ 快速参考

| 命令 | 用途 |
|------|------|
| `/research-plan` | 定义研究方向 |
| `/research-implement` | 准备实现阶段 |
| `/research-optimize` | 准备优化阶段 |
| `/research-pipeline` | 🌟 新会话恢复入口 |
| `implement.sh N` | 运行 N 轮实现循环 |
| `optimize.sh N` | 运行 N 轮优化循环 |
| `archive-run.sh` | 归档整次运行 |
