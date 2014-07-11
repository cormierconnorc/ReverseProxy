PROG = ReverseProxy

compile:
	ghc -O2 --make $(PROG) -threaded

clean:
	rm -f *.hi *.o *~ *#
