+++
author = "최재민"
title = "Rust를 쓰는 이유: Ownership"
date = "2023-11-07"
description = "Rust의 강점인 Ownership 개념을 이해합니다."
tags = ["backend", "sandbox", "security"]
+++

요즘 C, C++의 대체재로 새롭게 떠오르는 Rust!
Stack Overflow 설문조사에서 2023년 기준 8년째 선호 순위 1위를 차지한, 아주 핫한 언어라고 할 수 있어요.
Linux Kernel은 그동안 C언어의 대체재가 없다며 C언어를 계속 사용해왔지만, 최근에는 Rust를 사용하기 시작했어요.
Azure CTO가 _"이제 새 프로젝트는 C, C++ 대신 Rust를 사용해야 한다"_ 라고 말해 화제가 되기도 했죠.

{{< tweet user="markrussinovich" id="1571995117233504257" >}}

그래서 Rust가 왜 이렇게 핫한가요? 듣기로는 문법도 어렵다고 하고, C와 C++의 퍼포먼스를 따라갈 언어는 없을텐데 말이죠.
이 글에서는 Rust의 핵심 개념인 ownership(소유권)에 대해 설명하려고 해요.
C와 C++에 어떤 문제가 있었고 ownership이 이를 어떻게 해결하는지에 대해 알아봐요.

## 보안 문제와 메모리

시스템 보안 문제의 대부분은 메모리와 관련이 있어요. <cite>아래 통계처럼, Windows 운영체제의 전체 보안 취약점 중 약 70%가 메모리 관련 문제예요.[^1]</cite> C와 C++로 프로그램을 작성했을 때 어떤 메모리 문제가 발생할 수 있는지, 그리고 다른 언어들은 이 문제를 어떻게 해결했는지 설명할게요.

{{< figure src="windows-vulnerability.webp" caption="Windows의 보안 취약점 통계" alt="Windows의 보안 취약점 통계" >}}

[^1]: MSRC Team. (2019, July 16). A proactive approach to more secure code. https://msrc.microsoft.com/blog/2019/07/a-proactive-approach-to-more-secure-code/

### C와 C++의 메모리 문제

C언어를 써봤다면 포인터와 메모리 개념을 다들 알고 있을 거에요.
C언어의 포인터는 메모리 주소를 가리키는 변수에요.
모든 변수들은 메모리 주소를 가지고 있고, 포인터는 이 메모리 주소를 가리켜요.

{{< figure src="pointer.webp" alt="포인터" >}}

메모리에 할당되는 방식은 stack과 heap으로 나뉘어져요. 지역 변수처럼 stack에 할당되는 변수들은 정적으로 compile time에 크기가 결정되고, heap에 할당되는 변수들은 동적으로 runtime에 크기가 결정되어요. 코드를 예시로 설명하면 아래와 같아요.

```c
#include <stdlib.h>

int main() {
    int a = 10; // stack
    int *b = malloc(sizeof(int)); // heap

    *b = 20;

    if (1) {
        int c = 30; // stack
        int *d = malloc(sizeof(int)); // heap
        *d = 40;
    }
    // c, d는 if문이 끝나면 사라짐
    // heap에 할당된 변수는 free를 호출하지 않으면 사라지지 않음
    free(b);

    return 0;
}
```

{{< figure src="stack-heap.webp" alt="메모리의 stack과 heap" >}}

편의상 stack, heap을 설명하기 위헤 그림에서 메모리를 한 줄로 표현했어요.
Stack은 메모리의 위에, heap은 메모리의 아래에 위치해요.
한 칸은 4바이트라고 가정하면, 포인터는 8바이트니까 두 칸을 차지하죠.
지역 변수인 `a`, `b`, `c`, `d`는 stack에 할당되고, `malloc`으로 동적으로 할당된 변수는 heap에 할당돼요.

이 코드에는 문제가 있어요.
`d`가 가리키는 변수는 동적으로 할당된 변수인데, 직접 `free`로 메모리를 해제하지 않았어요.
이렇게 메모리를 해제하지 않으면 메모리 누수가 발생해요.
메모리 누수가 발생하면 메모리가 부족해지고, 결국 프로그램이 죽어버려요.
C와 C++에서는 메모리 해제를 개발자가 직접 해줘야 하는 어려움이 있어요.
한번 다른 코드를 볼게요.

```c {hl_lines=["11-12"],lineNumbersInTable=false,lineNos=true}
#include <stdio.h>
#include <stdlib.h>

int main() {
    int a = 10; // stack
    int *b = malloc(sizeof(int)); // heap

    *b = 20;
    printf("b: %d\n", *b);

    free(b);
    printf("b: %d\n", *b);

    return 0;
}
```

이번에는 `free`를 한 후에 `b`를 출력해봤어요. 컴파일이 잘 될까요? 결과는 아래와 같아요.

```bash
❯ gcc main.c -o main && ./main
b: 20
b: 1769226288
```

결과를 보면 두 번째 `b`에 이상한 값이 저장되어있어요.
사람이 보면 잘못된 동작이지만, 프로그램은 어떠한 에러도 없이 잘 동작해요.
이렇게 할당되지 않은 메모리를 가리키는 포인터를 **dangling pointer**라고 해요.
이렇게 `b`에 의도하지 않은 값이 저장되기 때문에, 공격자는 이를 악용할 수 있겠죠.
C와 C++에서는 이러한 문제를 언어 차원에서 해결하지 않고, 사람이 직접 해결해야 해요.
사람이 직접 해결하다보니 실수할 수 있고, 이러한 실수가 보안 취약점으로 이어질 수 있어요.

{{< callout emoji="🎯" text="<b>C++의 스마트 포인터</b><br>하나 짚고 넘어가자면, 사실 C++11 표준부터 \"스마트 포인터\"라는 개념이 이 문제를 해결해줘요. 하지만 C++에서도 <code>malloc</code> 사용이 가능하고 언어 차원에서 강제하지 않기 때문에 여전히 사람의 실수는 가능해요." >}}

### Garbage Collection

C와 C++ 이후에 나온 언어들은 이러한 메모리 관련 문제를 해결하기 위해 Garbage Collection을 사용해요.
대표적으로 Java, C#, JavaScript, Python, Go 등이 있어요.
Garbage Collection은 프로그램이 동작하는 동안 메모리를 관리해주는 기능이에요.
Java 코드를 예시로 보면 아래와 같아요.

```java {hl_lines=[7],lineNumbersInTable=false,lineNos=true}
public class Main {
    public static void main(String[] args) {
        int a = 10;
        Integer b = new Integer(20);
        System.out.println(b);

        b = null;
        System.out.println(b);
    }
}
```

Java에서는 `new`로 생성된 객체는 Garbage Collection이 동작할 때 메모리에서 해제돼요.
`b`에 `null`을 대입하면 `b`가 가리키던 객체는 더 이상 사용되지 않기 때문에 Garbage Collector가 알아서 메모리를 해제해요.

너무 좋은 기능인데 왜 C와 C++에서는 이런 기능을 제공하지 않았을까요?
Garbage Collector는 compile time이 아니라 runtime에 동작하기 때문에 프로그램의 성능에 영향을 미쳐요.
성능이 중요한 시스템에서는 Garbage Collector를 사용하기 어렵겠죠.
Go가 시스템 프로그래밍 언어로 개발되었지만 시스템에서 잘 사용되지 않는 것도 Garbage Collector 때문이에요.

## Rust는 어떻게 해결했을까?

자, 정리해보면 C와 C++은 성능을 택하고 메모리 관리를 개발자에게 맡겼고, Java와 같은 언어는 메모리 관리를 자동화했지만 성능을 희생했어요.
그러면 Rust는 어느 쪽을 선택했을까요?
놀랍게도 Rust는 두 마리 토끼를 다 잡았어요.

Rust는 아주 강력한 컴파일러를 가지고 있어요.
메모리 관리를 runtime에 하면 성능이 떨어지기 때문에, Rust는 컴파일러가 compile time에 메모리 관리를 하자는 거죠.
Compile time에 관리하면 개발자가 실수할 걱정도 없고, runtime의 성능도 떨어지지 않죠.
바로 여기에서 **ownership(소유권)** 개념을 도입해요.

### Ownership

> 아래 내용은 'The Rust Programming Language'를 참고해서 작성했어요.  
> https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html

Rust의 ownership에 관한 규칙을 한번 살펴볼게요.

1. Rust에서 각각의 값은 owner를 가진다.
2. 한번에 하나의 owner만 존재한다.
3. Owner가 scope를 벗어나면 값은 버려진다.

무슨 말인지 전혀 감이 안 잡히죠? 예시로 차근차근 설명해볼게요.
Rust도 다른 언어처럼 stack에 할당되는 변수와 heap에 할당되는 변수가 있어요.
Stack에 할당되는 변수는 다른 언어에서도 compile time에 관리되기 때문에, 여기서는 heap에 할당되는 변수에 대해 설명할게요.

Rust에서 heap에 할당되는 변수로는 vector가 있어요.
C++ STL의 vector처럼 동적으로 크기가 결정되는 배열이에요.
Rust에서 vector를 사용하는 예시 코드를 가져와봤어요.

```rust
fn main() {
    let mut vec = Vec::new(); // vec이 vector 소유 (ownership)
    vec.push(1);
    vec.push(2);
    vec.push(3);

    // vec가 scope 내에 있으므로 벡터를 사용할 수 있어요.
    println!("벡터: {:?}", vec);

    // vec가 scope를 벗어나면, 벡터는 자동으로 drop돼요.
    // 이 때, 벡터에 의해 관리되는 모든 메모리가 해제돼요.
}
```

위 코드에서 `vec` 변수에 heap 메모리 값을 저장했지만, 메모리를 해제하는 코드는 따로 없죠.
Rust에서는 `vec` 변수가 scope(`{}`)를 벗어나면 자동으로 메모리를 해제해요.

한번 조금 더 복잡한 예제를 볼게요.

```rust {hl_lines=[2,6,12],lineNumbersInTable=false,lineNos=true}
fn main() {
    let mut vec1 = Vec::new(); // vec1이 vector 소유
    vec1.push(1);
    vec1.push(2);

    let vec2 = vec1; // vec1의 ownership이 vec2로 이동

    // println!("{:?}", vec1);
    // 여기서 vec1을 사용하려고 하면 컴파일 에러가 발생해요.
    // Ownership이 vec2로 이동되었기 때문이에요.

    print_vector(vec2); // vec2의 ownership이 함수로 이동

    // println!("{:?}", vec2);
    // 이 줄도 컴파일 에러를 발생시켜요.
    // vec2의 ownership이 함수 내부로 이동되었기 때문이에요.
}

fn print_vector(some_vector: Vec<i32>) {
    println!("벡터: {:?}", some_vector);
    // 함수가 끝날 때, some_vector는 drop됩니다.
}
```

한번 GPT로 예시 코드를 만들어봤어요.
일단 2번째 줄에서 `vec1`에 vector를 할당했어요. Vector 값의 owner는 `vec1`이죠.
다음에 6번째 줄과 8번째 줄에 주목해야하는데요,
vec2에 vec1을 대입했더니 owner는 `vec2`가 되었고 `vec1`은 더 이상 사용할 수 없게 됐어요.
이렇게 변수의 ownership이 다른 변수로 이동되면, 이전 변수는 사용할 수 없게 돼요.

그리고 12번째 줄에서는 `vec2`를 함수 `print_vector`에 넘겼어요.
함수 `print_vector`에 넘기면서 ownership이 함수 내부로 이동되었기 때문에, `vec2`는 더 이상 사용할 수 없게 돼요.
함수 내부에서는 `some_vector`를 사용할 수 있고, 함수가 끝나면서 `some_vector`는 drop되어 메모리에서 해제돼요.

이제 조금 감이 오시나요? 너무 불편한 규칙 아니냐고요?
물론 heap이 아니라 정적으로 할당되는 변수들은 아래처럼 잘 동작해요.

```rust
fn main() {
    let a = 10;
    let b = a;
    println!("a: {}, b: {}", a, b);
}
```

이 코드에서는 `a`의 ownership이 `b`로 이동되는 것이 아니라, 값이 복사돼요.
정수형 타입은 `Copy` trait을 지원하기 때문에 복사가 가능해요.
잠만요, `Copy` trait은 뭐죠?

### Copy trait

Rust의 타입 중에는 `Copy` trait을 지원하는 타입과 그렇지 않은 타입이 있어요.
`Copy` trait을 지원하는 타입은 값이 변수에 바인딩되거나 다른 함수로 전달될 때 자동으로 복사가 일어나요.
복사가 일어나니까 ownership이 이동하지 않고, 원래 변수도 계속 사용할 수 있죠.
`Copy` trait을 지원하는 타입은 아래와 같아요.

- 모든 정수형 타입들 (예: `i32`, `u64` 등)
- 모든 부동 소수점 타입들 (예: `f32`, `f64`)
- 불리언 타입 `bool`
- 문자 타입 `char`
- 튜플들, 그 튜플의 모든 요소들이 Copy를 구현하는 경우 (예: `(i32, i32)`는 `Copy`이지만 `(i32, String)`은 아닙니다)

### Clone trait

`Clone` trait은 `Copy` trait과 비슷하지만, 명시적인 복사를 말해요.
앞선 예시처럼 `Copy` trait을 지원하지 않는 vector와 같은 타입들은 명시적으로 복사해야해요.
예시는 아래와 같아요.

```rust
fn main() {
    let mut vec1 = vec![1, 2, 3];
    let vec2 = vec1.clone();
    vec1.push(4);
    println!("vec1: {:?}, vec2: {:?}", vec1, vec2);
}
```

위 코드는 에러 없이 잘 동작해요.
`.clone()` 메소드를 사용해서 명시적으로 복사했고, `vec1`의 ownership은 그대로에요.
깊은 복사(deep copy)가 일어났기 때문에, `vec1`과 `vec2`는 서로 다른 메모리를 가리키고 있어요.
그래서 아래처럼 실행돼요.

```
vec1: [1, 2, 3, 4], vec2: [1, 2, 3]
```

### C로는 되지만, Rust로는 안 되는 것

한번 보니 ownership은 꽤나 까다로운 규칙인데요, 그래서 C언어로는 되는데 Rust로는 안 되는 것들이 있어요.

- **데이터의 여러 owner**: C에서는 여러 포인터가 동일한 메모리 주소를 가리킬 수 있어요. Rust에서는 한 번에 하나의 변수만이 어떤 데이터의 ownership을 가질 수 있어요.

- **포인터를 통한 데이터 변경**: C에서는 상수 포인터(`const`)를 사용하여도 메모리 주소를 통해 데이터를 변경할 수 있어요. Rust에서는 불변 변수에 대한 참조가 있으면, 그 데이터는 변경할 수 없어요.

- **임의 해제**: C에서는 `free()`를 사용하여 언제든지 메모리를 해제할 수 있어요. Rust에서는 값이 scope를 벗어날 때 자동으로 drop되고, 사용자가 임의로 메모리를 해제할 방법이 없어요.

- **포인터 산술**: C에서는 포인터를 증감하여 메모리 내에서 임의로 이동할 수 있어요. Rust에서는 `unsafe` 블록을 사용하지 않고는 포인터 산술을 사용할 수 없어요.

## Rust의 인기 이유, Ownership

지금까지 Rust의 핵심 개념인 Ownership을 찍먹해봤어요.
실제로 구현하다보면 생각보다 어려운 점도 많고, Rust 컴파일러가 꽤나 엄격한 편이기에 컴파일에 성공하는 것도 쉽지 않아요.
그럼에도 불구하고 성능 문제와 메모리 관리 문제를 모두 해결한 언어라는 점은 정말 대단하다고 생각해요.
아직 라이브러리나 생태계가 C++에 미치지는 못해도 Rust는 분명 미래가 유망한 언어예요.
아직 Rust를 사용해보지 않았다면 한 번 사용해보는 것도 좋을 것 같아요.
