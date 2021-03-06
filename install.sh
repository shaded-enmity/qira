#!/bin/bash -e

# default is just pip, but on things like arch where python 3 is default, it's pip2
PIP="pip"

unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
  # we need pip to install python stuff
  # build for building qiradb and stuff for flask like gevent
  if [ $(which apt-get) ]; then
    echo "installing apt packages"
    sudo apt-get -y install build-essential python-dev python-pip debootstrap libjpeg-dev zlib1g-dev unzip wget graphviz

    # grr, capstone should be a ubuntu package
    if [ ! -f /usr/lib/libcapstone.so ]; then
      # now we need capstone so the user can see assembly
      if [[ $(uname -m) == 'i386' ]]; then
        wget -O /tmp/cs.deb http://www.capstone-engine.org/download/2.1.2/capstone-2.1.2_i386.deb
      else
        wget -O /tmp/cs.deb http://www.capstone-engine.org/download/2.1.2/capstone-2.1.2_amd64.deb
      fi
      sudo dpkg -i /tmp/cs.deb
      rm /tmp/cs.deb
    fi
    
    # only python package we install globally
    sudo $PIP install virtualenv
  elif [ $(which pacman) ]; then
    echo "installing pip"
    sudo pacman -S base-devel python2-pip
    PIP="pip2"
  elif [ $(which yum) ]; then
    sudo yum install python-pip python-devel gcc gcc-c++ python-virtualenv glib2-devel
  fi

  if [ $(qemu/qira-i386 > /dev/null; echo $?) == 1 ]; then
    echo "QIRA QEMU appears to run okay"
  else
    echo "building QEMU"
    ./qemu_build.sh
  fi
fi

# we install more than we strictly need here, because pip is so easy
# should this use sudo?
# can ./qiradb go in requirements?
echo "installing pip packages"
virtualenv venv
source venv/bin/activate
$PIP install --upgrade -r requirements.txt 

echo "making symlink"
sudo ln -sf $(pwd)/qira /usr/local/bin/qira

echo "***************************************"
echo "  Thanks for installing QIRA"
echo "  Check out README for more info"
echo "  Or just dive in with 'qira /bin/ls'"
echo "  And point Chrome to localhost:3002"
echo "    ~geohot" 

