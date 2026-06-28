BUILD=./build

$(BUILD)/main.gb: $(BUILD) $(BUILD)/main.o $(BUILD)/memory.o  $(BUILD)/vblank.o $(BUILD)/keyboard.o $(BUILD)/input.o  $(BUILD)/sprites.o
	rgblink -o $(BUILD)/main.gb $(BUILD)/main.o $(BUILD)/memory.o $(BUILD)/vblank.o $(BUILD)/keyboard.o $(BUILD)/input.o  $(BUILD)/sprites.o
	rgbfix -v -p 0xFF $(BUILD)/main.gb 

$(BUILD)/main.o $(BUILD)/memory.o  $(BUILD)/vblank.o $(BUILD)/keyboard.o $(BUILD)/input.o  $(BUILD)/sprites.o: ./src/main.asm ./src/memory.asm ./src/vblank.asm ./src/keyboard.asm ./src/input.asm ./src/sprites.asm
	rgbasm -o $(BUILD)/vblank.o ./src/vblank.asm
	rgbasm -o $(BUILD)/memory.o ./src/memory.asm
	rgbasm -o $(BUILD)/main.o ./src/main.asm
	rgbasm -o $(BUILD)/sprites.o ./src/sprites.asm
	rgbasm -o $(BUILD)/keyboard.o ./src/keyboard.asm
	rgbasm -o $(BUILD)/input.o ./src/input.asm

${BUILD}: 
	mkdir -p ${BUILD}