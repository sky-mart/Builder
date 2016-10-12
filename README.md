# Builder

Разберусь наконец с тем, как происходит сборка проектов, что такое статические и динамические библиотеки, и какие есть инструменты для автоматизации сборки.


**1**. Когда вся программа состоит из одного файла, скомпилировать и скомпоновать проект можно одной командой
```bash
gcc file_name
```
Результат будет находиться в файле a.out, который запускается как и все исполняемые файлы
```bash
./a.out
```
Чтобы имя исполняемого файла было prog_name, нужно дописать
```bash	
gcc file_name -o prog_name
```
Насколько я понимаю, -o -- значит output.
Запускать мы, соответственно, будем
```bash
./prog_name
```
Иногда, по умолчанию, файл создается неисполняемый, тогда системе нужно дополнительно указать на это
```bash
chmod +x prog_name
```

**2**. В упрощенном варианте процесс сборки состоит из этапов компиляции и компоновки. Команда из пункта 1 объединяет оба этапа и выдает исполняемый файл. Этапы можно выполнить раздельно. К примеру,
```bash
gcc -c file.c
```
скомпилирует файл file.c и создаст объектный файл file.o, в котором уже будет лежать машинный код, а
```bash
gcc file.o -o prog_name
```
скомпонует объектный файл file.o с другими объектными файлам, в нашем простом примере с системными библиотеками. GCC производит компоновку тогда, когда входной файл имеет расширение .o.

**3**. Если проект состоит из нескольких файлов, то можно указать их все
```bash
gcc file1.c file2.c header.h
```
На моей системе (clang apple llwm), к сожалению нельзя указать имя исполняемого файла.

Можно отдельно провести компиляцию всех исходников, а потом скомпоновать их все вместе. В случае изменений в одном файле, не нужно будет перекомпилировать остальные.
```bash
gcc -c file1.c
gcc -c file2.c
gcc file1.o file2.o header.h
```

**4**. На самом деле GCC компилирует файлы в 4 этапа:

  1) Предобработка
```bash
cpp file.c > file.i
```
  Вставляет #include-файлы, расписывает макросы

  2) Компиляция предобработанного файла в ассемблер
```bash
gcc -S file.i -o file.s
```
  В .s-файле лежит код программы на языке Ассемблера

  3) Ассемблирование
```bash
as file.s -o file.o
```
  Конвертирует код на ассемблере в машинный код

  4) Компоновка
```bash
ld -o prog_name file.o ...libraries...
```
  Компонует объектный файл с библиотеками

  Увидеть все эти этапы можно добавив опцию -v
```bash
gcc -v file.c -o prog_name
```

**5**. Статические библиотеки. Компонуя программу со статической библиотекой, GCC копирует нужный код из библиотеки в итоговый исполняемый файл. Получить статическую библиотеку можно с помощью команды
```bash
ar rcs libfilename.a filename.o
```
Принято называть библиотеки с префиксом lib, как выяснится впоследствии, это даже полезно.

Для сборки нужно указать библиотеку в списке файлов на входе gcc
```bash
gcc main.c filename_header.h libfilename.a
```

**6**. Динамические библиотеки. Компонуя же программу с динамической библиотекой, GCC всего лишь создает в исполняем файле табличку для используемых функций, и перед запуском программы операционная система подгружает необходимые функции. Создаются динамические библиотеки с помощью команды
```bash
gcc -dynamiclib -o libhello.dylib hello.c
```
А проект собирается с указанием папки библиотеки и ее имени
```bash
gcc header.h main.c -Ldir -llibname
```
libname - это то, что находится между lib и .dylib


**7**. Пути к библиотекам и заголовочным файлам. 

Аргумент -Idir указывает GCC директорию, где искать заголовочные файлы.
Аргумент -Ldir указывает GCC директорию, где искать файлы библиотек, неважно динамических или статических.
Аргумент -llibname указывает GCC какую именно библиотеку использовать для сборки проекта.

Пример структуры проекта:

	bin/
	
	include/
	
		hello.h
		
	lib/
	
	obj/
	
	src/
	
		hello.c
		
		main.c

Для сборки проекта со статической библиотекой нужно выполнить следующие команды:
```bash
gcc -c -o obj/hello.o src/hello.c
ar rcs lib/libhello.a obj/hello.o
gcc -o bin/hello src/main.c -Iinclude -Llib -lhello
```
Для сборки же проекта с динамической библиотекой:
```bash
gcc -dynamiclib -o bin/libhello.dylib src/hello.c
gcc -o bin/hello src/main.c -Iinclude -Lbin -lhello
```

**8**. Утилита make. Эта утилита предназначена для автоматизации процесса сборки. В файле makefile задаются правила и их пререквизиты в формате

rule: pre-requisite-1 pre-requisite-2
		command

В качестве правил и пререквизитов можно использовать имена файлов. В этом случае если результат правила существует и он не старше необходимых файлов, то правило выполняться не будет.

Возможностей в утилите достаточно много: от переменных и шаблонных правил до бог знает чего еще, но нас утилита make интересует как промежуточный этап к более абстракным инструментам.
