DC := dmd

.PHONY: parser

all: parser

parser: parserMain.d yafam/build/parser.d yafam/runtime/types.d
	$(DC) $^ -ofparser.x
	
