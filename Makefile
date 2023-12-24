WORK_DIR = $(shell pwd)
SRC_DIR = $(WORK_DIR)/src
SRC_WASMTIME_DIR = $(SRC_DIR)/wasmtime
SRC_WASMTIME_C_API_INCLUDE_DIR = $(SRC_WASMTIME_DIR)/crates/c-api/include
SRC_WASM_C_API_INCLUDE_DIR = $(SRC_WASMTIME_DIR)
SRC_WASMTIME_CPP_INCLUDE_DIR = ${SRC_WASMTIME_DIR}/crates/c-api/wasm-c-api/include
BUILD_DIR = $(WORK_DIR)/build
LIB_DIR = $(BUILD_DIR)/lib
INCLUDE_DIR = $(BUILD_DIR)/include

init:
	mkdir -p \
		$(SRC_DIR) \
		$(LIB_DIR) \
		$(INCLUDE_DIR)

clean:
	rm -rf \
		$(SRC_DIR) \
		$(BUILD_DIR)

download-wasmtime:
	git clone -b v16.0.0 https://github.com/bytecodealliance/wasmtime.git $(SRC_WASMTIME_DIR) \
	&& cd $(SRC_WASMTIME_DIR) \
	&& git submodule update --init \
	&& cd ${WORK_DIR}

download-wasmtime-cpp:
	git clone https://github.com/bytecodealliance/wasmtime-cpp.git $(SRC_WASMTIME_CPP_DIR)

download: \
	download-wasmtime \
	download-wasmtime-cpp

build-wasmtime:
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

build: \
	build-wasmtime \
	build-wasmtime-cpp

all: \
	init \
	download \
	build