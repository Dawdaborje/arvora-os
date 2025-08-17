default:
	./build.sh

build-calameres:
	./build_with_calameres.sh

clean:
	echo "Cleaning..."
	rm -rf work/
	rm -rf output
	rm -rf out/
