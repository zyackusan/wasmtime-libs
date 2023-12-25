WORK_DIR = $(shell pwd)
SRC_DIR = $(WORK_DIR)/src
SRC_WASMTIME_DIR = $(SRC_DIR)/wasmtime
SRC_WASMTIME_C_API_INCLUDE_DIR = $(SRC_WASMTIME_DIR)/crates/c-api/include
SRC_WASM_C_API_INCLUDE_DIR = $(SRC_WASMTIME_DIR)
SRC_WASMTIME_CPP_INCLUDE_DIR = ${SRC_WASMTIME_DIR}/crates/c-api/wasm-c-api/include
SRC_WABT_DIR = $(SRC_DIR)/wabt
BUILD_DIR = $(WORK_DIR)/build
BIN_DIR = $(BUILD_DIR)/bin
LIB_DIR = $(BUILD_DIR)/lib
INCLUDE_DIR = $(BUILD_DIR)/include

init:
	mkdir -p \
		$(SRC_DIR) \
		$(BIN_DIR) \
		$(LIB_DIR) \
		$(INCLUDE_DIR)

clean:
	rm -rf \
		$(SRC_DIR) \
		$(BUILD_DIR)

download-wasmtime:
	git clone -b v16.0.0 https://github.com/bytecodealliance/wasmtime.git $(SRC_WASMTIME_DIR) --depth 1 \
	&& cd $(SRC_WASMTIME_DIR) \
	&& git submodule update --init \
	&& cd ${WORK_DIR}

download-wasmtime-cpp:
	git clone https://github.com/bytecodealliance/wasmtime-cpp.git $(SRC_WASMTIME_CPP_DIR) --depth 1

download-wabt:
	git clone -b 1.0.34 https://github.com/WebAssembly/wabt.git $(SRC_WABT_DIR) --depth 1 \
	&& cd $(SRC_WABT_DIR) \
	&& git submodule update --init \
	&& cd ${WORK_DIR}

download: \
	download-wasmtime \
	download-wasmtime-cpp \
	download-wabt

build-wasmtime-bin:
	cd $(SRC_WASMTIME_DIR) \
	&& cargo build --release \
	&& cp target/release/wasmtime $(BIN_DIR)

build-wasmtime-staticlib:
	cd $(SRC_WASMTIME_DIR) \
	&& cargo build --release -p wasmtime-c-api \
	&& cp target/release/libwasmtime.a $(LIB_DIR) \
	&& cd $(SRC_WASMTIME_C_API_INCLUDE_DIR) \
	&& cp --parents -r . $(INCLUDE_DIR)

build-wasmtime-cpp:
	cd ${SRC_WASMTIME_CPP_INCLUDE_DIR} \
	&& cp --parents -r . ${INCLUDE_DIR} \
	&& cd ${SRC_WASMTIME_CPP_INCLUDE_DIR} \
	&& cp --parents -r . ${INCLUDE_DIR}

build-wabt:
	cd $(SRC_WABT_DIR) \
	&& make clang-release \
	&& cp ./out/clang/Release/wasm2wat $(BIN_DIR) \
	&& cp ./out/clang/Release/wat2wasm $(BIN_DIR)

build: \
	build-wasmtime-bin \
	build-wasmtime-staticlib \
	build-wasmtime-cpp \
	build-wabt

all: \
	init \
	download \
	build