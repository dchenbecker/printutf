#!/bin/zsh -xe

WORKDIR=$(mktemp -d --tmpdir utfprint.XXXXXXXXXX)
INPUTFILE=$WORKDIR/srcfile
TEMPTEX=$WORKDIR/output.tex

echo "Saving input to $INPUTFILE, LaTeX to $TEMPTEX"

cat > $INPUTFILE

MAIL_DATE="$(formail -czx Date: < $INPUTFILE)"
MAIL_FROM="$(formail -czx From: < $INPUTFILE)"
SUBJECT="$(formail -czx Subject: < $INPUTFILE | sed 's/&/\\&/g')"

cat > $TEMPTEX <<EOF
\documentclass{article}
\usepackage{ucharclasses}
\usepackage{fontspec}
\usepackage[margin=0.75in]{geometry}
\usepackage{fancyhdr}
\usepackage{lastpage}
\pagestyle{fancy}
\lhead{\bfseries Subject: $SUBJECT\\\\\normalfont From: $MAIL_FROM}
\rfoot{$MAIL_DATE}
\cfoot{}
\lfoot{Page \thepage\ of \pageref{LastPage}}
\renewcommand{\headrulewidth}{0.6pt}
\renewcommand{\footrulewidth}{0.2pt}
\setDefaultTransitions{\fontspec{DejaVu Sans Mono}}{}
\setTransitionsForCJK{\fontspec{AR PL UKai TW}}{}
\begin{document}
\begin{verbatim}
EOF

formail -f -I Date: -I From: -I Subject: >> $TEMPTEX < $INPUTFILE

cat >> $TEMPTEX <<EOF
\end{verbatim}
\end{document}
EOF

cd $WORKDIR
xelatex $TEMPTEX && xelatex $TEMPTEX > latex.log
pdfnup output.pdf --frame true --scale 0.95 --paper letter > nup.log
lpr output-nup.pdf

rm -rf $WORKDIR


