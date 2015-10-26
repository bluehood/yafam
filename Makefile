DC := dmd

.PHONY: parser
all: fam parser

parser: parserMain.d yafam/build/parser.d yafam/runtime/types.d
	$(DC) $^ -ofparser.x
	
fam: main.d yafam/runtime/*.d
	$(DC) $^ -offam

.PHONY: clean
clean:
	rm -f *.o fam parser.x
