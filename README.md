### Thanks

- https://github.com/immortalwrt/immortalwrt/releases/tag/v24.10.1

### Usage

```bash

# setup
./setup.sh

# exec; workspace in ~/immortalwrt/24.10.1
./exec.sh zsh

cd ~/immortalwrt/24.10.1
make menuconfig
make -j32 V=s
```
