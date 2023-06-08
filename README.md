# mysql-upgrader

## 쿼리 작성 및 최적화
### SQL 모드
> MySQL 서버의 `sql_mode` 라는 시스템 설정에는 여러 개의 값이 동시에 설정될 수 있다. 
> 해당 설정은 대부분의 쿼리의 작동 방식에 영향을 미치므로 프로젝트 초기에 적용하는 것이 좋다. 운용 중인 애플리케이션에서 `sql_mode` 설정을 변경하는 것은
> 상당히 위험하므로 주의해야 한다.  

### 영문 대소문자 구분
> `lower_case_table_names`: 이 변수를 1로 설정하면 모두 소문자로만 저장되고, MySQL 서버가 대소문자를 구분하지 않게 해준다. 
> 이 설정의 기본값은 0으로, DB 나 테이블명에 대해 대소문자를 구분한다.  

### 날짜
> MySQL 서버에서는 정해진 형태의 날짜 포맷으롶 표기하면 MySQL 서버가 자동으로 DATE 나 DATETIME 값으로 변환하기 때문에 
> 복잡하게 STR_TO_DATE() 같은 함수를 사용하지 않아도 된다.  
> 
> DATE 타입은 날짜는 포함하지만 시간은 포함하지 않을 때 사용하는 타입이다.  
> DATE 타입 YYYY-MM-DD 형식으로 입력이 가능하며 '1000-01-01' 부터 '9999-12-31' 까지 입력이 가능하다.  
> 
> DATETIME 타입은 날짜와 시간을 모두 포함할 때 사용하는 타입이다.  
> YYYY-MM-DD HH:MM:SS 형식으로 입력이 가능하며 '1000-01-01 00:00:00' 부터 '9999-12-31 23:59:59' 까지 입력이 가능하다.  
> 
> TIME 타입은 시간에 대한 정보만 담는 타입이다.  
> HH:MM:SS 형식으로 입력이 가능하며 '-838:59:59' 부터 '838:59:59' 까지 입력이 가능하다.  
> 
> TIMESTAMP 타입은 날짜와 시간모두를 포함한 타입이다.  
> 범위로는 1970-01-01 00:00:01 ~ 2038-01-19 03:14:07 UTC 까지 표현할 수 있다.  
> 
> DATETIME vs TIMESTAMP  
> DATETIME 은 문자형이고 TIMESTAMP 는 숫자형이다.  
> DATETIME 은 8byte, TIMESTAMP 는 4byte 이다.  
> TIMESTAMP 는 타임존을 기반으로 한다.  
> DATETIME 및 TIMESTAMP 는 뒤에 괄호와 숫자를 붙여서 밀리세컨드를 표시할 수 있으며 최대 6자리까지 표시하여 저장할 수 있다.  

### 불리언
> BOOL 이나 BOOLEAN 이라는 타입이 있지만 사실 이건은 TINYINT 타입에 대한 동의어일 뿐이다.  
> MySQL 은 C/C++ 언어에서 처럼 TRUE 또는 FALSE 같은 불리언 값을 정수로 매핑해서 사용한다(0과 1).  
> 모든 숫자 값이 TRUE 나 FALSE 라는 두 개의 불리언 값으로 매핑되지 않는다는 것은 혼란스럽고 애플리케이션의 버그로 연결됐을 가능성이 크다. 
> 불리언 타입을 꼭 사용하고 싶다면 ENUM 타입으로 관리하는 것이 조금 더 명확하고 실수할 가능성도 줄일 수 있다.  

### LIKE 연산자
> LIKE 연산자는 인덱스를 이용해 처리할 수 있다.(와일드카드를 오른쪽에만 넣은 경우)  

### BETWEEN 연산자
> 크거나 같다 와 작거나 같다를 합친 연산자이다.  
> BETWEEN 을 통한 범위 검색보다는 해당 범위의 값이 적은 경우 IN ()을 통해서 괄호 안에 범위의 값들을 모두 넣어서 동등 비교를 하는 것이 좋다. 
> 범위의 값이 많은 경우 JOIN 후 BETWEEN 을 사용하거나 혹은 IN (subquery) 를 사용한다. 
> IN (subquery)는 실행 시 옵티마이저에 의해 자동으로 JOIN 쿼리로 변경되어 실행된다.  

### IN 연산자
> MySQL 8.0 이전 버전까지는 IN 절에 튜플(레코드)를 사용ㅇ하면 항상 풀 테이블 스캔을 했었다. 
> ```sql
> select * 
> from dept_emp 
> where (dept_no, emp_no) in (('d001', 10017), ('d002', 10144), ('d003', 10054));
> ```
> 위의 예제 쿼리는 IN 절의 상숫값이 단순 스칼라값이 아니라 튜플이 사용됐다. 
> MySQL 8.0 버전부터는 위의 쿼리와 같이 IN 절에 튜플을 그대로 나열해도 인ㄷ게스를 최적으로 사용할 수 있게 개선됐다.  
> 
> NOT IN 의 실행 계획은 인덱스 풀 스캔으로 표시되는데, 동등이 아닌 부정형 비교여서 인덱스를 이용해 처리 범위를 줄이는 조건으로는
> 사용할 수 없기 때문이다. 

### 현재 시각 조회(NOW, SYSDATE)
> 두 함수 모두 현재의 시간을 반환하는 함수로서 같은 기능을 수행한다. 
> NOW 함수의 경우 하나의 쿼리에서 모든 NOW 함수는 같은 값을 가지지만 SYSDATE 함수는 하나의 쿼리 내에서도 호출되는 시점에 따라 결괏값이 달라진다.  
> SYSDATE 함수는 두 가지 큰 잠재적인 문제가 있다.  
> * SYSDATE 함수가 사용된 SQL 은 레플리카 서버에서 안정적으로 복제되지 못한다.  
> * SYSDATE 함수와 비교되는 칼럼은 인ㄷ게스를 효율적으로 사용하지 못한다.  
> 또한 SYSDATE 와 비교하는 조건 절의 경우도 인덱스를 사용하지 못한다. (NOW 는 인덱스를 사용하여 처리된다)  
> 그래서 꼭 필요한 때가 아니라면 SYSDATE 함수를 사용하지 않는 편이 좋다.  

### 날짜와 시간의 연산(DATE_ADD)
> ```sql
> # DATE_ADD(<DateTime>, INTERVAL n <YEAR, MONTH, DAT, HOUR, MINUTE, SECOND>
> select DATE_ADD(now(), INTERVAL 1 DAY) AS tomorrow;
> 
> select DATE_ADD(now(), INTERVAL -1 DAY) AS yesterday;
> ```

### Hex String 변환
> HEX(): 이진값(Binary)을 사람이 읽을 수 있는 형태의 16진수의 문자열로 변환하는 함수이다.  
> UNHEX(): 16진수 문자열을 읽어서 이진값(Binary)로 변환하는 함수다.  

### 암호화 및 해시 함수(MD5, SHA, SHA2)
> SHA(): SHA-1 암호화 알고리즘 사용, 160비트(20바이트) 해시 값을 반환한다.
> 
> SHA2(): SHA 암호화 알고리즘보다 더 강력한 224비트부터 512비트 암호화 알고리즘을 사용.
> 
> MD5(): 메시지 다이제스트(Message Digest) 알고리즘을 사용해 128비트(16바이트) 해시 값을 반환한다.    
> 입력된 문자열(Message)의 길이를 줄이는(Digest) 용도로 사용된다.
> 
> 위 함수들 모두 사용자의 비밀번호와 같은 암호화가 필요한 정보를 인코딩하는 데 사용되며, 반환 값은 16진수 문자열 형태이다.  
> 암호화된 값을 문자열로 저장해 두기 위해서는 각 16진수의 값이 문자로는 2자리로 표현되기 때문에 
> MD5() 함수는 CHAR(32), SHA() 함수는 CHAR(40)의 타입을 필요로 한다.  
> 저장 공간을 원래의 16바이트(MD5) 와 20바이트(SHA) 로 줄이고 싶다면 BINARY, VARBINARY 형태의 타입에 저장하면 된다.  
> 칼럼 타입을 BINARY(16) 또는 BINARY(20) 으로 정의하고, MD5() 함수나 SHA() 함수의 결과를 UNHEX() 함수를 이용해 이진값으로
> 변환해서 저장하면 된다.  
> ```sql
> create table tab_binary(
>     col_md5 BINARY(16),
>     col_sha BINARY(20),
>     col_sha2_256 BINARY(32)
> );
> 
> insert into tab_binary values 
> (UNHEX(MD5('abc')), UNHEX(SHA('abc')), UNHEX(SHA2('abc', 256)));
> 
> select HEX(col_md5), HEX(col_sha), HEX(col_sha2_256) from tab_binary \G; 
> ```
> 
> MD5 함수나 SHA(), SHA2() 함수는 모두 비대칭형 암호화 알고리즘이다. 이 함수들의 결괏값은 중복 가능성이 매우 낮기 때문에 길이가 긴 데이터를
> 크기를 줄여서 인덱싱(해시)하는 용도로 사용된다. 예를 들어 URL 같은 값은 1KB 를 넘을 때도 있으며 전체적으로 값의 길이가 긴 편이다. 이러한 데이터를
> 검색하려면 인덱스가 필요하지만 긴 칼럼에 대해 전체 값으로 인덱스를 생성하는 것은 불가능할 뿐만 아니라 공간 낭비도 커진다.  
> URL 값을 MD5() 함수로 단축하면 16바이트로 저장할 수 있고, 이 16바이트로 인덱스를 생성하면 되기 때문에 상대적으로 효율적이다.  
> ```sql
> # MySQL 8.0 버전부터 인덱스 생성에 md5() 함수 사용 
> create table tb_accesslog(
>     access_id BIGINT NOT NULL AUTO_INCREMENT,
>     access_url VARCHAR(1000) NOT NULL,
>     access_dttm DATETIME NOT NULL,
>     PRIMARY KEY(access_id),
>     INDEX ix_accessurl ((UNHEX(MD5(access_url))))
> ) ENGINE=INNODB;
> 
> # 함수 기반의 인덱스를 가진 테이블 INSERT, SELECT 
> insert into tb_accesslog values (1, 'http://matt.com', NOW());
> 
> # 평문 검색하면 결과 안나옴.
> select * from tb_accesslog where UNHEX(MD5(access_url)) = 'http://matt.com';
> 
> # 칼럼 및 검색 값 모두에 함수 사용 필요.
> select * from tb_accesslog where UNHEX(MD5(access_url)) = UNHEX(MD5('http://matt.com'));
> ```
> 인덱스 및 검색 시에 UNHEX 는 사용하지 않고 MD5 만 사용해도 된다. 하지만 UNHEX 사용 시 BINARY 로 저장되기 때문에 인덱스의 크기를 더 줄일 수 있다.  

### 벤치마크(BENCHMARK), 처리 대기(SLEEP)
> SLEEP() 함수 및 BENCHMARK() 함수는 디버깅이나 테스트 용도의 함수이다.
> 
> SLEEP(): from 없이 사용하면 매개변수로 전달하는 숫자의 초 만큼 대기 후 종료한다. from 절이 있으면 해당 테이블에서 반환되는 레코드 수 만큼 SLEEP 함수가
> 호출되어 설정 한 n * 반환된 레코드 갯수 초 만큼 대기하게 된다.  
> 
> BENCHMARK(): 2개의 인자를 필요로 한다. 첫 번째 인자는 반복해서 수행할 횟수이며, 두 번째 인자로는 반복해서 실행할 표현식을 입력하면 된다.  
> ```sql
> # 1.5 초 대기 후 종료
> select SLEEP(1.5);
> 
> # employees 테이블의 총 레코드 갯수 * 1 초 대기 후 종료
> select SLEEP(1) from employees;    
> 
> # MD5 함수를 10만번 수행, 반환 값은 의미 없고 실행에 걸린 시간만 보면 된다.  
> select BENCHMARK(100000, MD5('abcdefghijk'));
> 
> # salaries 테이블 풀 테이블 조회를 10만번 수행한다.  
> select BENCHMARK(100000, (select * from salaries));
> ```
> 하지만 이렇게 쿼리를 BENCHMARK() 함수로 확인할 때는 주의할 사항이 있다.  
> 그것은 "select BENCHMAKR(10, expr)" 와 "select expr" 을 10번 직접 실행하는 것과는 차이가 있다는 것이다. 
> SQL 클라이언트와 같은 도구로 "select expr"을 10번 실행하는 경우에는 매번 쿼리의 파싱이나 최적화, 테이블 잠금이나 네트워크 비용 등이 소요된다. 
> 하지만 "select BENCHMAKR(10, expr)"로 실행하는 경우에는 벤치마크 횟수에 관계없이 단 1번의 네트워크, 쿼리 파싱 및 최적화 비용이 소요된다는 점을
> 고려해야 한다.  
> 
> 또한 "select BENCHMAKR(10, expr)"을 사용하면 한 번의 요청으로 expr 표현식이 10번 실행되는 것이므로 이미 할당받은 메모리 자원까지 공유되고,
> 메모리 할당도 "select expr" 쿼리로 직접 10번 실행하는 것보다는 1/10 밖에 일어나지 않는다.  
> BENCHMARK 함수로 얻은 쿼리나 함수의 성능은 그 자체로는 큰 의미가 없으며, 동일 기능을 가지지만 다른게 표현된 쿼리 두 개 이상을 
> 상대적으로 비교 분석하는 용도로 사용할 것을 권장한다.  

### JSON 관련 함수들
> JSON_PRETTY(): MySQL 클라이언트에서 JSON 데이터의 기본적인 표시 방법은 단순 텍스트 포맷이어서 가독성이 떨어진다. 해당 함수를 이용하여 읽기 쉬운 
> 포멧으로 변환한다.  
> 
> JSON_STORAGE_SIZE(): JSON 데이터는 텍스트 기반이지만 MySQL 서버는 디스크의 저장 공간을 절약하기 위해 JSON 데이터를 실제 디스크에 저장할 때 
> BSON(Binary JSON) 포맷을 사용한다. 하지만 BSON 으로 변환됐을 때 저장 공간의 크기가 얼마나 될지 예측하기는 어렵다. 이를 위해 MySQL 서버에서는 
> 해당 함수를 제공한다. 해당 함수의 실행 결과로 반환되는 값의 단위는 바이트(Byte)이다.  
> 
> JSON_EXTRACT(): JSON 도큐먼트에서 특정 필드의 값을 가져오는 방법 중 하나이다.  
> 첫 번째 인자는 JSON 데이터가 저장된 칼럼 또는 JSON 도큐먼트 자체이며, 두 번째 인자는 가져오고자 하는 필드의 JSON 경로를 명시한다.  
> ```sql
> # 따옴표 있이 JSON 값 가져오기 - JSON 함수 사용 
> select emp_no, JSON_EXTRACT(doc, "$.first_name") from employee_docs;
> 
> # 따옴표 있이 JSON 값 가져오기 - JSON 표현식 사용
> select emp_no, doc->"$.first_name" from employee_docs;
> 
> # 따옴표 없이 JSON 값 가져오기 - JSON 함수 사용
> select emp_no, JSON_UNQUOTE(JSON_EXTRACT(doc, "$.first_name")) from employee_docs;
> 
> # 따옴표 없이 JSON 값 가져오기 - JSON 표현식 사용
> select emp_no, doc->>"$.first_name" from employee_docs;
> ```
> JSON_EXTRACT() 함수의 결과에는 따옴표가 붙은 상태인데, 두 번째 예제처럼 JSON_UNQUOTE() 함수를 함께 사용하면 따옴표 없이 값만 가져올 수 있다.  
> 
> JSON_CONTAINS(): JSON 도큐먼트 또는 지정된 JSON 경로에 JSON 필드를 가지고 있는지 확인하는 함수.
> ```sql
> # 방식 1
> select emp_no from employee_docs
> where JSON_CONTAINS(doc, '{"first_name":"Christian"}');
> 
> # 방식 2
> select emp_no from employee_docs
> where JSON_CONTAINS(doc, '"Christian"', '$.first_name');
> ```

### 인덱스 사용 주의 사항
> where 절이나 order by 또는 group by 가 인덱스를 사용하려면 기본적으로 인덱스된 칼럼의 값 자체를 변환하지 않고 그대로 사용한다는 조건을 만족해야 한다.
> ```sql
> # where 조건에서 인덱스가 걸린 salary 를 salary * 10 으로 변환하여 사용하기 때문에 인덱스 레인지 스캔이 아닌 인덱스 풀 스캔을 사용하게 된다.
> select * from salaries where salary*10 > 1500000;
> 
> # 다음과 같이 salary 칼럼의 값을 변경하지 않고 검색하도록 유도할 수 있다.
> select * from salaries where salary > 1500000/10;
> ```
> 인덱스 칼럼의 데이터 형식과 다른 데이터 형식으로 비교하는 경우 역시 인덱스를 제대로 사용하지 못함으로 where 를 통한 비교 시 인덱스 칼럼과 동일한
> 데이터 타입으로 비교해야한다.
>
> 복합 인덱스의 경우 where 조건에 인덱스의 왼쪽부터 순서대로 기술하지 않더라도 옵티마이저가 알아서 인덱스의 왼쪽부터 필터해나가도록 해준다.
>
> group by 절에서 인덱스 사용 가능한 상황은 다음과 같다. group by 절의 칼럼 순서와 복합 인덱스의 칼럼 순서가 일치하고 인덱스 칼럼 외의 칼럼이
> 오지 않아야 한다.    
> group by 절의 칼럼 순서가 복합 인덱스의 칼럼 순서와 일치만 한다면 group by 절에 복합 인덱스의 칼럼이 몇개 누락되어도 인덱스를 사용할 수 있다.
>
> ex) 복합 인덱스가 (col1, col2, col3, col4) 인데 group by 에는 (col1, col2) 와 같이 복합 인덱스 칼럼의 일부만 사용해도 인덱스를 제대로 사용한다.
>
> where 조건과 order by(또는 group by) 절의 인덱스 사용 시 다음 3가지 중 한가지 방법으로만 인덱스를 이용한다.
> * where 절과 order by 절이 동시에 같은 인덱스를 이용: where 절의 비교 조건에서 사용하는 칼럼과 order by 절의 정렬 대상 칼럼이
    > 모두 하나의 인덱스에 연속해서 포함돼 있을 때 이 방식으로 인덱스를 사용할 수 있다. 이 방법은 나머지 2가지 방식보다 훨씬 빠른 성능을 보이기
    > 때문에 가능하면 이 방식으로 처리할 수 있게 쿼리를 튜닝하거나 인덱스를 생성하는 것이 좋다.
>
> * where 절만 인덱스를 이용: order by 절은 인덱스를 이용한 정렬이 불가능하며, 인덱스를 통해 검색된 결과 레코드를 별도의 정렬 처리 과정(Using filesort)
    > 을 거쳐 정렬을 수행한다. 주로 이 방법은 where 절의 조건에 일치하는 레코드의 건수가 많지 않을 때 효율적인 방식이다.
>
> * order by 절만 인덱스를 이용: order by 절은 인덱스를 이용해 처리하지만 where 절은 인덱스를 이용하지 못한다.
    > 이 방식은 order by 절의 순서대로 인덱스를 읽으면서 레코드 한 건씩 where 절의 조건에 일치하는지 비교하고, 일치하지 않을 때는 버리는 형태로 처리한다.
    > 주로 아주 많은 레코드를 조회해서 정렬해야 할 때는 이런 형태로 튜닝하기도 한다.
>
> group by 와 order by 가 같이 사용된 쿼리에서는 둘 중 하나라도 인덱스를 이용할 수 없을 때는 둘 다 인덱스를 사용하지 못한다. 즉, group by
> 는 인덱스를 이용할 수 없을 때 이 쿼리의 group by 와 order by 절은 모두 인덱스를 이용하지 못한다. 물론 반대의 경우도 마찬가지다.  
> MySQL 5.7 버전까지는 group by 는 group by 칼럼에 대한 정렬까지 함께 수행하는 것이 기본 작동 방식이었다. 하지만 MySQL 8.0 버전부터는
> group by 절이 칼럼의 정렬까지는 보장하지 않는 형태로 바뀌었다. 그래서 MySQL 8.0 버전부터는 group by 칼럼으로 그루핑과 정렬을 모두 수행하기 위해서는
> group by 절과 order by 절을 모두 명시해야 한다.
>
>
