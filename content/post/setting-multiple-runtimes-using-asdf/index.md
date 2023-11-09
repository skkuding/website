+++
author = "이균서"
title = "asdf를 이용해 다양한 런타임을 설치하고 사용하는 법"
date = "2023-11-09"
description = "asdf 런타임 매니저를 이용해 다양한 런타임을 설치하고 사용하는 법을 알아봅니다."
tags = ["backend"]
+++

## 들어가며

요즘은 다양한 runtime을 이용해 개발을 합니다.  
예를 들어, node.js, python, golang, jdk, rust, ruby 등등..
그래서 이 runtime들을 설치하고 version 관리하는 데에 많은 시간과 비용이 소모됩니다.  
node.js의 경우는 nvm, python은 pyenv, jdk는 sdkman, rust는 rustup, ruby는 rvm 등등..  
그래서 이런 runtime들을 한 곳에서 관리할 수 있는 asdf를 소개합니다.  
본 포스트는 `zsh`과 `ohmyzsh`을 기반으로 설명합니다.

## `asdf`를 `git clone`으로 설치

```zsh
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
```

![asdf git clone한 상태](https://res.cloudinary.com/gyunseo-blog/image/upload/v1698669625/install-asdf-on-ubuntu-linux-and-ohmyzsh-1696765333415.jpeg)

## `asdf` 활성화하기

`~/.zshrc`의 `plugins` 정의에 `asdf`를 추가해, `asdf`를 활성화합니다.

```zsh
vim ~/.zshrc
```

![](https://res.cloudinary.com/gyunseo-blog/image/upload/v1698669625/install-asdf-on-ubuntu-linux-and-ohmyzsh-1696765514519.jpeg)
상기 이미지처럼 `plugins=(asdf)`를 추가합니다.  
그러면 `asdf`가 `ohmyzsh` framework에 통합이 되어, `asdf`를 사용할 수 있게 됩니다.

```zsh
asdf --version
```

![](https://res.cloudinary.com/gyunseo-blog/image/upload/v1698669625/install-asdf-on-ubuntu-linux-and-ohmyzsh-1696765667860.jpeg)

## Plugin Dependencies 설치

```zsh
sudo apt-get install -y dirmngr gpg curl gawk
```

본격적으로 `asdf` plugin을 설치하기 전에, plugin 의존성 패키지들을 설치합니다.

## `Nodejs` Plugin 설치

하기 명령어로 `nodejs` plugin을 설치합니다.

```zsh
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

## `Nodejs` Version 설치

하기 명령어로 모든 `node.js` runtime version을 볼 수 있습니다.

```zsh
asdf list all nodejs
```

원하는 경우 하기 명령어로 특정 version의 subset을 볼 수도 있습니다.

```zsh
asdf list all nodejs 18
```

필자는 `node.js` lts 버전을 설치할 것입니다.  
그전에 하기 명령어를 통해, 현재 시점에서 `nodejs` lts version을 확인해 봅시다.

```zsh
# Before checking for aliases, update nodebuild to check for newly releasead versions
asdf nodejs update-nodebuild

asdf nodejs resolve lts
# outputs: 18

# Outputs the latest version available for download which is a LTS
asdf nodejs resolve lts --latest-available
# outputs: 18.18.0
```

하기 명령어로 현재 시점에서의 lts version인 18.18.0 version을 설치합니다.

```zsh
asdf install nodejs 18.18.0
```

설치가 완료되면 하기 명령어로 `nodejs` runtime version의 list를 확인할 수 있습니다.

```zsh
asdf list nodejs
```

![](https://res.cloudinary.com/gyunseo-blog/image/upload/v1698669625/install-asdf-on-ubuntu-linux-and-ohmyzsh-1696766814971.jpeg)

## `nodejs` Version 설정하기

`asdf`는 현재 작업 디렉터리부터 `$HOME` 디렉터리까지 모든 `.tool-versions` 파일에서 tool의 버전 조회를 수행합니다.  
`asdf`가 관리하는 tool을 실행할 때, version lookup이 발생합니다.

## `nodejs` Global Version 설정하기

```zsh
asdf global nodejs 18.18.0
```

상기 명령어로 global version을 설정합니다.  
global default version들은 `$HOME/.tool-versions`에서 관리됩니다.  
그러면 하기 명령어로 global version이 제대로 설정됐는지 확인할 수 있습니다.

```zsh
cat $HOME/.tool-versions
```

![](https://res.cloudinary.com/gyunseo-blog/image/upload/v1698669625/install-asdf-on-ubuntu-linux-and-ohmyzsh-1696767200085.jpeg)

## `nodejs` Local version 설정하기

18.17.1 version을 설치하고, `gyunseo.github.io` 디렉터리에서 local version으로 18.17.1 version을 설정합시다.

```zsh
asdf install nodejs 18.17.1
asdf local nodejs 18.17.1
cat $PWD/.tool-versions
```

![](https://res.cloudinary.com/gyunseo-blog/image/upload/v1698669625/install-asdf-on-ubuntu-linux-and-ohmyzsh-1696767644582.jpeg)

## 글을 마치며

본 포스트에서는 node.js runtime version을 관리하는 방법을 소개했습니다.  
이 방법을 이용해 다양한 runtime version을 관리할 수 있습니다.  
필자는 현재 golang, jdk, python, rust를 `asdf`로 관리하고 있습니다.  
여러분들도 `asdf`를 이용해 다양한 runtime version을 관리해보세요.
