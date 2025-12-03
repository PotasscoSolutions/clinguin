SHELL:=/bin/bash
APPLICATION_NAME = clinguin

angular:
	cd angular_frontend && npx ng build --base-href ./
	rm -rf clinguin/client/presentation/frontends/angular_frontend/clinguin_angular_frontend
	cp -R angular_frontend/dist/clinguin_angular_frontend \
	      clinguin/client/presentation/frontends/angular_frontend
	python3 -m pip uninstall $(APPLICATION_NAME) -y
	python3 -m pip install ./[doc]

