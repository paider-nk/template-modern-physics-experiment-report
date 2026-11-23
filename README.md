# 近代物理实验报告模板 Skill

一套固定版式的近代物理实验报告模板，配可直接编译的 LaTeX 骨架、可复用的图元片段，以及四份按此模板完成的完整报告。

所有由它生成的报告版面一致：A4、正文五号宋体、1.5 倍行距、黑体标题、图题表题规范、`MODERN PHYSICS EXPERIMENT II` 页眉。读者看到的是内容，不是排版的差异。

## 目录结构

```
.
├── SKILL.md                          skill 入口：工作流、LaTeX 路线、保真规则
├── artifact-template.json            模板描述（参考件与预览图索引）
├── agents/openai.yaml                agent 元数据
├── assets/
│   ├── preview.png                   模板版式规格图
│   ├── reference.docx                保留的 Word 参考件
│   └── latex/
│       ├── report-template.tex       可编译骨架，复制后填内容
│       └── figure-snippets.tex       八类可复用图元
├── references/
│   ├── report-workflow.md            来源处理、结构、分析、验收
│   ├── latex-layout-spec.md          版式参数、编译命令、踩坑对照表
│   └── worked-examples.md            四份报告的案例档案
└── scripts/
    └── check.ps1                     编译两份 tex 并扫描日志
```

## 四份示例报告

| 报告 | 页数 | 原始素材 | 示范了什么 |
| --- | --- | --- | --- |
| 9.9 锁相放大器 | 22 | Word 文档，35 张图 | 完整推导链、附录数据表、英文摘要 |
| 4.5 电光调制器特性的测试 | 15 | Word 文档，35 张多为残缺的图 | 全部原理图改用 TikZ 重画，只保留实拍照片 |
| 电子自旋共振 | 16 | 19 页 12 pt PDF 与 `.tex` | 长文档迁入模板、清除制作说明 |
| 荧光光谱 | 11 | 19 页 PDF，5.2 MB | 图片重压缩、多任务结构、图注如实标注 |

每份报告的素材形态、结构决策、图策略、实测数据、出错点与验收方式，记录在 `references/worked-examples.md`。

## 环境要求

- **TeX**：XeLaTeX，需要 `ctex`、`tikz`、`pgfplots`、`booktabs`、`caption`、`titlesec`、`fancyhdr`、`siunitx`、`needspace`。TinyTeX 足够，缺包用 `tlmgr install` 补。
- **字体**：SimSun（宋体）、SimHei（黑体）、KaiTi（楷体）、Times New Roman。Windows 自带；macOS/Linux 需替换为系统中文字体，并保留粗体映射 `BoldFont=SimHei`，否则标题会静默掉粗。
- **可选**：LibreOffice 或其他 PDF 光栅化工具，用于把成品渲染成图逐页检查。

## 安装与使用

1. 把本目录复制到 skills 目录，例如 `~/.codex/skills/`（Windows：`C:\Users\<你>\.codex\skills\`）。
2. 新建实验报告时点名该 skill，或由描述自动触发。
3. LaTeX 路线：复制 `assets/latex/report-template.tex` 到工程目录，图片放进 `figs/`，按小节填入内容。

检查模板本身：

```powershell
pwsh -File scripts/check.ps1
```

脚本在临时目录编译 `report-template.tex` 与 `figure-snippets.tex`，日志里出现错误、Overfull Box 或未定义引用即判失败。

编译与渲染的具体命令、验收标准见 `references/latex-layout-spec.md` 第 2 节。

## 设计约定

- 版式参数只写在导言区一处。要改纸张或字号，改导言区，不要逐个图去补丁。
- 原理图用 TikZ 重画，实拍照片一律保留。重画过的截图不再是证据。
- 以照片为“数据点”的图表（如“波片位置 × 偏压”）排成坐标系，不排成把图片塞进单元格的表格。
- 只有来自物理模型的曲线才叫拟合；连接实测点的曲线标注为平滑连线。
- 讲报告本身而不讲物理的句子（制作说明、自我设限、“资料中没有给出”一类）一律删除，不做软化处理。

`assets/preview.png` 是版式规格图，四份报告在标题、作者、摘要、页眉四处采用了略大的字号阶梯，与规格图的差异及需改动的行号列在 `references/latex-layout-spec.md` 第 1 节末。

## 推送到 GitHub

本目录已是仓库结构。执行：

```bash
git init
git add .
git commit -m "Initial commit: modern physics experiment report skill"
git branch -M main
git remote add origin https://github.com/<你的账号>/artifact-template-modern-physics-experiment-report.git
git push -u origin main
```

仓库约 4.9 MB，其中 `assets/reference.docx` 占 4.4 MB。LaTeX 路线不读取该文件，删掉它可把仓库压到 0.5 MB 以内。

## 许可

MIT，见 `LICENSE`。发布前替换其中的版权人占位。

## 参考文件

`assets/reference.docx`、`assets/preview.png`、`artifact-template.json` 是模板的视觉参考件，`SKILL.md` 禁止修改它们。保留在仓库中是为了让 Word 路线同样可复现。
