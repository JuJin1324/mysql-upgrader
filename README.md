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
> MySQL 서버에서는 정해진 형태의 날짜 포맷으로 표기하면 MySQL 서버가 자동으로 DATE 나 DATETIME 값으로 변환하기 때문에 
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
> **날짜 타입 비교**  
> DATE 혹은 DATETIME 과 문자열 비교 시 STR_TO_DATE 함수를 사용해도 되고 문자열로 사용해도 모두 인덱스를 정상적으로 이용한다.  
> ```sql
> # STR_TO_DATE 함수를 사용하여 비교
> select count(*)
> from employees
> where hire_date > STR_TO_DATE('2023-01-23', '%Y-%m-%d');
> 
> # 문자열 비교
> select count(*)
> from employees
> where hire_date > '2023-01-23';
> ```
> 
> 그러나 아래와 같이 날짜 타입 칼럼을 변환하여 비교하게되면 인덱스를 사용하지 않는다.  
> ```sql
> select count(*)
> from employees
> where DATE_FORMAT(hire_date, '%Y-%m-%d') > '2023-01-23';
> ```
> 
> 날짜 타입 칼럼의 값을 더하거나 빼는 함수로 변형한 후 비교해도 마찬가지로 인덱스를 이용할 수 없다.
> ```sql
> select count(*)
> from employees
> where DATE_ADD(hire_date, INTERVAL 1 YEAR) > '2023-01-23'; 
> ```
> 
> DATETIME 값에서 시간 부분만 떼어 버리고 비교하려면 다음과 같이 DATE() 함수를 사용한다. 
> ```sql
> select count(*)
> from employees
> where hire_date > DATE(now());  
> ```
> DATETIME 과 DATE 타입의 비교에서 타입 변환은 인덱스의 사용 여부에 영향을 미치지 않기 때문에 성능보다는 쿼리의 결과에 주의해서 사용하면 된다.  
> 
> DATE 나 DATETIME 타입의 값과 TIMESTAMP 의 값을 별도의 타입 변환 없이 비교하면 문제없이 작동하고 실제 실행 계획도 인덱스 레인지 스캔을 사용해서
> 동작하는 것처럼 보이지만 사실은 그렇지 않다.  
> UNIX_TIMESTAMP() 함수의 결괏값은 MySQL 내부적으로는 단순 숫자 값에 불과할 뿐이므로 DATETIME 칼럼과 비교시 원하는 결과를 얻을 수 없다.  
> DATETIME 칼럼과 TIMESTAMP 값 비교시 다음과 같이 해야한다.  
> ```sql
> # TIMESTAMP -> DATETIME
> select count(*) from employeess
> where hire_date < FROM_UNIXTIME(UNIX_TIMESTAMP());
> 
> # DATETIME -> TIMESTAMP
> select count(*) from employeess
> where hire_timestamp < FROM_UNIX_TIMESTAMP('2023-11-23 00:00:00');
> ```
> 
> **Short-Circuit Evaluation**  
> and 조건 시 앞의 조건이 거짓이면 뒤의 조건의 참/거짓 여부와 관계 없이 무조건 거짓이 됨으로 뒤의 조건은 평가하지 않는 것이 Short-Circuit Evaluation 이다.  
> MySQL 의 select 문장에서 where 절에 조건 비교 시 조건의 순서에 따라 맨 앞에 기술된 조건에 해당하는 레코드가 0개이면 그 뒤의 조건은 더이상 실행되지 않고
> 결과가 반환되도록 동작한다.  
> where 절은 조건 비교 시 조건이 기술된 순서에 따라서 필터를 하며, 인덱스 조건이 있는 경우에만 순서와 상관없이 가장 먼저 실행되고 인덱스가 사용되지 않은
> 조건은 기술된 순서대로 동작한다.  
> MySQL 서버에서 쿼리를 작성할 때 가능하면 복잡한 연산 또는 다른 테이블의 레코드를 읽어야 하는 서브쿼리 조건 등은 where 절의 뒤쪽으로 배치하는 것이
> 성능상 도움이 될 것이다.  
> 
> **Limit**  
> Limit 은 Where 조건이 아니기 때문에 where 조건에 해당하는 레코드를 모두 가져온 후 limit 의 갯수를 추려내는 방식으로 동작한다.  
> 쿼리 문장에 group by 나 order by 와 같은 전체 범위 작업이 선행되더라도 limit 절이 있다면 크진 않지만 나름의 성능 향상은 있다고 불 수 있다.    
> order by, distinct, group by 가 인덱스를 이용해 처리될 수 있다면 limit 절은 꼭 필요한 만큼의 레코드만 읽게 만들어주기 때문에 쿼리의 작업량을 상당히
> 줄여준다.  
> limit 의 첫번째 인자는 offset 이고 두번째 인자는 갯수(count) 이다.  
> limit 뒤에 인자를 1개만 사용하는 경우 offset 은 자동으로 0 이고 지정한 인자는 갯수(count)에 해당한다.  
> ```sql
> # limit 10 만 쓰면 10개의 레코드만 가져온다는 것이다.
> select * from employees limit 10;
> 
> # limit 0, 10 이면 상위 0번째 레코드부터 10개만 가져온다는 것이다.
> select * from employees limit 0, 10;
> ```
> limit 제한 사항으로는 limit 의 인자로 표현식이나 별도의 서브쿼리를 사용할 수 없다.  
> 
> **Count**  
> count() 함수는 칼럼이나 표현식을 인자로 받으며, 특별한 형태로 "*" 를 사용할 수도 있다. 여기서 "*" 는 select 절에 사용될 때처럼 모든 칼럼을 가져오라는
> 의미가 아니라 그냥 레코드 자체를 의미하는 것이다. 그래서 count(*) 를 사용하든 count(1) 을 사용하건 동일한 처리 성능을 보인다.  
> 
> 대부분 count(*) 쿼리는 페이징 처리를 위해 사용할 때가 많은데, count(*) 쿼리에서 order by 절은 어떤 경우에도 필요치 않음으로 order by 절은 제거하여 사용한다. 
> 그리고 left join 또한 레코드 건수의 변화가 없거나 아우터 테이블에서 별도의 체크를 하지 않아도 되는 경우에는 모두 제거하는 것이 성능상 좋다.    
> MySQL 8.0 버전부터는 select count(*) 쿼리에 사용된 order by 절은 옵티마이저가 무사하도록 개선되었다. 하지만 가독성 및 오해를 줄이기 위해서 select count(*)
> 문에서는 order by 를 제거하자.  
> 
> count() 함수에 칼럼명이나 표현식이 인자로 사용되면 그 칼럼이나 표현식의 결과가 NULL 이 아닌 레코드 건수만 반환한다. 예를 들어, "count(col1)" 이라고 
> select 쿼리에 사용하면 col1 이 NULL 이 아닌 레코드의 건수를 가져온다. 그래서 NULL 이 될 수 있는 칼럼을 count() 함수에 사용할 때는 의도대로 쿼리가
> 작동하는지 확인하는 것이 좋다.  
> 
> **Join**  
> 조인 시 on 조건에 오는 두 칼럼 모두에 인덱스가 있어야 빠른 조인이 가능하다. 두 칼럼에 모두 인덱스가 없는 경우가 가장 느리게 동작한다.  
> where 조건 뿐만 아니라 조인의 on 조건에서도 두 칼럼의 데이터 타입이 일치하지 않으면 인덱스를 효율적으로 이용할 수 없다.  
> 인덱스 사용에 영향을 미치는 데이터 타입 불일치는 다음 타입들 사이에는 발생하지 않기 때문에 다음 타입들은 비교에 사용해도 문제가 없다.
> * CHAR 타입과 VARCHAR 타입
> * INT 타입과 BIGINT 타입
> * DATE 타입과 DATETIME 타입
> 
> 문자열 데이터 타입의 경우 문자 집합이나 콜레이션이 다른 경우에는 적절한 인덱스 사용이 불가능하다.  
> 숫자 데이터 타입의 경우에도 Signed/Unsigned 가 다른 경우에는 적절한 인덱스 사용이 불가능하다.  
> 
> MySQL 옵티마이저는 절대 아우터로 조인되는 테이블을 드라이빙 테이블로 선택하지 못하기 때문에 아우터 조인 사용 시 풀 스캔이 필요한 테이블을 드라이빙 테이블로 
> 선택할 수 있다. 필요한 데이터와 조인되는 테이블 간의 관계를 정확히 파악해서 꼭 필요한 경우가 아니라면 이너 조인을 사용하는 것이 업무 요건을 정확히 구현함과 동시에
> 쿼리의 성능도 향상시킬 수 있다.  
> 
> ```sql
> select * 
> from employees e 
> LEFT JOIN dept_manager mgr ON mgr.emp_no=e.emp_no
> where mgr.dept_no='d001'; 
> ```
> 위와 같이 where 조건에 아우터 테이블의 칼럼 조건을 넣게 되면 MySQL 은 자동으로 LEFT JOIN 을 INNER JOIN 으로 변환시켜서 동작한다.  
> 정상적인 아우터 조인으로 동작시키려면 아우터 테이블의 칼럼 조건을 where 가 아니라 on 절에 넣어야한다.  
> 
> 지연된 조인(Delayed Join) 은 from 절에 서브 쿼리를 통해서 최대한 조인할 레코드의 갯수를 줄여서 조인하는 기법을 말한다.  
> from 절의 서브쿼리의 경우 임시 테이블을 사용하기 때문에 성능이 낮아진다고 생각할 수 있지만 서브 쿼리를 통해서 가져오는 레코드를 의미있게 줄여준다면 
> 임시 테이블을 사용함에도 성능의 향상을 더 볼 수도 있다.  
> from 절의 서브쿼리를 통하지 않았을 때와 비교해서 얼마나 많이 조인 레코드를 줄여주느냐를 고려해서 지연된 조인을 사용해보는 것이 좋을듯 하다.
> 
> **Order by**  
> InnoDB 의 경우 order by 를 사용하지 않았을 때 인덱스를 사용하였다면 인덱스의 순서에 맞게 가져오게되며 풀 테이블 스캔 시 클러스터링 인덱스인 PK dml tnstjfh
> 가져오게 된다. 하지만 항상 정렬이 필요한 곳에서는 order by 절을 사용해야 한다.  
> MySQL 에서 order by 절에 쌍따옴표를 사용하여 칼럼명을 표시하게 되면 문자열 리터럴로 인식하여 해당 칼럼명은 무시되기 때문에 쌍따옴표로 칼럼명을 표시하지 않도록
> 주의해야한다.
> 
> **서브 쿼리**  
> select 절(select 와 from 사이)에 사용된 서브쿼리는 내부적으로 임시 테이블을 만들거나 쿼리를 비효율적으로 실행하게 만들지는 않기 때문에
> 서브쿼리가 적절히 인덱스를 사용할 수 있다면 크게 주의할 사항은 없다.  
> select 절 서브쿼리에서는 항상 칼럼과 레코드가 하나인 결과를 반환해야 한다. 그 값이 NULL 이든 아니든 관계없이 레코드가 1건이 존재해야한다.  
> 즉 스칼라 서브쿼리인 경우만 가능하다.(스칼라 서브쿼리는 칼럼과 레코드 값이 각각 1개만 반환하는 쿼리를 말한다.)  
> 다만 조인으로 처리해도 되는 쿼리의 경우 서브쿼리로 실행될 때 보다 조인으로 처리할 때가 조금 더 빠르기 때문에 가능하면 조인으로 쿼리를 작성하는 것이 좋다.  
> 
> where 절에서 서브쿼리를 통해서 동등 비교 시 MySQL 5.5 버전부터는 서브쿼리를 먼저 실행하여 상수로 변환하여 비교한다.  
> 하지만 서브쿼리의 칼럼이 2개 이상인 튜플로 동등비교를 하게되면 외부 쿼리는 인덱스를 사용하지 못하고 풀 테이블 스캔을 실행하게 된다.  
> 단일 칼럼 값 비교시에면 where 서브쿼리를 사용한다.  
> 
> RDBMS 에서 Not-Equal 비교(<>연산자)는 인덱스를 제대로 활용할 수 없듯이 not in(안티 세미 조인) 또한 최적화할 수 있는 방법이 많지 않다.  
> MySQL 옵티마이저는 안티 세미 조인 쿼리가 사용되면 다음 두 가지 방법으로 최적화를 수행한다.
> * not exists
> * 구체화(Materialization)
> where 절에 단독으로 안티 세미 조인 조건만 있다면 풀 테이블 스캔을 피할 수 없으니 주의하자.  
>
> **CTE(Common Table Expression)**  
> CTE 는 이름을 가지는 임시테이블로서, SQL 문장 내에서 한 번 이상 사용될 수 있으며 SQL 문장이 종료되면 자동으로 CTE 임시 테이블은 삭제된다.    
> 사용: `WITH cte1 AS (select ...) select ...`  
> CTE 를 재귀적으로 사용하지 않더라도 기존 FROM 절에 사용되던 서브쿼리에 비해 다음의 3가지 장점이 있다.  
> * CTE 임시 테이블은 재사용 가능하므로 FROM 절의 서브쿼리보다 효율적이다.
> * CTE 로 선언된 임시 테이블을 다른 CTE 쿼리에서 참조할 수 있다.
> * CTE 임시 테이블의 생성 부분과 사용 부분의 코드를 분리할 수 있으므로 가독성이 높다.
> 
> **잠금을 사용하는 Select**  
> 한 가지 주의할 사항은 FOR UPDATE 나 FOR SHARE 절을 가지지 않는 select 쿼리의 작동 방식이다.  
> InnoDB 스토리지 엔진을 사용하는 테이블에서는 잠금 없는 읽기가 지원되기 때문에 특정 레코드가 "select ... for update" 쿼리에 의해서 잠겨진 상태라
> 하더라도 FOR SHARE 나 FOR UPDATE 절을 가지지 않은 단순 select 쿼리는 아무런 대기 없이 실행된다.  
> ```sql
> select * 
> from employees e 
> inner join dept_emp de on dep.emp_no=e.emp_no
> inner join departments d on d.dept_no=de.dept_no
> FOR UPDATE;
> ```
> 이 쿼리는 조인한 테이블 3개에서 읽은 레코드에 대해 모두 쓰기 잠금을 걸게 된다. 그런데 dept_emp 테이블과 departments 테이블은 그냥 참고용으로만
> 읽고, 실제 쓰기 잠금은 employees 테이블에만 걸고 싶다면 어떻게 해야 할까? MySQL 8.0 버전부터는 다음과 같이 잠금을 걸 테이블을
> 선택할 수 있도록 기능이 개선됐다.  
> ```sql
> # FOR UPDATE 뒤에 OF <테이블명> 을 하여 OF 뒤에 선언한 테이블의 레코드만 잠금을 건다.
> select * 
> from employees e 
> inner join dept_emp de on dep.emp_no=e.emp_no
> inner join departments d on d.dept_no=de.dept_no
> FOR UPDATE OF e; 
> ```
> `FOR UPDATE NOWAIT` 는 는 select 하려는 레코드가 다른 트랜잭션에 의해 이미 잠겨진 상태라면 즉시 에러를 반환한다.
> 응용 프로그램에서 락을 기다리지 않고 즉시 다른 처리를 수행하거나 다시 트랜잭션을 시작하도록 구현해야 할 때도 유용하게 사용할 수 있다.  
> 
> `FOR UPDATE SKIP LOCKED` 는 select 하려는 레코드가 다른 트랜잭션에 의해 이미 잠겨진 상태라면 에러를 반환하지 않고 잠긴 레코드는 무시하고 잠금이 걸리지
> 않은 레코드만 가져온다.  
> 이는 큐(Queue)와 같은 기능을 MySQL 에 구현할 때 좋다. 
