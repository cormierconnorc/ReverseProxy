PROG = ReverseProxy

compile:
	ghc -O2 --make $(PROG) -threaded

clean:
	rm -f *.hi *.o *~ *#

install:
	mkdir /etc/reverse_proxy
	cp proxy.conf /etc/reverse_proxy
	cp ReverseProxy /usr/bin

uninstall:
	rm -f /etc/reverse_proxy/proxy.conf
	rmdir /etc/reverse_proxy
	rm -f /usr/bin/ReverseProxy
