TESTING := testing/log_on_off testing/test_get_log_ent_size
obj-m := hellow.o
KDIR := /lib/modules/$(shell uname -r)/build
DEBUG_FLAGS += -g -DDEBUG
GPP = g++
GOPTS = -std=c++11
GOTPSSO = -shared -fPIC
default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules EXTRA_CFLAGS="$(DEBUG_FLAGS)"
	sudo cp hellow.ko /lib/modules/$(shell uname -r)/custom/

test_log_on_off: testing/log_on_off.c
	gcc testing/log_on_off.c -o testing/log_on_off

test_get_ent_size: testing/test_get_log_ent_size.c
	gcc testing/test_get_log_ent_size.c -o testing/test_get_log_ent_size

harness: harness/c_harness.cpp default utils/utils.h utils/utils.cpp hellow_ioctl.h \
	harness/Tester.cpp harness/Tester.h tests/echo_sub_dir.so tests/BaseTestCase.h \
	permuter/Permuter.h  permuter/RandomPermuter.so
	$(GPP) $(GOPTS) harness/c_harness.cpp harness/Tester.cpp utils/utils.cpp \
		-I /usr/src/linux-headers-$(shell uname -r)/include/ -ldl -o harness/c_harness

harness_huge: harness/c_harness.cpp default utils/utils.h utils/utils.cpp hellow_ioctl.h \
	harness/Tester.cpp harness/Tester.h tests/echo_sub_dir_huge.so tests/BaseTestCase.h \
	permuter/Permuter.h  permuter/RandomPermuter.so
	$(GPP) $(GOPTS) harness/c_harness.cpp harness/Tester.cpp utils/utils.cpp \
		-I /usr/src/linux-headers-$(shell uname -r)/include/ -ldl -o harness/c_harness

harness_huge: harness/c_harness.cpp default utils/utils.h utils/utils.cpp hellow_ioctl.h \
	harness/Tester.cpp harness/Tester.h tests/echo_sub_dir_big.so tests/BaseTestCase.h \
	permuter/Permuter.h  permuter/RandomPermuter.so
	$(GPP) $(GOPTS) harness/c_harness.cpp harness/Tester.cpp utils/utils.cpp \
		-I /usr/src/linux-headers-$(shell uname -r)/include/ -ldl -o harness/c_harness

tests_c_harness: tests/test_get_log_ent_size.c
	gcc tests/test_get_log_ent_size.c -o tests/test_get_log_ent_size

tests_echo_root_dir: tests/echo_root_dir.cpp
	$(GPP) $(GOPTS) $(GOTPSSO) -Wl,-soname,echo_root_dir.so \
		-o tests/echo_root_dir.so tests/echo_root_dir.cpp
	
tests/echo_sub_dir.so: tests/echo_sub_dir.cpp
	$(GPP) $(GOPTS) $(GOTPSSO) -Wl,-soname,echo_sub_dir.so \
		-o tests/echo_sub_dir.so tests/echo_sub_dir.cpp

tests/echo_sub_dir_big.so: tests/echo_sub_dir_big.cpp
	$(GPP) $(GOPTS) $(GOTPSSO) -Wl,-soname,echo_sub_dir_big.so \
		-o tests/echo_sub_dir_big.so tests/echo_sub_dir_big.cpp

tests/echo_sub_dir_huge.so: tests/echo_sub_dir_huge.cpp
	$(GPP) $(GOPTS) $(GOTPSSO) -Wl,-soname,echo_sub_dir_huge.so \
		-o tests/echo_sub_dir_huge.so tests/echo_sub_dir_huge.cpp

permute: permute.cpp utils/utils.h utils/utils.cpp hellow_ioctl.h
	$(GPP) $(GOPTS) permute.cpp utils/utils.cpp \
		-I /usr/src/linux-headers-$(shell uname -r)/include/ -o permute

permuter/RandomPermuter.so: permuter/RandomPermuter.cpp \
	permuter/RandomPermuter.h utils/utils.h  utils/utils.cpp  hellow_ioctl.h
	$(GPP) $(GOPTS) $(GOTPSSO) -Wl,-soname,RandomPermuter.so \
		-o permuter/RandomPermuter.so permuter/RandomPermuter.cpp utils/utils.cpp \
		-I /usr/src/linux-headers-$(shell uname -r)/include/

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
	rm -f $(TESTING) tests/*.so harness/c_harness permute *.o *.so permuter/*.so
