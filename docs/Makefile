GRAPHS = $(wildcard images/*.gv)
TIKZ = $(GRAPHS:.gv=.tex)

pdf:
	pdflatex --shell-escape Report.tex && pdflatex --shell-escape Report.tex > /dev/null

images: $(TIKZ)

%.tex : %.gv
	dot2tex --figonly $< > $@

clean:
	rm -f {*,*/*}.{aux,toc,log,out}

clobber: clean
	rm -f {*,*/*}.{pdf,ps,dvi} images/*.tex
