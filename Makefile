# Makefile para proyectos Julia con investigación
.PHONY: test test-verbose test-coverage coverage format clean clean-cov setup resolve instantiate precompile reload benchmark dev-check profile quarto-preview quarto-render jupyter docs pre-commit ci-local all help

# Variables
JULIA := julia
PROJECT := --project=.
SCRIPTS_DIR := scripts
DEV_DIR := dev
BENCHMARK_DIR := benchmark
RESEARCH_DIR := research

# === TESTING ===
test:
	$(JULIA) $(PROJECT) -e "using Pkg; Pkg.test()"

test-verbose:
	$(JULIA) $(PROJECT) -e "using Pkg; Pkg.test(; test_args=[\"--verbose\"])"

test-coverage:
	$(JULIA) $(PROJECT) --code-coverage=user -e "using Pkg; Pkg.test()"

# === COVERAGE ===
coverage: test-coverage
	@echo "📊 Generando reporte de cobertura..."
	$(JULIA) $(PROJECT) -e "include(\"utils/CoverageConfig.jl\"); run_coverage()"

# === DEVELOPMENT ===
dev-check:
	@echo "🔍 Verificando optimización del código..."
	test -f $(DEV_DIR)/performance_check.jl && $(JULIA) $(PROJECT) $(DEV_DIR)/performance_check.jl || \
	echo "⚠️ No $(DEV_DIR)/performance_check.jl encontrado"

profile:
	@echo "💾 Analizando allocaciones..."
	test -f $(DEV_DIR)/profile_allocations.jl && $(JULIA) $(PROJECT) $(DEV_DIR)/profile_allocations.jl || \
	echo "⚠️ No $(DEV_DIR)/profile_allocations.jl encontrado"

# === RESEARCH ===
jupyter:
	@echo "📓 Iniciando Jupyter Lab..."
	test -d $(RESEARCH_DIR)/notebooks && jupyter lab $(RESEARCH_DIR)/notebooks/ || \
	echo "⚠️ No $(RESEARCH_DIR)/notebooks/ encontrado"

quarto-preview:
	@echo "👀 Preview Quarto..."
	test -d $(RESEARCH_DIR)/quarto && quarto preview $(RESEARCH_DIR)/quarto/ || \
	echo "⚠️ No $(RESEARCH_DIR)/quarto/ encontrado"

quarto-render:
	@echo "📖 Renderizando Quarto..."
	test -d $(RESEARCH_DIR)/quarto && quarto render $(RESEARCH_DIR)/quarto/ || \
	echo "⚠️ No $(RESEARCH_DIR)/quarto/ encontrado"

# === BENCHMARKING ===
benchmark:
	@echo "⚡ Ejecutando benchmarks..."
	test -f $(BENCHMARK_DIR)/run.jl && $(JULIA) $(PROJECT) $(BENCHMARK_DIR)/run.jl || \
	echo "⚠️ No $(BENCHMARK_DIR)/run.jl encontrado"

# === PACKAGE MANAGEMENT ===
resolve:
	$(JULIA) $(PROJECT) -e "using Pkg; Pkg.resolve()"

instantiate:
	$(JULIA) $(PROJECT) -e "using Pkg; Pkg.instantiate()"

precompile:
	$(JULIA) $(PROJECT) -e "using Pkg; Pkg.precompile()"

setup: instantiate precompile
	@echo "✅ Proyecto configurado"

reload:
	$(JULIA) $(PROJECT) -e "using Pkg; Pkg.activate(\".\")"

# === FORMATTING ===
format:
	@echo "🎨 Formateando código Julia..."
	test -f $(SCRIPTS_DIR)/format_files.jl && $(JULIA) $(SCRIPTS_DIR)/format_files.jl || \
	$(JULIA) $(PROJECT) -e "using JuliaFormatter; format(\".\", BlueStyle())"

# === CLEANUP ===
clean-cov:
	@echo "🧹 Limpiando archivos .cov..."
	test -f $(SCRIPTS_DIR)/clean_cov_files.jl && $(JULIA) $(SCRIPTS_DIR)/clean_cov_files.jl || \
	find . -name "*.cov" -delete

clean: clean-cov
	@echo "🧹 Limpieza completa..."
	find . -name "*.DS_Store" -delete
	find . -name "*.tmp" -delete
	find . -name "*~" -delete
	test -d $(RESEARCH_DIR)/quarto/_output && rm -rf $(RESEARCH_DIR)/quarto/_output || true

# === DOCUMENTATION ===
docs:
	test -f docs/make.jl && $(JULIA) $(PROJECT) docs/make.jl || echo "⚠️ No docs/make.jl encontrado"

# === WORKFLOWS COMBINADOS ===
research: jupyter
	@echo "🔬 Entorno de investigación listo"

dev: dev-check profile
	@echo "🛠️  Análisis de desarrollo completado"

pre-commit: format test clean-cov
	@echo "🚀 Listo para commit"

ci-local: test-coverage coverage dev-check
	@echo "🧪 Simulación CI completa"

all: setup test coverage benchmark dev format clean
	@echo "🏁 Workflow completo ejecutado"

# === HELP ===
help:
	@echo "Comandos disponibles:"
	@echo "  test           - Ejecutar tests"
	@echo "  coverage       - Generar reporte cobertura"
	@echo "  dev-check      - Verificar optimización código"
	@echo "  benchmark      - Ejecutar benchmarks"
	@echo "  jupyter        - Iniciar Jupyter Lab"
	@echo "  quarto-preview - Preview sitio Quarto"
	@echo "  quarto-render  - Renderizar sitio Quarto"
	@echo "  format         - Formatear código (BlueStyle)"
	@echo "  clean          - Limpiar archivos temporales"
	@echo "  setup          - Configurar proyecto"
	@echo "  research       - Entorno investigación"
	@echo "  pre-commit     - Preparar para commit"
	@echo "  help           - Mostrar esta ayuda"
