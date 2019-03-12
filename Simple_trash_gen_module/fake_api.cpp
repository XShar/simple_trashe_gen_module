#include "pch.h"
#include <windows.h>
#include <stdint.h>
#include <iostream>
#include "fake_api.h"

extern "C" {
	void __cdecl  debug_print(unsigned line) {
		std::cout << "debug: " << line << "\n";
	}
};

static uint32_t eax_random = 0;

static void fake_api_calls(void) {

	//Рандомное число, для вызова API в случайном порядке
	eax_random = do_Random_EAX(0, 9);

	//Рандомно вызываем API
	if (eax_random == 0) {
		LPSTR wiapi1 = GetCommandLineA();
	}
	else if (eax_random == 1) {
		DWORD wiapi2 = GetTickCount();
	}
	else if (eax_random == 2) {
		DWORD wiapi3 = GetTickCount();
	}
	else if (eax_random == 3) {
		DWORD wiapi4 = GetLastError();
	}
	else if (eax_random == 4) {
		DWORD wiapi5 = GetVersion();
	}
	else if (eax_random == 5) {
		HANDLE wiapi6 = GetCurrentProcess();
	}
	else if (eax_random == 6) {
		HANDLE wiapi7 = GetProcessHeap();
	}
	else if (eax_random == 7) {
		LPWCH wiapi8 = GetEnvironmentStrings();
	}
	else if (eax_random == 8) {
		HANDLE wiapi9 = GetProcessHeap();
	}
	else if (eax_random == 9) {
		LANGID wiapi10 = GetSystemDefaultLangID();
	}
}

void fake_api_instruction_gen(uint32_t instruction, uint32_t api) {
	//Генерация случайных иснтрукций, нужного числа
	for (uint32_t i = 0; i < instruction; i++) {
		do_fake_instr();
	}

	//Вызовы случайных API, нужного числа
	for (uint32_t i = 0; i < api; i++) {
		fake_api_calls();
	}
}