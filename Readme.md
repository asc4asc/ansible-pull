ansible-pull -U https://github.com/asc4asc/ansible-pull.git -C update-debian

Wenn hosts:all gesetzt ist, muss es so aufgerufen werden.

ansible-pull -i 'localhost,' -U https://github.com/asc4asc/ansible-pull.git -C update-debian
