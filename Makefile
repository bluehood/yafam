DC := dmd

.PHONY: parser
all: fam parser

fam: main.d yafam/runtime/*.d
	$(DC) $^ -offam

parser: parserMain.d yafam/build/parser.d yafam/runtime/types.d
	$(DC) $^ -ofparser.x
	
.PHONY: clean
clean:
	rm -f *.o fam parser.x
