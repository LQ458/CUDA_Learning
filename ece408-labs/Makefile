ALL_MP = MP1 MP2 MP3 MP4 MP5.1 MP5.2 MP6 MP7
all:
	@for d in $(ALL_MP); do make -C $$d all; done
run: all
	@for d in $(ALL_MP); do echo "=== $$d ==="; make -C $$d run; done
clean:
	@for d in $(ALL_MP); do make -C $$d clean; done
