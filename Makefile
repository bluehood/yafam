DC := dmd

.PHONY: default
default:
	echo "no default target"

build: yafam/build/*.d yafam/runtime/types.d
	$(DC) $^ -ofbin/parser
	
runtime: yafam/runtime/*.d
	$(DC) $^ -ofbin/yafam

.PHONY: clean
clean:
	rm -f *.o \
                bin/yafam \
                bin/parser \
                yafam/runtime/rules.d \
                yafam/runtime/defs.d
