all: src/testing.cr
	crystal build -D preview_mt ./src/testing.cr -o MyApp