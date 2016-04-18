all: bin/hello

bin/hello: obj/hello.o obj/main.o
	gcc -o bin/hello obj/main.o obj/hello.o

obj/hello.o: src/hello.c
	gcc -c -o obj/hello.o src/hello.c -Iinclude

obj/main.o: src/main.c
	gcc -c -o obj/main.o src/main.c -Iinclude

clean:
	rm obj/hello.o
	rm obj/main.o
	rm bin/hello 
