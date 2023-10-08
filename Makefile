all : test0 test1 test2 test3 test4

test0: src/testing0.cr
	crystal build -D preview_mt ./src/testing0.cr -o test0

test1: src/testing1.cr
	crystal build -D preview_mt ./src/testing1.cr -o test1

test2: src/testing2.cr
	crystal build -D preview_mt ./src/testing2.cr -o test2

test3: src/testing3.cr
	crystal build -D preview_mt ./src/testing3.cr -o test3

test4: src/testing4.cr
	crystal build -D preview_mt ./src/testing4.cr -o testing4
