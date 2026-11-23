# Modern Physics Experiment Report — skill

A reusable template for Chinese modern-physics experiment reports (近代物理实验报告), packaged
as an agent skill. It carries a fixed visual layout — A4, 五号宋体正文, 1.5 倍行距, 黑体标题,
图题/表题规范, `MODERN PHYSICS EXPERIMENT II` 页眉 — plus a working LaTeX pipeline and four
complete reports that were produced with it.

The point of the skill is consistency: every report built from it looks like the same
document, so a reader (or a grader) sees the physics rather than the formatting.

## What's inside

```
.
├── SKILL.md                          entry point: workflow, LaTeX pipeline, fidelity rules
├── artifact-template.json            template descriptor (reference + preview)
├── agents/openai.yaml                agent metadata
├── assets/
│   ├── preview.png                   rendered preview of the reference layout
│   ├── reference.docx                the retained Word reference
│   └── latex/
│       ├── report-template.tex       compilable skeleton — copy and fill in
│       └── figure-snippets.tex       eight reusable figure patterns
├── references/
│   ├── report-workflow.md            source handling, structure, analysis, verification
│   ├── latex-layout-spec.md          exact parameters, build commands, error/fix table
│   └── worked-examples.md            the four finished reports, as case files
└── scripts/
    └── check.ps1                     compile both .tex files and scan the logs
```

## The four worked examples

| Report | Pages | Source it started from | What it demonstrates |
| --- | --- | --- | --- |
| 9.9 锁相放大器 (lock-in amplifier) | 22 | Word doc, 35 images | full derivation chain, appendix data tables, English abstract |
| 4.5 电光调制器特性的测试 (electro-optic modulator) | 15 | Word doc, 35 mostly broken figures | redrawing every schematic in TikZ, keeping only real photographs |
| 电子自旋共振 (electron spin resonance) | 16 | 19-page 12 pt PDF + `.tex` | converting a long report to the template, stripping production notes |
| 荧光光谱 (fluorescence) | 11 | 19-page PDF, 5.2 MB | image recompression, multi-task structure, honest figure labelling |

`references/worked-examples.md` records, for each one, the source form, the structural
decisions, the figure strategy, the measured data, what broke, and how it was verified.

## Requirements

- **TeX**: XeLaTeX with `ctex`, `tikz`, `pgfplots`, `booktabs`, `caption`, `titlesec`,
  `fancyhdr`, `siunitx`, `needspace`. A TinyTeX installation is enough — `tlmgr install`
  the missing packages once.
- **Fonts**: SimSun (宋体), SimHei (黑体), KaiTi (楷体) and Times New Roman. On Windows
  these are present by default; on macOS/Linux substitute system CJK fonts and keep the
  bold face mapping (`BoldFont=SimHei`) or headings will silently lose weight.
- **Optional**: LibreOffice (or any PDF rasteriser) for the render-and-inspect step. The
  skill assumes you look at page images, not just the log.

## Use

1. Copy this directory into your skills folder, e.g. `~/.codex/skills/` (Windows:
   `C:\Users\<you>\.codex\skills\`).
2. Ask for a report and name the skill, or let the description trigger it.
3. For a LaTeX report, copy `assets/latex/report-template.tex` into a project folder, put
   the images in `figs/`, and fill in the sections.

To check the template itself:

```powershell
pwsh -File scripts/check.ps1
```

It compiles `report-template.tex` and `figure-snippets.tex` in a temporary folder and fails
if the log contains an error, an overfull box, or an undefined reference.

## Design notes

- The layout parameters are deliberately hard-coded in one place. If you need a different
  page size or font size, change it in the preamble once — do not patch individual figures.
- `assets/preview.png` is the annotated template sheet the reports were measured against.
  The template follows the four finished reports, which use a slightly larger title/author
  scale and the `II` header. The five differences are listed in
  `references/latex-layout-spec.md` §1, with the exact lines to change if you prefer to match
  the sheet instead.
- Schematics are redrawn in TikZ; photographs are never redrawn. A redrawn screenshot stops
  being evidence.
- Figures whose "data points" are photographs (a matrix of oscilloscope captures) are laid
  out as a coordinate system, not as a table with images in cells.
- A curve is only called a fit when it comes from a physical model. Joining measured points
  is labelled as a smooth join.
- Text that talks about the report instead of the physics — production notes, hedging,
  "the source does not say" — is removed, not softened.

## Adding your own report

If you produce another report with this template, add a short case file under
`references/` following the structure of `worked-examples.md`: source form, structural
decisions, figure strategy, data, failures, verification. That is what makes the skill
useful after the first reading.

## Publishing to GitHub

This directory is already in repository shape. After `git init` and the first commit:

```bash
git init
git add .
git commit -m "Initial commit: modern physics experiment report skill"
git branch -M main
git remote add origin https://github.com/<you>/artifact-template-modern-physics-experiment-report.git
git push -u origin main
```

The repository is about 4.9 MB, dominated by `assets/reference.docx` (4.4 MB). That is well
inside GitHub's per-file limit, but if you prefer a lean repository you can drop the docx
and keep only `preview.png` plus the LaTeX assets — the LaTeX route does not read it.

## License

MIT — see `LICENSE`. Replace the copyright holder line before publishing if you fork it.

## Note on the reference files

`assets/reference.docx`, `assets/preview.png` and `artifact-template.json` are the retained
visual reference for the template. `SKILL.md` instructs agents not to modify them; keep them
in the repository so the Word route stays reproducible.
