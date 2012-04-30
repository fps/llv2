.PHONY: llilv.so

llilv.so:
	swig -c++ -lua -I/usr/include/lilv-0/lilv/ llilv.i
	g++ -o llilv.so llilv_wrap.cxx -export-dynamic -Wall -shared -fPIC -I /usr/include/lua5.1 -I /usr/include/lilv-0/lilv/ -llilv-0 -llua5.1
