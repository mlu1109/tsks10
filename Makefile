NAME = report

all:
	make clean
	pdflatex $(NAME)
	xdg-open $(NAME).pdf
clean:
	rm -f $(NAME).aux $(NAME).bbl $(NAME).blg $(NAME).log $(NAME).pdf $(NAME).toc

