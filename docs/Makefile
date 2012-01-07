pdf:
	pdflatex Report.tex && pdflatex Report.tex > /dev/null

clean:
	rm -f {*,*/*}.{aux,toc,log,out}

clobber: clean
	rm -f {*,*/*}.{pdf,ps,dvi}
