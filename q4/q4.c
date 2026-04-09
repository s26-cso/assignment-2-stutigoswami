#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

int main() {
    char op[8];           // operation name
    char libname[20];     // "lib" + op + ".so" + null terminator
    int num1, num2;


    while (scanf("%s %d %d", op, &num1, &num2) != EOF) {
        
        //  build "lib<op>.so"
        strcpy(libname, "lib");
        strcat(libname, op);
        strcat(libname, ".so");

        // load the shared lib
        void* handle = dlopen(libname, RTLD_LAZY);

        // fucnpointer loading
        int (*func)(int, int) = dlsym(handle, op);

   
        printf("%d\n", func(num1, num2));

        //unload lib for memory reasons :P
        dlclose(handle);
    }
    return 0;
}