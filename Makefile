



VENV_DIR = .venv
ENGINEERING_DIR = src/engineering
ANALYTICS_DIR = ../analytics




.PHONY: setup
setup:

	rm -rf ${VENV_DIR}
	@echo "Criando ambiente virtual..."
	python3 -m venv ${VENV_DIR}
	
	@echo "Ativando o ambiente virtual e instalando dependencias..."
	. ${VENV_DIR}/bin/activate && \
	pip install -r requirements.txt


.PHONY: predict
predict:

	@echo "Ativando o ambiente virtual e instalando dependencias..."
	. ${VENV_DIR}/bin/activate && \
	cd src/analytics && \
	python predict_fiel.py


.PHONY: run
run:
	@echo "Ativando ambiente virtual..."
	. ${VENV_DIR}/bin/activate && \
	cd src/engineering && \
	python get_data.py && \
	cd ../analytics && \
	python pipeline_analytics.py


.PHONY: all
all: setup run predict