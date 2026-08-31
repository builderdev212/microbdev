.PHONY: clean
clean:
	@find . -type d -name '.gen' -print0 | xargs -0 rm -rf
	@rm -rf *.Xil
	@rm -f *.log
	@rm -f *.jou
