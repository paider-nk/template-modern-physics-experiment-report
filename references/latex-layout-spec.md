# LaTeX layout specification and build checks

This file records the exact, working LaTeX setup used for the four reports in
`references/worked-examples.md`. `assets/latex/report-template.tex` is the same
preamble with placeholder content; start a new report by copying it.

## 1. Fixed layout parameters

| Item | Value |
| --- | --- |
| Class | `ctexart`, options `[UTF8,zihao=5,a4paper]` |
| Page | A4, margins left/right 2.0 cm, top/bottom 2.2 cm |
| Body | 五号宋体 (`zihao=5`), line spread 1.5, first-line indent 2 em, `\parskip` 0 |
| Latin / math | Times New Roman (`\setmainfont`), math italic per `amsmath` |
| Chinese fonts | `\setCJKmainfont{SimSun}[BoldFont=SimHei,ItalicFont=KaiTi]` |
| Level-1 heading | 小四黑体, numbered `1`, `2`, … |
| Level-2 heading | 五号黑体, numbered `2.1`, `2.2`, … |
| Level-3 heading | 五号黑体 (only when the procedure needs a third level) |
| Figure caption | below figure, 小五宋体, centered, one sentence |
| Table caption | above table, 小五宋体 (bold label only if the template asks), centered |
| Tables | three-line (`booktabs`: `\toprule`/`\midrule`/`\bottomrule`), no vertical rules |
| References | 小五宋体, `[\arabic*]` labels, hanging indent, `leftmargin=2.2em` |
| Header | `MODERN PHYSICS EXPERIMENT II`, `\zihao{-5}` italic Times, 0.4 pt rule |
| Footer | page number, `\zihao{-5}` |
| Title block | `\zihao{3}\heiti` title, `\zihao{5}` author, `（学院，学校，城市 邮编）`, `E-mail：` |
| Abstract | `\noindent\textbf{摘要：}` single paragraph, no first-line indent |
| Keywords | `\noindent\textbf{关键词：}` items separated by `；` |

Equation numbering, `\ref`/`\eqref`, and figure/table counters are left to LaTeX;
never hard-code “图 3” or “式 (5)” in prose.

### Where this differs from the retained reference sheet

`assets/preview.png` is the annotated template sheet the reports were originally measured
against. The four finished reports — and therefore this template — differ from it in five
places. Both are defensible; the reports took the “slightly larger, cleaner” side because
the annotated sheet was designed for a Word workflow.

| Item | Reference sheet (`preview.png`) | This template (= the four reports) |
| --- | --- | --- |
| Title | 小二黑体加粗 | `\zihao{3}` 黑体 (三号) |
| Author line | 小四仿宋 | `\zihao{5}` 宋体 |
| Affiliation | 六号宋体 | `\zihao{5}` 宋体 |
| 摘要 / 关键词 | 标签小五黑体 + 正文小五宋体 | `\zihao{5}` 宋体，标签用 `\textbf` |
| Header | `Modern Physics Experiment I` | `MODERN PHYSICS EXPERIMENT II` |

If the instructor grades against the sheet rather than against the previous reports, change
these five lines in the preamble — nothing else depends on them. Do not mix the two: pick
one scale for the whole document.

Note that “加粗” on a SimHei heading cannot be produced with `\bfseries` — SimHei has no bold
shape and XeLaTeX raises `Font shape TU/SimHei(0)/b/n undefined`. If真 bold is required,
either substitute a family with a bold face or use a synthetic `\heiti` heading at the
larger size, which is what the reports did.

## 2. Build and verification

```powershell
# PowerShell; adjust the TinyTeX path to the local installation
$bin = 'I:\work output\latex-report\tinytex\TinyTeX\bin\windows'
Set-Location <project-dir>
& "$bin\xelatex.exe" -interaction=nonstopmode main.tex
& "$bin\xelatex.exe" -interaction=nonstopmode main.tex      # second pass: page numbers, refs
Select-String -Path main.log -Pattern '^!|Overfull|undefined'
Select-String -Path main.log -Pattern 'Output written'
```

Acceptance: no `^!` line, no `Overfull \hbox`, no “Reference … undefined”, and an
`Output written` line with the expected page count. A zero exit code alone is not
enough — XeLaTeX often “succeeds” with 0 pages of output after a fatal error.

Visual review (PDF → page images, then look at them):

```powershell
$node = '<node.exe>'
$cli  = '<...>/@deepseek-ai/libreoffice-kit/lib/cli.js'
& $node $cli render --input <project-dir>/main.pdf `
      --output-dir <a-directory-that-does-not-exist> --pages 1,4,9 --dpi 120
```

- `--output-dir` **must not exist**; `convert --output <existing file>` fails with
  `EEXIST`, so delete the target first.
- Check: title page, first equation page, every figure page, every table page,
  the references page, and the last page. Look for clipped figures, labels sitting
  on lines, empty half-pages, and duplicated captions.

Installing a missing package (TinyTeX): `tlmgr update --self` first, then
`tlmgr install <pkg>`. Otherwise `tlmgr` refuses with “tlmgr itself needs to be updated”.

## 3. Errors that actually happened, and their fixes

| Symptom | Cause | Fix |
| --- | --- | --- |
| `Package xeCJK Error: Control sequence \heiti is already defined` | `\newCJKfontfamily` for 黑体/宋体/仿宋/楷书 | delete those lines; `ctexart` already defines `\heiti \songti \fangsong \kaishu` |
| `Font shape TU/SimHei(0)/b/n undefined` | `\bfseries` after `\heiti` | drop `\bfseries`; SimHei has no bold face |
| `Package caption Error: \zihao {-5} undefined` | `\captionsetup{font={\zihao{-5}}}` | `\DeclareCaptionFont{xiaowu}{\zihao{-5}}` then `font=xiaowu` |
| `\mathrm allowed only in math mode` in a pgfplots label | `\mathrm` in `ylabel` | use `\text{mV}` |
| First paragraph after a heading loses its indent | default paragraph style | `\usepackage{indentfirst}` |
| ` \phantomsection` undefined | no `hyperref` loaded | drop `\phantomsection`/`\addcontentsline` |
| Two “参考文献” headings | `\section{参考文献}` plus `thebibliography` | define the list with `enumerate`, or `\renewcommand{\refname}{参考文献}` |
| Fit curve is nearly a horizontal line | pgfplots evaluates `cos`/`sin` in **degrees** | convert modulation depth `m` from rad to deg (`m*180/pi`) before writing it into the expression |
| Half-empty page before a large figure | `[H]` cannot split | use `[htbp]` for tall photo figures, keep `[H]` only for small ones |
| Reference list split across pages | page break inside the list | `\needspace{11\baselineskip}` before the section, or `\needspace` after loading `needspace` |

## 4. Figures: size and aspect conventions

Pick the width from the figure's role, not from the source image size.

| Case | Setting |
| --- | --- |
| Two photos side by side | `minipage[b]{0.49\linewidth}` + `width=\linewidth` (or `0.48` with `\hfill`) |
| Four photos in one row | `minipage[b]{0.235\textwidth}` + `width=0.97\linewidth` |
| Three- or five-photo grid | `minipage[b]{0.47\linewidth}`, 2 per row, last row centered |
| Single apparatus photo | `height=6.1cm,keepaspectratio` (portrait) or `width=0.74\linewidth` |
| Theory/principle TikZ | 0.80–0.95 `\linewidth`, set the natural width in coordinates |
| Data plot (pgfplots) | `width=.80\linewidth, height=6.2cm` |
| Wide block diagram overflowing the text block | prefix the `tikzpicture` with `x=0.86cm,y=1cm` (compresses horizontally, keeps font size) instead of `\resizebox` |

Side-by-side images must share an aspect ratio **before** typesetting. Pre-process
with Pillow: resample to the display width, pad onto a common canvas (e.g. 6:5 or
4:5), save JPEG q≈82 at ~350 dpi. A mixed set of portrait/landscape originals
otherwise produces rows of unequal height, which readers notice immediately.

Do not put production notes in captions (“按教材图 15.1 重绘”, “保留原图一”,
“（图中虚线仅作示意，不作定量拟合）”). The caption states what the figure shows;
methodological caveats belong in the prose, stated once and positively.

## 5. TikZ conventions

- Font inside a figure: `font=\zihao{6}` on the `tikzpicture` or per node.
- Boxes: `draw,fill=white,align=center,minimum height=0.7cm,minimum width=1.6cm`.
  `fill=white` is what keeps a light-path arrow from showing through a component.
- Arrows: `>=Stealth`; structure lines 0.6–0.8 pt; `dashed` for a different physical
  meaning than solid, `dotted` for a third.
- Labels must never sit on a line or a box edge. Place them at `pos=` on the arrow,
  or in empty space, and check the rendered page — this is the most common defect.
- Do not put `\draw plot` inside a `scope` with `shift=`; the coordinates are
  transformed and the curve comes out skewed. Plot first, then shift the whole
  `tikzpicture` in the page, or use pgfplots.
- `\clip` inside a `scope` can silently swallow the whole drawing; avoid it.

## 6. Tables

- Three-line tables only. `\toprule`, header row, `\midrule`, body, `\bottomrule`.
- Long first columns: `tabularx` with `>{\raggedright\arraybackslash}p{3.6cm}X`.
- Text that must not wrap: bind it with `\,` inside the math (`LiNbO$_3$`).
- When the object of a table is really a set of labelled positions (for example
  “waveplate position × bias voltage”, each cell a photo), draw it as a coordinate
  system in TikZ instead of a grid; see §7 of `assets/latex/figure-snippets.tex`.

## 7. Prose conventions enforced during revision

The four reports converged on the same editorial rules; apply them by default.

- Delete defensive/meta sentences: “仅凭本实验的数据不能……”, “由于条件所限……”,
  “该判据只是定性判断……”, “图中虚线仅为视觉引导……”, “本文记录未提供平行样……”,
  “不能证明……”, “并不意味着……”. Replace each with either a positive statement
  of what was done, or a single factual limitation stated once.
- Delete sourcing narration: “工作簿记录的”“原理资料给出的”“按系统说明图三重绘”,
  “此处保留实测计算值，不以文献值替代”. Say “实测值”“该波段信号源的典型范围”.
- Keep numbers, units, and significant figures exactly as measured; never re-round
  to make a fit look better, and never add uncertainty without repeat data.
- A trend line that is not a physical fit is called “平滑连线”, not “拟合”.
- When the user asks to remove reference entries, renumber the remaining list and
  update every citation marker in the prose in the same pass.
