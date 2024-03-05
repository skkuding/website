# SKKUDING 팀 페이지

스꾸딩 팀의 소개 페이지와 기술 블로그입니다!

[Hugo](https://gohugo.io/)와 [Paper 테마](https://github.com/nanxiaobei/hugo-paper)를 사용해 만들었어요.

## Prerequisites

- 먼저 [hugo](https://gohugo.io/installation/)를 설치해주세요.

## 작성한 글 보기

- 아래 명령어로 Hugo 서버를 실행할 수 있어요.
- 정상적으로 실행되면 어느 포트에서 실행중인지 터미널을 통해 출력돼요.
- Draft를 포함해 보고싶다면 -D 옵션을 추가해주세요.

```bash
hugo server
hugo -D server
```

## 글 작성하기

- 다음 명령어로 `index.md`를 생성하고 여기에 마크다운으로 글을 작성할 수 있어요.

```bash
hugo new [디렉토리 이름]/index.md # 디렉토리 이름은 글 주제와 연관되는 것으로 마음대로!
```

- 생성한 `index.md`에 다음 내용이 들어있어요.

```markdown
---
title: "Test"
date: 2023-11-10T16:52:29+09:00
draft: true
---
```

- `draft` 옵션이 켜져있는 경우 블로그를 빌드했을 때 작성한 글이 보이지 않으니 지워주세요.
- `author`, `description`, `tags`을 다음과 같이 추가해주세요.
- `title`을 수정해 글 제목을 변경할 수 있어요.

```markdown
---
title: "Test"
date: 2023-11-10T16:52:29+09:00
author: "작성자"
description: "블로그 글을 써봅시다"
tags: ["HUGO"]
---

## 팀 블로그에 글을 써봅시다

여기에 이렇게 글을 작성해 주세요
```

- 사진을 삽입할 수 있어요.
- 원하는 사진을 index.md와 같은 디렉토리로 복사하고 다음처럼 작성해주세요.

```markdown
![대체 텍스트](이미지 경로)
![챗지피티](ChatGPT.webp)
```

- 유튜브 영상을 삽입할 수 있어요.
- VIDEO_ID는 https://www.youtube.com/watch?v=abcdef 이것과 같은 유튜브 영상 url에서 `v=`뒤에 위치하는 문자열이에요.

```markdown
{{< youtube VIDEO_ID >}}
```

<aside>
사실 노션에 작성하고 복사 붙여넣기 하면 편해요 😅

</aside>
