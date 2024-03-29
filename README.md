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
> MySQL 8.0 이전 버전까지는 IN 절에 튜플(레코드)를 사용하면 항상 풀 테이블 스캔을 했었다. 
> ```sql
> select * 
> from dept_emp 
> where (dept_no, emp_no) in (('d001', 10017), ('d002', 10144), ('d003', 10054));
> ```
> 위의 예제 쿼리는 IN 절의 상숫값이 단순 스칼라값이 아니라 튜플이 사용됐다. 
> MySQL 8.0 버전부터는 위의 쿼리와 같이 IN 절에 튜플을 그대로 나열해도 인덱스를 최적으로 사용할 수 있게 개선됐다.  
> 
> NOT IN 의 실행 계획은 인덱스 풀 스캔으로 표시되는데, 동등이 아닌 부정형 비교여서 인덱스를 이용해 처리 범위를 줄이는 조건으로는
> 사용할 수 없기 때문이다. 

### 현재 시각 조회(NOW, SYSDATE)
> 두 함수 모두 현재의 시간을 반환하는 함수로서 같은 기능을 수행한다. 
> NOW 함수의 경우 하나의 쿼리에서 모든 NOW 함수는 같은 값을 가지지만 SYSDATE 함수는 하나의 쿼리 내에서도 호출되는 시점에 따라 결괏값이 달라진다.  
> SYSDATE 함수는 두 가지 큰 잠재적인 문제가 있다.  
> * SYSDATE 함수가 사용된 SQL 은 레플리카 서버에서 안정적으로 복제되지 못한다.  
> * SYSDATE 함수와 비교되는 칼럼은 인덱스를 효율적으로 사용하지 못한다.  
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
모두 하나의 인덱스에 연속해서 포함돼 있을 때 이 방식으로 인덱스를 사용할 수 있다. 이 방법은 나머지 2가지 방식보다 훨씬 빠른 성능을 보이기
때문에 가능하면 이 방식으로 처리할 수 있게 쿼리를 튜닝하거나 인덱스를 생성하는 것이 좋다.
>
> * where 절만 인덱스를 이용: order by 절은 인덱스를 이용한 정렬이 불가능하며, 인덱스를 통해 검색된 결과 레코드를 별도의 정렬 처리 과정(Using filesort)
을 거쳐 정렬을 수행한다. 주로 이 방법은 where 절의 조건에 일치하는 레코드의 건수가 많지 않을 때 효율적인 방식이다.
>
> * order by 절만 인덱스를 이용: order by 절은 인덱스를 이용해 처리하지만 where 절은 인덱스를 이용하지 못한다.
이 방식은 order by 절의 순서대로 인덱스를 읽으면서 레코드 한 건씩 where 절의 조건에 일치하는지 비교하고, 일치하지 않을 때는 버리는 형태로 처리한다.
주로 아주 많은 레코드를 조회해서 정렬해야 할 때는 이런 형태로 튜닝하기도 한다.
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
> count() 함수는 칼럼이나 표현식을 인자로 받으며, 특별한 형태로 `*` 를 사용할 수도 있다. 여기서 `*` 는 select 절에 사용될 때처럼 모든 칼럼을 가져오라는
> 의미가 아니라 그냥 레코드 자체를 의미하는 것이다. 그래서 count(*) 를 사용하든 count(1) 을 사용하건 동일한 처리 성능을 보인다.  
> 
> 대부분 `count(*)` 쿼리는 페이징 처리를 위해 사용할 때가 많은데, `count(*)` 쿼리에서 order by 절은 어떤 경우에도 필요치 않음으로 order by 절은 제거하여 사용한다. 
> 그리고 left join 또한 레코드 건수의 변화가 없거나 아우터 테이블에서 별도의 체크를 하지 않아도 되는 경우에는 모두 제거하는 것이 성능상 좋다.    
> MySQL 8.0 버전부터는 `select count(*)` 쿼리에 사용된 order by 절은 옵티마이저가 무시하도록 개선되었다. 하지만 가독성 및 오해를 줄이기 위해서 select count(*)
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
> InnoDB 의 경우 order by 를 사용하지 않았을 때 인덱스를 사용하였다면 인덱스의 순서에 맞게 가져오게되며 풀 테이블 스캔 시 클러스터링 인덱스인 PK 의 순서로 
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
> `FOR UPDATE NOWAIT` 는 select 하려는 레코드가 다른 트랜잭션에 의해 이미 잠겨진 상태라면 즉시 에러를 반환한다.
> 응용 프로그램에서 락을 기다리지 않고 즉시 다른 처리를 수행하거나 다시 트랜잭션을 시작하도록 구현해야 할 때도 유용하게 사용할 수 있다.  
> 
> `FOR UPDATE SKIP LOCKED` 는 select 하려는 레코드가 다른 트랜잭션에 의해 이미 잠겨진 상태라면 에러를 반환하지 않고 잠긴 레코드는 무시하고 잠금이 걸리지
> 않은 레코드만 가져온다.  
> 이는 큐(Queue)와 같은 기능을 MySQL 에 구현할 때 좋다. 

### INSERT
> 일반적으로 온라인 트랜잭션 서비스에서 INSERT 문장은 대부분 1건 또는 소량의 레코드를 INSERT 하는 형태이므로 그다지 성능에 대해서 고려할 부분이 많지 않다.  
> 오히려 많은 INSERT 문장이 동시에 실행되는 경우 INSERT 문장 자체보다는 테이블 구조가 성능에 더 큰 영향을 미친다. 하지만 많은 경우 INSERT 의 성능과 SELECT 의
> 성능을 동시에 빠르게 만들수 있는 테이블 구조는 없다. 그래서 INSERT 와 SELECT 성능을 어느 정도 타협하면서 테으블 구조를 설계해야 한다. 
>  
> 테이블의 세컨더리 인덱스는 SELECT 문장의 성능을 높이지만, 반대로 INSERT 성능은 떨어진다. 그래서 테이블에 세컨더리 인덱스가 많을수록, 그리고 테이블이 클수록
> INSERT 성능은 떨어진다. 이러한 이유로 테이블의 세컨더리 인덱스를 너무 남용하는 것은 성능상 좋지 않다.  
> 
> 프라이머리 키는 INSERT 성능을 결정하는 가장 중요한 부분이다.  
> InnoDB 스토리지 엔진을 사용하는 테이블의 프라이머리 키는 클러스터링 키인데, 이는 세컨더리 인덱스를 이용하는 쿼리보다 프라이머리 키를 이용하는 쿼리의 성능이
> 훨씬 빨라지는 효과를 낸다. 그래서 프라이머리 키는 단순히 INSERT 성능만을 위해 설계해서는 안 된다. 프라이머리 키의 선정은 "INSERT 성능" 과 "SELECT 성능"의
> 대립되는 두 가지 요소 중에서 하나를 선택해야 함을 의미한다.  
> 
> 대부분 온라인 트랜잭션 처리를 위한 테이블들은 쓰기(INSERT/UPDATE/DELETE) 보다는 읽기(SELECT) 쿼리의 비율이 압도적으로 높다. SELECT 는 거의 실행되지 않고
> INSERT 가 매우 많이 실행되는 테이블이라면 테이블의 프라이머리 키를 단조 증가 또는 단조 감소하는 패턴의 값을 선택하는 것이 좋다.  
> 주로 로그를 저장하는 테이블이 이런 류에 속한다. 하지만 상품이나 주문, 사용자 정보와 같이 중요 정보를 가진 테이블들은 쓰기에 비해 읽기 비율이 압도적으로 높은 경우가 많다.  
> 이러한 류의 테이블에 대해서는 INSERT 보다는 SELECT 쿼리를 빠르게 만드는 방향으로 프라이머리 키를 선정해야 한다.  
> 일반적으로 SELECT 에 최적화된 프라이머리 키는 단조 증가나 단조 감소 패턴과는 거리가 먼 경우가 많지만, 여전히 빈번하게 실행되는 SELECT 쿼리의 조건을 기준으로
> 프라이머리 키를 선택하는 것이 좋다.  
> 
> 또한 SELECT 는 많지 않고 INSERT 가 많은 테이블에 대해서는 인덱스의 개수를 최소화하는 것이 좋다. 반면 INSERT 는 많지 않고 SELECT 가 많은 테이블에 대해서는
> 쿼리에 맞게 필요한 인덱스들을 추가해도 시스템 전반적으로 영향도가 크지 않다. 물론 SELECT 가 많은 테이블에 대해서는 자연적으로 세컨더리 인덱스가 많아진다.  
> 
> **Auto-Increment 칼럼**  
> SELECT 보다는 INSERT 에 최적화된 테이블을 생성하기 위해서는 다음 두 가지 요소를 갖춰 테이블을 준비하면 된다.  
> * 단조 증가 또는 단조 감소되는 값으로 프라이머리 키 선정  
> * 세컨더리 인덱스 최소화  
> 
> 자동 증가 값을 프라이머리 키로 해서 테이블을 생성하는 것은 MySQL 서버에서 가장 빠른 INSERT 를 보장하는 방법이다. 

### UPDATE 와 DELETE
> UPDATE 와 DELETE 는 WHERE 조건절에 일치하는 모든 레코드를 업데이트하는 것이 일반적인 처리 방식이다. 하지만 MySQL 에서는 UPDATE 나 DELETE 문장에 
> ORDER BY 절과 LIMIT 절을 동시에 사용해 특정 칼럼으로 정렬해서 상위 몇 건만 변경 및 삭제하는 것도 가능하다. 한 번에 너무 많은 레코드를 변경 및 삭제하는 작업은
> MySQL 서버에 과부하를 유발하거나 다른 커넥션의 쿼리 처리를 방해할 수도 있다. 이 때 LIMIT 을 이용해 조금씩 잘라서 변경하거나 삭제하는 방식을 손쉽게 구현할 수 있다.  
> 예시)
> ```sql
> DELETE FROM employee ORDER BY last_name LIMIT 10;
> ```
> 복제가 구축된 MySQL 서버에서 바이너리 로그 포맷이 ROW 가 아닌 STATEMENT 인 경우에는 주의해서 사용이 필요하다. ROW 인 경우에는 상관이 없지만
> STATEMENT 의 경우 경고가 발생하는데 ORDER BY 에 의해 정렬되는 값의 순서가 소스 서버와 레플리카 서버가 달라질 수 있기 때문이다.  
> 
> **JOIN UPDATE**  
> 두 개 이상의 테이블을 조인해 조인된 결과 레코드를 변경 및 삭제하는 쿼리를 JOIN UPDATE 라고 한다.  
> 조인된 테이블 중에서 특정 테이블의 칼럼값을 다른 테이블의 칼럼에 업데이트해야 할 때 주로 조인 업데이트를 사용한다. 
> 꼭 다른 테이블의 칼럼값을 참조하지 않더라도 조인되는 양쪽 테이블에 공통으로 존재하는 레코드만 찾아서 업데이트하는 용도로도 사용할 수 있다.  
> 
> 일반적으로 JOIN UPDATE 는 조인되는 모든 테이블에 대해 읽기 참조만 되는 테이블은 읽기 잠금이 걸리고, 칼럼이 변경되는 테이블은 쓰기 잠금이 걸린다. 
> 그래서 JOIN UPDATE 문장이 웹 서비스 같은 OLTP 환경에서는 데드락을 유발할 가능성이 높으므로 너무 빈번하게 사용하는 것은 피하는 것이 좋다. 
> 하지만 배치 프로그램이나 통계용 UPDATE 문장에서는 유용하게 사용할 수 있다.  
> 
> JOIN UPDATE 문장에서는 `GROUP BY` 나 `ORDER BY` 절은 사용할 수 없다. 
> 이렇게 문법적으로 지원하지 않는 SQL 에 대해서는 서브쿼리를 이용한 파생 테이블을 사용하여 처리한다.

### 스키마 조작(DDL)
> **온라인 DDL**  
> 온라인 DDL 은 스키마를 변경하는 작업 도중에도 다른 커넥션에서 해당 테이블의 데이터를 변경하거나 조회하는 작업을 가능하게 해준다.  
> MySQL 8.0 버전에서는 `old_alter_table` 시스템 변수의 기본값이 OFF 로 설정되어 있기 때문에 자동으로 온라인 DDL 이 활성화된다. 
> `ALTER TABLE` 명령을 실행하면 MySQL 서버는 다음과 같은 순서로 스키마 변경에 적합한 알고리즘을 찾는다.
> 1. `ALGORITHM=INSTANT` 로 스키마 변경이 가능한지 확인 후, 가능하다면 선택 
> 2. `ALGORITHM=INPLACE` 로 스키마 변경이 가능한지 확인 후, 가능하댜면 선택 
> 3. `ALGORITHM=COPY` 알고리즘 선택
> 
> * INSTANT: 테이블의 데이터는 전혀 변경하지 않고, 메타데이터만 변경하고 작업을 완료한다. 테이블이 가진 레코드 건수와 무관하게 작업 시간은 매우 짧다. 
> 스키마 변경 도중 테이블의 읽고 쓰기는 대기하게 되지만 스키마 변경 시간이 매우 짧기 때문에 다른 커넥션의 쿼리 처리에는 크게 영향을 미치지 않는다.
> * INPLACE: 임시 테이블로 데이터를 복사하지 않고 스키마 변경을 실행한다. 레코드의 복사 작업은 없지만 테이블의 모든 레코드를 리빌드해야 하기 때문에
> 테이블의 크기에 따라 많은 시간이 소요될 수도 있다. 하지만 스키마 변경 중에도 테이블의 읽기와 쓰기가 모두 가능하다.
> * COPY: 변경된 스키마를 적용한 임시 테이블을 생성하고, 테이블의 레코드를 모두 임시 테이블로 복사한 후 최종적으로 임시 테이블을 RENAME 해서 스키마 변경을 완료한다.
> 이 방법은 테이블 읽기만 가능하고 DML(INSERT, UPDATE, DELETE)은 실행할 수 없다. 
> 
> 온라인 DDL 명령은 알고리즘과 함께 잠금 수준도 명시할 수 있다. `ALGORITHM` 과 `LOCK` 옵션이 명시되지 않으면 MySQL 서버가 적절한 수준의 알고리즘과 잠금 
> 수준을 선택하게 된다. 
> 예시) 
> ```sql
> ALTER TABLE salary CHANGE to_date end_date DATE NOT NULL,
>    ALGORITHM=INPLACE, LOCK=NONE;
> ```
>
> 온라인 DDL 에서 INSTANT 알고리즘은 테이블의 메타데이터만 변경하기 때문에 매우 짧은 시간 동안의 메타데이터 잠금만 필요로 하다. 그래서 INSTANT 알고리즘을
> 사용하는 경우에는 LOCK 옵션은 명시할 수 없다.  
> INPLACE 나 COPY 알고리즘을 사용하는 경우 LOCK 은 다음 3가지 중 하나를 명시할 수 있다.  
> * NONE: 아무런 잠금을 걸지 않음.
> * SHARED: 읽기 잠금을 걸고 스키마 변경을 실행하기 때문에 스키마 변경 중 읽기는 가능하지만 쓰기(INSERT, UPDATE, DELETE)는 불가함.
> * EXCLUSIVE: 쓰기 잠금을 걸고 스키마 변경을 실행하기 때문에 테이블의 읽고 쓰기가 불가함.  
> 
> ALTER TABLE 문장에 ALGORITHM 및 LOCK 을 명시해서 온라인 DDL 알고리즘을 강제할 수 있다. 물론 이렇게 온라인 DDL 알고리즘을 강제한다고 해서 무조건 
> 그 알고리즘으로 처리되는 것은 아니다. 하지만 명시된 알고리즘으로 온라인 DDL 이 처리되지 못한다면 단순히 에러만 발생시키고 실제 스키마 변경 작업은 시작되지 
> 않기 때문에 의도하지 않은 잠금과 대기는 발생하지 않는다.  
> 
> 다음 순서로 ALGORITHM 과 LOCK 옵션을 시도해보면서 해당 알고리즘이 지원되는지 여부를 판단한다.  
> 1. `ALGORITHM=INSTANT` 옵션으로 스키마 변경 시도
> 2. 실패하면 `ALGORITHM=INPLACE, LOCK=NONE` 옵션으로 스키마 변경 시도
>
> 실행하고자 하는 스키마 변경 작업으로 인해 DML(INSERT, UPDATE, DELETE) 이 멈춰서는 안 된다면 여기까지만 해보면 된다.
> 
> 3. 실패하면 `ALGORITHM=INPLACE, LOCK=SHARED` 옵션으로 스키마 변경 시도
> 4. 실패하면 `ALGORITHM=COPY, LOCK=SHARED` 옵션으로 스키마 변경 시도
> 5. 실패하면 `ALGORITHM=COPY, LOCK=EXCLUSIVE` 옵션으로 스키마 변경 시도
> 
> 위의 1번과 2번 옵션으로 스키마 변경이 되지 않는다면 점검(서비스를 멈추고)을 걸고 DML 을 멈춘 다음 스키마 변경을 해야 한다는 것을 확인할 수 있다.  
> 하지만 온라인 DDL 이라고 하더라도 그만큼 MySQL 서버에 부하를 유발할 수 있으며, 그로 인해 다른 커넥션의 쿼리들이 느려질 수도 있다. 그래서 
> 스키마 변경 시 서버의 자원 사용률을 확인하면서 진행하자.  
> 
> 온라인 DDL 이 INSTANT 알고리즘을 사용하는 경우 거의 시작과 동시에 작업이 완료되기 때문에 작업 도중 실패할 가능성은 거의 없다.  
> 하지만 INPLACE 알고리즘으로 실행되는 경우 내부적으로 테이블 리빌드 과정이 필요하고 최종 로그 적용 과정이 필요해서 중간 과정에서 실패할 가능성이 
> 상대적으로 높은 편이다. 
> 
> 온라인 DDL 을 포함한 모든 ALTER TABLE 명령은 MySQL 서버의 `performance_schema` 를 통해 진행 상황을 모니터링할 수 있다.  
> ```sql
> -- // performance_schema 시스템 변수 활성화(MySQL 서버 재시작 필요)
> SET GLOBAL performance_schema=ON;
> 
> -- // 'stage/innodb/alter%' instrument 활성화 
> UPDATE performance_schema.set_up_instruments
>   SET ENABLED = 'YES', TIMED = 'YES'
>   WHERE NAME LIKE 'stage/innodb/alter%';
> 
> -- // '%stages%' consumer 활성화
> UPDATE performance_schema.setup_consumers
>   SET ENABLED = 'YES'
>   WHERE NAME LIKE '%stages%';
> 
> -- // 스키마 변경 시 진행 상황 조회 
> SELECT EVENT_NAME, WORK_COMPLETED, WORK_ESTIMATED
>   FROM performance_schema.events_stages_current;
> 
> -- // 스키마 변경이 완료되어서 performance_schema.events_stages_current 테이블 조회 시 결과가 안나오면 history 테이블 조회
> SELECT EVENT_NAME, WORK_COMPLETED, WORK_ESTIMATED
>   FROM performance_schema.events_stages_history;
> ```
> 
> **데이터베이스 변경**  
> 다른 RDBMS 에서는 스키마(Schema)와 데이터베이스를 구분해서 관리하지만 MySQL 서버에서는 스키마와 데이터베이스는 동격의 개념이다.  
> 
> 데이터베이스 생성: `CREATE DATABASE [IF NOT EXISTS] <Database 명>;`    
> 데이터베이스 목록: `SHOW DATABASES;`  
> 데이터베이스 선택: `USE <Database 명>;`    
> 데이터베이스 속성 변경: `ALTER DATABASE <Database 명> CHARACTER SET=euckr COLLATE=euckr_korean_ci;`    
> 데이터베이스 삭제: `DROP DATABASE [IF EXISTS] <Database 명>;`  
> 
> **테이블 변경**  
> 테이블 구조 조회:   
> 1.`SHOW CREATE TABLE <Table 명>;`: 최초 테이블을 생성할 때 사용자가 실행한 내용을 그대로 보여주는 것이 아니다. MySQL 서버가 테이블의 메타 정보를
> 읽어서 이를 CREATE TABLE 명령으로 재적성해서 보여주는 것이다.  
> 2.`DESC <Table 명>;`: 테이블의 칼럼 정보를 보기 편한 표 형태로 표시해준다. 하지만 인텍스 칼럼의 순서나 외래키, 테이블 자체의 속성을 보여주지는 않으므로
> 테이블의 전체적인 구조를 한 번에 확인하기는 어렵다.  
> 
> **테이블 명 변경**  
> ```sql
> RENAME TABLE table1 TO table2; 
> RENAME TABLE db1.table1 TO db2.table2;
> ```
> RENAME TABLE 명령은 단순히 테이블의 이름 변경뿐만 아니라 다른 데이터베이스로 테이블을 이동할 때도 사용할 수 있다.  
> 
> 테이블 명을 두고 신규 테이블로 변환하고 싶은 경우 다음과 같이 여러 테이블의 RENAME 명령을 하나의 문장으로 묶어서 실행할 수 있다.  
> ```sql
> RENAME TABLE employees TO employees_old
>              employees_new TO employees;
> ```
> 예를 들어 employees 라는 테이블 명을 두고 employees_new 테이블을 만들어서 기존 employees 테이블을 employees_old 로 변경 후
> employees_new 테이블을 employees 로 변경하고 싶은 경우 다음과 같이 하나의 문장으로 묶어서 실행하면 RENAME TABLE 명령에 명시된 모든 테이블에 대해
> 잠금을 걸고 테이블의 이름 변경 작업을 실행하게 된다. 응용 프로그램의 입장에서 보면 employees 테이블을 조회하려고 할 때 이미 잠금이 걸려있기 때문에 대기한다.
> 그리고 RENAME TABLE 명령이 완료되면 employees 테이블의 잠금이 해제되어 employees 테이블의 읽기를 실행한다. 즉 쿼리가 시작될 때와 실제 쿼리를 실행할 때의
> 대상 테이블이 변경됐지만 응용 프로그램은 이를 알아차리지 못하고 투명하게 실행되는 것이다. 잠깐의 잠금 대기가 발생하는 것이지 에러가 발생하지는 않는다.  
> 
> **테이블 상태 조회**  
> ```sql
> SELECT * FROM information_schema.TABLES 
> WHERE TABLE_SCHEMA='<Database 명>' AND TABLE_NAME='<Table 명>';
> ```
> 
> 데이터베이스 디스크 공간 정보 조회  
> ```sql
> SELECT TABLE_SCHEMA,
>   SUM(DATA_LENGTH)/1024/1024 as data_size_mb,
>   SUM(INDEX_LENGTH)/1024/1024 as index_size_mb
> FROM information_schema.TABLES
> GROUP BY TABLE_SCHEMA;
> ```
> 
> **테이블 구조 복사**  
> `CREATE TABLE temp_employees LIKE employees;`: employees 테이블의 모든 칼럼 및 인덱스가 같은 temp_employees 테이블을 생성한다.  
> `INSERT INTO temp_employees SELECT * FROM employees`: employees 테이블의 모든 데이터를 temp_employees 테이블에 INSERT 한다.  
> 
> **테이블 삭제**  
> 일반적으로 MySQL 에서 레코드가 많지 않은 테이블을 삭제하는 작업은 서비스 도중이라고 하더라도 문제가 되지 않는다.  
> 하지만 용량이 매우 큰 테이블을 삭제하는 작업은 상당히 부하가 큰 작업에 속한다. 테이블이 삭제되면 MySQL 서버는 해당 테이블이 사용하던 데이터 파일을
> 삭제해야 하는데, 이 파일의 크기가 매우 크고 디스크에서 파일의 조각들이 너무 분산되어 저장돼 있다면 많은 디스크 읽고 쓰기 작업이 필요하다. 
> 테이블 삭제가 직접 다른 커넥션의 쿼리를 방해하지는 않지만 간접적으로 영향을 미칠 수도 있다. 그래서 테이블이 크다면 서비스 도중에 삭제 작업(DROP TABLE)은
> 수행하지 않는 것이 좋다.  
> 
> **칼럼 삭제**  
> ```sql
> ALTER TABLE employees DROP COLUMN emp_telno,
> ALGORITHM=INPLACE, LOCK=NONE;
> ```
> 칼럼을 삭제하는 작업은 항상 테이블의 리빌드를 필요로 하기 때문에 INSTANT 알고리즘을 사용할 수 없다. 그래서 항상 INPLACE 알고리즘으로만 칼럼 삭제가
> 가능하다.
> 
> **인덱스 조회**  
> ```sql
> SHOW INDEX FROM <Table 명>;
> ```
> `Seq_in_index`: 단일 칼럼으로 생성된 인덱스는 1만 표시되며, 복합 칼럼 인덱스인 경우 1부터 2,3,4 형태로 증가한다.  
> `Cardinality`: 유니크한 값의 개수를 보여준다.  
> 
> **인덱스 가시성 변경**  
> MySQL 8.0 버전부터는 인덱스를 삭제하기 전에 먼저 해당 인덱스를 보이지 않게 변경해서 하루 이틀 정도 상황을 모니터링한 후 안전하게 인덱스를 삭제할 수 있게 됐다.  
> 인덱스가 사용되지 못하게 하는 DDL 문장: `ALTER TABLE employees ALTER INDEX ix_firstname INVISIBLE;`  
> 인덱스를 다시 사용할 수 있게하는 DDL 문장: `ALTER TABLE employees ALTER INDEX ix_firstname VISIBLE;`  
> 인덱스를 최초 생성 시 사용되지 못하게 하는 DDL 문장: `ALTER TABLE employees ADD INDEX ix_firstname(first_name) INVISIBLE;`  
> 
> 새로 생성하는 인덱스가 적절한 성능을 낼 수 있는지 불분명하다면 INVISIBLE 로 인덱스를 생성하고, 적절히 부하가 낮은 시점을 골라서 인덱스를 VISIBLE 로 
> 변경하여 테스트해볼 수 있다. 서버의 성능이 떨어진다면 다시 INVISIBLE 로 바꾸고 원인을 좀 더 분석해볼 수도 있다.
> 
> **활성 트랜잭션 조회**  
> 5초 이상 활성 상태로 남아있는 프로세스만 조사하는 쿼리
> ```sql
> SELECT trx_id,
>   (SELECT CONCAT(user, '@', host)
>    FROM information_schema.processlist
>    WHERE id=trx_mysql_thread_id) AS source_info,
>   trx_state,
>   trx_started,
>   now(),
>   (unix_timestamp(now()) - unix_timestamp(trx_started)) AS lasting_sec,
>   trx_requested_lock_id,
>   trx_wait_started,
>   trx_mysql_thread_id,
>   trx_tables_in_use,
>   trxt_tables_locked
> FROM information_schema.innodb_trx
> WHERE (unix_timestamp(now()) - unix_timestamp(trxt_started)) > 5 \G
> ```
> 
> trx_id 가 어떤 레코드에 대해서 잠금을 가지고 있는지 확인하는 쿼리는 다음과 같다.
> ```sql
> SELECT * FROM performance_schema.data_locks \G
> ```
> 
> **쿼리 테스트 횟수**  
> 일반적으로 쿼리의 성능 테스트는 콜드 상태(캐시나 버퍼가 모두 초기화된 상태)가 아닌 워밍업된 상태(캐시나 버퍼가 필요한 데이터로 준비된 상태)를 가정하고
> 테스트하는 편이다. 어느 정도 사용량이 있는 서비스라면 콜드 상태에서 워밍업 상태로 전환하는 데 그다지 오래 걸리지 않기 때문에 서비스 환경의 쿼리는 대부분 콜드 상태보다는
> 워밍업된 상태에서 실행된다고 불 수 있다.  
> 
> 테스트하려는 쿼리를 번갈아 가면서 6~7번 정도 실행한 후, 처음 한두 번의 결과는 버리고 나머지 결과의 평균값을 기준으로 비교하는 것이 좋다. 처음에는 운영체제 캐시나
> MySQL 의 버퍼 풀이 준비되지 않을 때가 많아서 대체로 많은 시간이 소요되는 편이어서 편차가 클 수 있기 때문이다.  

---

## 확장 검색
### 전문 검색
> MySQL 서버에서는 다음 2가지 알고리즘을 이용해 인덱싱할 토큰을 분리해낸다.  
> * 형태소 분석(서구권 언어의 경우 어근 분석) 
> * n-gram 파서
> 
> MySQL 서버에서는 형태소 분석이나 어근 분석 기능은 구현돼 있지 않다.  
> n-gram 은 문장 자체에 대한 이해 없이 공백과 같은 띄어쓰기 단위로 단어를 분리하고, 그 단어를 단순히 주어진 길이(n-gram 의 n 은 1~10 사이의 숫자 값)로 쪼개서 
> 인덱싱하는 알고리즘이다.  
>
> n-gram 알고리즘에서 n의 값을 2로한 bi-gram 혹은 3으로 한 tri-gram 이 가장 일반적으로 사용된다.  
> bi-gram 과 tri-gram 을 설정하는 시스템 변수인 `ngram_token_size` 는 읽기 전용이며, MySQL 서버의 설정 파일을 이용해 서버가 시작될 때만 변경할 수 있다.  
> 
> **테이블 생성 시 인덱스 설정 쿼리**  
> ```sql
> CREATE TABLE tb_bi_gram (
>   id BIGINT NOT NULL AUTO_INCREMENT,
>   title VARCHAR(100),
>   body TEXT,
>   PRIMARY KEY(id),
>   FULLTEXT INDEX fx_msg(title, body) WITH PARSER ngram
> );
> ```
> 
> **검색 쿼리**  
> ```sql
> -- 자연어 검색
> SELECT COUNT(*) FROM tb_bi_gram
>   WHERE MATCH(title, body) AGAINST ('단편');
> 
> -- 불리언 검색
> SELECT COUNT(*) FROM tb_bi_gram
>   WHERE MATCH(title, body) AGAINST ('적인' IN BOOLEAN MODE);
> ```
> 
> 검색어의 길이가 ngram_token_size 보다 작은 경우에는 검색이 불가능하다. 예를 들어, ngram_token_size=2 인 bi-gram 인 경우 2글자 이상의 검색어는 사용 가능하지만
> 1글자 검색어는 결과를 가져오지 못한다. 이러한 특성 때문에 한글에서는 ngram_token_size 의 값으로 2가 범용적으로 적절한 선택이 될 것이다.  

### 전문 검색 쿼리 모드
> **자연어 검색(NATURAL LANGUAGE MODE)**  
> 전문 검색 쿼리에서 특별히 모드를 지정하지 않으면 자연어 검색 모드가 사용된다.  
> MySQL 서버의 자연어 검색은 검색어에 제시된 단어들을 많이 가지고 있는 순서대로 정렬해서 결과를 반환한다.  
> 전문 검색 쿼리의 검색어에는 반드시 단일 단어만 사용되는 것은 아니다. 문장도 사용할 수 있다.  
> 
> **불리언 검색(BOOLEAN MODE)**  
> 불리언 검색은 쿼리에 사용되는 검색어의 존재 여부에 대해 논리적 연산이 가능하다. 검색어에 +, - 기호를 이용해서 +기호가 붙은 검색어는 검색에 포함하지만 -기호가 붙은
> 검색어는 검색에 포함하지 않도록 설정이 가능하다.  

### 전문 검색 인덱스 디버깅
> MySQL 서버에서는 전문 검색 쿼리 오류의 원인을 쉽게 찾을 수 있게 다음과 같이 전문 검색 인덱스 디버깅 기능을 제공한다.  
> ```sql
> SET GLOBAL innodb_ft_aux_table = '<DB 명>/<Table 명>';
> ```
> innodb_ft_aux_table 시스템 변수에 전문 검색 인덱스를 가진 테이블이 설정되면 information_schema DB 의 테이블들을 통해 전문 검색 인덱스가 어떻게 저장 및
> 관리되는지를 볼 수 있게 해준다.  
> * information_schema.innodb_ft_config  
> * information_schema.innodb_ft_index_table
> * information_schema.innodb_ft_index_cache
> * information_schema.innodb_ft_deleted

### 공간 검색
> **EGSG:4326**  
> EPSG 코드는 전세계 좌표계 정의에 대한 고유한 명칭입니다.  
> `EGSG:4326` 은 WGS84 타원체의 경위도 좌표계입니다. 흔히 GPS 등의 기본 좌표계입니다.  
> 입력되는 값의 단위는 각도(Degree) 입니다.  

### 지리 좌표계
> 다음 예제에서는 공간 인덱스(Spatial Index)도 같이 생성했는데, 공간 인덱스를 생성하는 칼럼은 반드시 NOT NULL 이어야 한다.  
> GPS 로부터 받는 위치 정보를 저장하기 위해 WGS 84 좌표계(SRID가 4326인 좌표계)로 칼럼을 정의했다.  
> ```sql
> CREATE TABLE sphere_coord (
>   id INT NOT NULL AUTU_INCREMENT,
>   name VARCHAR(20),
>   location POINT NOT NULL SRID 4326,
>   PRIMARY KEY (id),
>   SPATIAL INDEX sx_location(location)
> );
> ```
> 
> POINT 자료형에는 `ST_PointFromText('POINT(<위도 값> <경도 값>)', 4326)` 를 넣는다.  
> 위치 데이터 INSERT 예시
> ```sql
> INSERT INTO sphere_coord VALUES (NULL, '서울숲', ST_PointFromText('POINT(37.544738 127.039074)', 4326));
> ```
> 
> 두 점의 거리를 구하는 함수 `ST_Distance_Sphere` 는 결과값으로 미터(Meter) 값을 반환한다.  
> 예시    
> ```sql
> SELECT id, name,
>   ST_AsText(location) AS location,
>   ROUND(ST_Distance_Sphere(location,
>       ST_PointFromText('POINT(37.547027 127.047337', 4326))) AS distance_meters
> FROM sphere_coord
> WHERE ST_Distance_Sphere(location,
>       ST_PointFromText('POINT(37.547027 127.047337', 4326)) < 1000;
> ```
> 다른 RDBMS 에서는 인덱스를 이용한 반경 검색이 가능하지만, 안타깝게도 MySQL 서버에서는 아직 인덱스를 이용한 반경 검색 기능(함수)이 없다.
> 그래서 위의 쿼리는 공간 인덱스(SPATIAL INDEX)를 이용하지 못하고 풀 테이블 스캔을 이용한다.  
> 
> MySQL 서버에서 지리 좌표계나 SRS 관리 기능이 도입된 것은 MySQL 8.0 이 처음이다. 그래서 지리 좌표계의 데이터 검색 및 변환 기능, 그리고 성능은 
> 미숙한 부분이 보인다. 그래서 MySQL 서버를 이용해 지리 좌표계를 활용하고자 한다면 기능의 정확성이나 성능에 대해 조금은 주의가 필요할 수도 있다.

---

## 파티션
### 개요
> 파티션 기능은 테이블을 논리적으로는 하나의 테이블이지만 물리적으로는 여러 개의 테이블로 분리해서 관리할 수 있게 해준다. 
> 파티션의 기능은 주로 대용량의 테이블을 물리적으로 여러 개의 소규모 테이블로 분산하는 목적으로 사용한다.  
> 하지만 파티션 기능은 대용량 테이블에 사용하면 무조건 성능이 빨라지는 만병통치약이 아니다. 어떤 쿼리를 사용하느냐에 따라 오히려 성능이 더 나빠지는 경우도 
> 자주 발생할 수 있다.  
> 
> **사용하는 경우**    
> 하나의 테이블이 너무 커서 인덱스의 크기가 물리적인 메모리보다 훨씬 크거나 데이터 특성상 주기적인 삭제 작업이 필요한 경우 등이 파티션이 필요한 대표적인 예라고
> 할 수 있다.  
> 
> 인덱스가 커지면 커질수록 SELECT 는 말할 것도 없고, INSERT 나 UPDATE, DELETE 작업도 함께 느려지는 단점이 있다.    
> 특히 한 테이블의 인덱스 크기가 물리적으로 MySQL 이 사용 가능한 메모리 공간보다 크다면 그 영향은 더 심각할 것이다. 테이블의 데이터는 실질적인 물리 메모리보다
> 큰 것이 일반적이겠지만 인덱스의 워킹 셋(Working set)이 실질적인 물리 메모리보다 크다면 쿼리 처리가 상당히 느려질 것이다.  
> 
> 테이블의 모든 데이터가 고루고루 사용되는 것은 아닐 것이다. 그중에서 최신 20~30% 정도의 데이터만 활발하게 조회될 것이다. 대부분의 테이블 데이터가 이런 형태로
> 사용된다고 볼수 있는데, 활발하게 사용되는 데이터를 워킹 셋(Working set)이라고 표현한다.  

### 주의사항
> **파티션의 제약 사항**  
> * 프라이머리 키를 포함해서 테이블의 모든 유니크 인덱스는 파티션 키 칼럼을 포함해야 한다.  
> * 최대 8192개의 파티션을 가질 수 있다.  
> * 파티션 생성 이후 MySQL 서버의 `sql_mode` 시스템 변수 변경은 데이터 파티션의 일관성을 깨뜨릴 수 있다.  
> * 파티션 테이블에서는 외래키를 사용할 수 없다.  
> * 전문 검색/공간 검색과 관련된 칼럼 및 설정을 이용할 수 없다.  
>
> **open_files_limit 시스템 변수 설정**  
> MySQL 에서는 일반적으로 테이블을 파일 단위로 관리하기 때문에 MySQL 서버에서 동시에 오픈된 파일의 개수가 상당히 많아질 수 있다.  
> 이를 제한하기 위해 `open_files_limit` 시스템 변수에 동시에 오픈할 수 있는 적절한 파일의 개수를 설정할 수 있다.  
> 파티션되지 않은 일반 테이블은 테이블 1개당 오픈된 파일의 개수가 2에서 3개 수준이지만 파티션 테이블에서는 (파티션의 개수 * 2에서 3)개가 된다.

### 레인지 파티션
> **용도**  
> * 날짜를 기반으로 데이터가 누적되고 연도나 월, 또는 일 단위로 분석하고 삭제해야 할 때
> * 범위 기반으로 데이터를 여러 파티션에 균등하게 나눌 수 있을 때
> * 파티션 키 위주로 검색이 자주 실행될 때
>
> **이력 데이터의 효율적인 관리**  
> 로그와 같은 이력 데이터의 경우 년도별로 파티션을 나눠서 관리할 수 있다. 이 때 연도가 파티션 키가 되어 사용할 수 있다.  
> 파티션 없이 로그 삭제 시 대량의 데이터가 저장된 테이블을 기간 단위로 삭제한다면 전체적으로 미치는 부하 및 테이블 자체의 동시성에도 영향이 클 수 있다.  
> 하지만 파티션을 이용하면 이러한 문제를 대폭 줄일 수 있다.
> 
> **파티션 삭제**  
> 레인지 파티션을 사용하는 테이블에서 파티션을 삭제할 때 항상 가장 오래된 파티션 순서로만 삭제할 수 있다. 레인지 파티션이 4개가 있는데, 중간에 있는 파티션을
> 먼저 삭제할 수는 없다. 레인지 파티션을 사용하는 테이블에서는 가장 마지막 파티션만 새로 추가할 수 있고, 가장 오래된 파티션만 삭제할 수 있다.  

### 리스트 파티션
> **용도**  
> * 파티션 키 값이 코드 값이나 카테고리와 같이 고정적일 때
> * 키 값이 연속되지 않고 정렬 순서와 관계없이 파티션을 해야 할 때 
> * 파티션 키 값을 기준으로 레코드의 건수가 균일하고 검색 조건에 파티션 키가 자주 사용될 때 

### 해시 파티션
> **용도**  
> * 레인지 파티션이나 리스트 파티션으로 데이터를 균등하게 나누는 것이 어려울 때
> * 테이블의 모든 레코드가 비슷한 사용 빈도를 보이지만 테이블이 너무 커서 파티션을 적용해야 할 때 
> 
> 해시 파티션이나 키 파티션의 대표적인 용도로는 회원 테이블을 들 수 있다. 회원 정보는 가입 일자가 오래돼서 사용되지 않거나 최신이어서 더 빈번하게 사용되거나
> 하지 않는다. 또한 회원의 지역이나 취미 같은 정보 또한 사용 빈도에 미치는 영향이 거의 없다. 이처럼 테이블의 데이터가 특정 칼럼의 값에 영향을 받지 않고, 
> 전체적으로 비슷한 사용 빈도를 보일 때 적합한 파티션 방법이다.  
> 
> **주의사항**  
> * 해시 파티션의 파티션 키 또는 파티션 표현식은 반드시 정수 타입의 값을 반환해야 한다.  
> * 일반적으로 사용자들에게 익순한 파티션의 조작이나 특성은 대부분 리스트 파티션이나 레인지 파티션에만 해당하는 것들이 많다. 해시 파티션이나 키 파티션을 사용하거나 
> 조작할 때는 주의가 필요하다.

### 키 파티션
> 키 파티션은 해시 파티션과 사용법과 특성이 거의 값다. 다른 점은 키 파티션에서는 정수 타입이나 정숫값을 반환하는 표현식뿐만 아니라 대부분의 데이터 타입에 대해
> 파티션 키를 적용할 수 있다.  
> 
> **주의사항 및 특이사항**  
> * 키 파니션은 파티션 키가 반드시 정수 타입이 아니어도 된다. 해시 파티션으로 파티션이 어렵다면 키 파티션 적용을 고려해보자.
> * 해시 파티션에 비해 파티션 간의 레코드를 더 균등하게 분할할 수 있기 때문에 키 파티션이 더 효율적이다. 

### 파티션 테이블의 쿼리 성능
> 파티션 테이블에 쿼리가 실행될 때 테이블의 모든 파티션을 읽을지 아니면 일부 파티션만 읽을지는 성능에 아주 큰 영향을 미친다. 쿼리의 실행 계획이 수립될 때 불필요한
> 파티션은 모두 배제하고 꼭 필요한 파티션만을 걸러내는 과정을 `파티션 프루닝(Partition pruning`이라고 하는데, 쿼리의 성능은 테이블에서 얼마나 많은
> 파티션을 프루닝할 수 있는지가 관건이다. 
> 
> 테이블을 10개로 파티션해서 10개의 파티션 중에서 주로 1~3개 정도의 파티션만 읽고 쓴다면 파티션 기능이 성능 향상에 도움이 될 것이다.
> 그런데 10개로 파티션하고 파티션된 10개를 아주 균등하게 사용한다면 이는 성능 향상보다는 오히려 오버헤드만 심해지는 결과를 가져올 수 있다.
> (파티션 마다 나누어져 있는 인덱스를 버퍼풀에 올려야함으로 10개를 균등하게 사용하게되면 10개의 인덱스를 모두 버퍼풀에 로드해야하기 때문이다.)  
> 파티션을 사용할 때는 반드시 파티션 프루닝이 얼마나 도움이 될지를 먼저 예측해보고 응용 프로그램에 적용하자.

---

## 데이터 타입
### 문자열(CHAR 와 VARCHAR)
> 하나의 글자가 CHAR 타입에 저장될 때는 추가 공간이 더 필요하지 않지만 VARCHAR 타입에 저장할 때는 문자열의 길이를 관리하기 위한 1~2바이트 공간을 추가로
> 더 사용한다. VARCHAR 타입의 길이가 255바이트 이하이면 1바이트만 사용하고, 256바이트 이상으로 설정되면 2바이트를 사용한다. VARCHAR 타입의 최대 길이는 2바이트로
> 표현할 수 있는 이상은 사용할 수 없다. 즉, VARCHAR 타입의 최대 길이는 65,566 바이트 이상으로 설정할 수 없다.  
> 
> CHAR 와 VARCHAR 타입의 선택 기준은 값의 길이도 중요하지만, 해당 칼럼의 값이 얼마나 자주 변경되느냐가 기준이 돼야 한다.  
> 
> 주민등록번호처럼 항상 값의 길이가 고정적일 때는 당연히 CHAR 타입을 사용해야 한다. 또한 값이 2에서 3바이트씩 차이가 나더라도 자주 변경될 수 있는 부서 번호나
> 게시물의 상태 값 등은 CHAR 타입을 사용하는 것이 좋다. 자주 변경돼도 레코드가 물리적으로 다른 위치로 이동하거나 분리되지 않아도 되기 때문이다. 
> 레코드의 이동이나 분리는 CHAR 타입으로 인해 발생하는 2애서 3바이트 공간 낭비보다 더 큰 공간이나 자원을 낭비하게 만든다.  
> 
> CHAR 나 VARCHAR 키워드 뒤에 인자로 전달하는 숫자는 그 칼럼의 바이트 크기가 아니라 문자의 수를 의미한다. 즉, CHAR(10) 또는 VARCHAR(10) 으로 칼럼을
> 정의하면 이 칼럼은 10바이트를 저장할 수 있는 공간이 아니라 10글자를 저장할 수 있는 공간을 의미한다. 그래서 CHAR(10) 타입을 사용하더라도 이 칼럼이
> 실제로 디스크나 메모리에서 사용하는 공간은 각각 달라진다.  
> 
> **저장 공간과 스키마 변경(Online DDL)**  
> CHAR, VARCHAR 칼럼의 길이를 63글자로 늘리는 경우와 64글자로 늘리는 경우 Online DDL 명령의 결과는 다음과 같다.  
> ```sql
> // 63 글자로 변경
> ALTER TABLE test MODIFY value VARCHAR(63), ALGORITHM=INPLACE, LOCK=NONE;
> 
> // 64 글자로 변경
> ALTER TABLE test MODIFY value VARCHAR(64), ALGORITHM=COPY, LOCK=SHARED;
> ```
> utf8mb4 문자 집합을 사용하는 경우 1글자당 4바이트를 점유하게 된다. VARCHAR(63) 까지는 최대 길이가 252(63*4)바이트이기 때문에 문자열 값의 길이를 저장하는 
> 공간은 1바이트면 된다. 하지만 VARCHAR(64) 타입은 저장할 수 있는 문자열의 크기가 최대 256바이트까지 가능하기 때문에 문자열 길이를 저장하는 공간의 크기가 2바이트로
> 바뀌어야 한다.  
> 이처럼 문자열 길이를 저장하는 공간의 크기가 바뀌게 되면 MySQL 서버는 스키마 변경을 하는 동안 읽기 잠금(LOCK=SHARED)을 걸어서 아무도 데이터를 변경하지 못하게
> 막고 테이블 레코드를 복사하는 방식으로 처리한다.  
> 
> **문자 집합(캐릭터 셋)**  
> 한글 기반의 서비스에서는 `euckr` 또는 `utf8mb4` 문자 집합을 사용한다. 최근의 웹 서비스나 스마트폰 애플리케이션은 여러 나라의 언어를 동시에 지원하기 위해 
> 기본적으로 UTF-8 문자 집합(utf8mb4)을 사용하는 추세다.  
> 
> **콜레이션(Collation)**  
> 콜레이션은 문자열 칼럼의 값에 대한 비교나 정렬 순서를 위한 규칙을 의미한다. 즉, 비교나 정렬 작업에서 영문 대소문자를 같은 것으로 처리할지, 
> 아니면 더 크거나 작은 것으로 판단할지에 대한 규칙을 정의하는 것이다.  
> 
> utf8mb4 의 디폴트 콜레이션은 `utf8mb4_0900_ai_ci` 이다. 대소문자를 구분하지 않는 콜레이션이라서 대소문자를 구분해서 비교하거나 정렬해야 하는 칼럼에서는 
> `utf8mb4_bin` 콜레이션을 사용하면 된다.    
> 
> "utf8mb4_0900" 콜레이션은 "NO PAD" 옵션으로 인해 문자열 뒤에 존재하는 공백도 유효 문자로 취급되어 비교되고, 이로 인해 기존과는 다른 비교 결과를 보일 수도
> 있으므로 주의해야 한다.  
> 
> **비교 방식**  
> MySQL 서버에서 지원하는 대부분의 문자 집합과 콜레이션에서 CHAR 타입이나 VARCHAR 타입을 비교할 때 공백 문자를 뒤에 붙여서 두 문자열의 길이를 동일하게 만든 후 
> 비교를 수행한다.
> ```sql
> // 아래 쿼리의 결과값은 1로 TRUE 이다.
> SELECT 'ABC'='ABC      ' AS is_equal;
> ```
> 
> 하지만 utf8mb 문자 집합이 UCA 버전 9.0.0 을 지원하면서 문자열 뒤에 붙어있는 공백 문자들에 대한 비교 방식이 달라졌다. 
> utf8mb_0900_xxx 콜레이션을 사용하는 경우 문자열 뒤의 공백이 비교 결과에 영향을 미친다.  
> ```sql
> SET NAMES utf8mb4 COLLATE utf8mb4_0900_bin;
> // 아래 쿼리의 결과값은 0으로 FALSE 이다.
> SELECT 'a' = 'a  ';
> ```

### 숫자
> 숫자를 저장하는 타입은 값의 정확도에 따라 크게 참값(Exact value)과 근삿값 타입으로 나눌 수 있다.  
> * 참값은 소수점 이하 값의 유무와 관계없이 정확히 그 값을 그대로 유지하는 것을 의미한다. 참값을 관리하는 데이터 타입으로는 `INTEGER` 를 포함해 `INT` 로 
> 끝나는 타입과 `DECIMAL` 이 있다.
> * 근삿값은 흔히 부동 소수점이라고 불리는 값을 의미하며, 처음 칼럼에 저장한 값과 조회된 값이 정확하게 일치하지 않고 최대한 비슷한 값으로 관리하는 것을 의미한다.
> 근삿값을 관리하는 타입으로는 `FLOAT` 와 `DOUBLE` 이 있다.
> 
> 십진 표기법을 사용하는 DECIMAL 타입은 이진 표기법을 사용하는 타입(DECIMAL 제외 MySQL 의 모든 숫자 타입)보다 저장 공간을 2배 이상 필요로 한다.  
> 따라서 매우 큰 숫자 값이나 고정 소수점을 저장해야 하는 것이 아니라면 일반적으로 INTEGER 나 BIGINT 타입을 자주 사용한다.  
> 
> **부동 소수점**  
> MySQL 에서 FLOAT 나 DOUBLE 과 같은 부동 소수점 타입은 잘 사용하지 않는다.    
> 부동 소수점 값을 저장해야 한다면 유효 소수점의 자릿수만큼 10을 곱해서 정수로 만들어 그 값을 정수 타입의 칼럼에 저장하는 방법도 생각해볼 수 있다.  
> 예를 들어, 소수점 4자리까지 유효한 GPS 정보를 저장한다고 했을 때 소수점으로 된 좌푯값에 10000을 곱해서 저장하고 조회할 때는 10000으로 나눈 결과를 사용하면
> 된다.  
> 단 위의 경우는 MySQL 의 공간 검색 기능을 위해 저장한다면 POINT 타입으로 저장하며, 단순히 GPS 의 정보를 저장만하는 경우에는 위와같이 정수로 변환해서 저장한다.  
> 
> **DECIMAL**  
> 소수점 이하의 값까지 정확하게 관리하려면 DECIMAL 타입을 이용해야 한다. 다만 소수가 아닌 정숫값을 관리하기 위해 DECIMAL 타입을 사용하는 것은 성능상으로나
> 공간 사용면에서 좋지 않다. 단순히 정수를 관리하고자 한다면 INTEGER 나 BIGINT 를 사용하는 것이 좋다.

### 날짜와 시간
> MySQL 에서 지원하는 날짜나 시간에 관련된 데이터 타입으로 `DATE` 와 `DATETIME` 타입이 많이 사용된다.  
> DATETIME 은 밀리초를 지원하며 밀리초 자릿수를 괄호에 넣어서 사용하면 된다. ex) 밀리초 3자리수: DATETIME(3)  
> 
> MySQL 의 날짜 타입은 칼럼 자체에 타임존 정보가 저장되지 않으므로 DATETIME 이나 DATE 타입은 현재 DBMS 커넥션의 
> 타임존과 관계없이 클라이언트로부터 입력된 값을 그대로 저장하고 조회할 때도 변환없이 그대로 출력한다.
> 하지만 TIMESTAMP 는 항상 UTC 타임존으로 저장되므로 타임존이 달라져도 값이 자동으로 보정된다.  
> 
> MySQL 서버의 칼럼 타입이 TIMESTAMP 든 DATETIME 이든 관계없이, JDBC 드라이버는 날짜 및 시간 정보를 MySQL 타임존에서 
> JVM 의 타임존으로 변환해서 출력한다.  
> 
> 타임존 관련 설정은 한 번 문제가 되기 시작하면 해결하기가 매우 어려운 문제가 될 수 있기 때문에 강제로 타임존을 변환하는 것은 하지말자.  

### ENUM 과 SET
> ENUM 과 SET 모두 문자열 값을 MySQL 내부적으로 숫자 값으로 매핑해서 관리하는 타입이다.  
> 
> **ENUM**  
> ENUM 타입의 가장 큰 용도는 코드화된 값을 관리하는 것이다.  
> ```sql
> CREATE TABLE tb_enum (fd_enum ENUM('PROCESSING', 'FAILUTRE', 'SUCESS'));
> INSERT INTO tb_enum VALUES ('PROCESSING'), ('FAILURE');
> ```
> ENUM 타입은 INSERT 나 UPDATE, SELECT 등의 쿼리에서 CHAR 나 VARCHAR 타입과 같이 문자열처럼 비교하거나 저장할 수 있다.  
> 하지만 MySQL 서버가 실제로 값을 디스크나 메모리에 저장할 때는 사용자로부터 요청된 문자열이 아니라 그 값에 매핑된 정숫값을 사용한다.  
> ENUM 타입에 사용할 수 있는 최대 아이템의 개수는 65,535개이며, 아이템의 개수가 255개 미만이면 ENUM 타입은 저장 공간으로 1바이트를 사용하고, 
> 그 이상인 경우에는 2바이트를 사용한다.  
> 
> MySQL 5.6 버전부터는 새로 추가하는 아이템이 ENUM 타입의 제일 마지막으로 추가되는 형태라면 테이블의 구조(메타데이터) 변경만으로
> 즉시 완료된다.  
> ```sql
> // ENUM 끝에 REFUND 를 추가하는 경우 INSTANT 사용 가능.
> ALTER TABLE tb_enum
> MODIFY fd_enum ENUM('PROCESSING', 'FAILUTRE', 'SUCESS', 'REFUND'))
> ALGORITHM=INSTANT;
> 
> // ENUM 중간에 REFUND 를 추가하는 경우 테이블 리빌드 필요.
> ALTER TABLE tb_enum
> MODIFY fd_enum ENUM('PROCESSING', 'FAILUTRE', 'REFUND', 'SUCESS'))
> ALGORITHM=COPY, LOCK=SHARED;
> ```
> 
> **SET**  
> SET 타입도 테이블의 구조에 정의된 아이템을 정숫값으로 매핑해서 저장하는 방식은 똑같다. SET 은 하나의 칼럼에 1개 이상의 값을 저장할 수 있다는 차이점이 있다.
> ```sql
> CREATE TABLE tb_set (
>     fd_set SET('TENNIS', 'SOCCER', 'GOLF', 'BASKETBALL');
> )
> 
> INSERT INTO tb_set (fd_set) VALUES ('SOCCER'), ('GOLF,TENNIS');
> ```

### TEXT 와 BLOB
> TEXT 와 BLOB 형식의 유일한 차이점은 TEXT 타입은 문자열을 저장하는 대용량 칼럼이라서 문자 집합이나 콜레이션을 가진다는 것이고, BLOB 타입은 이진 데이터
> 타입이라서 별도의 문자 집합이나 콜레이션을 가지지 않는다는 것이다.  
> 
> MySQL 에서는 버전에 따라 조금씩 차이는 있지만 일반적으로 하나의 레코드는 전체 크기가 64KB 를 넘어설 수 없다. VARCHAR 나 VARBINARY 와 같은 가변
> 길이 칼럼은 최대 저장 가능 크기를 포함해 64K로 크기가 제한된다. 레코드의 전체 크기가 64KB 를 넘어서서 더 큰 칼럼을 추가할 수 없다면 일부 칼럼을 
> TEXT 나 BLOB 타입으로 전환해야할 수도 있다.  
> 
> 대용량 BLOB 이나 TEXT 칼럼을 사용하는 쿼리가 있다면 MySQL 서버의 `max_allowed_packet` 시스템 변수를 필요한 만큼 충분히 늘려서 설정하는 것이 좋다.  

### JSON 타입
> MySQL 5.7 버전부터 지원되는 JSON 타입의 칼럼은 JSON 데이터를 문자열로 저장하는 것이 아니라 MongoDB 와 같이 바이너리 포맷의 BSON(Binary JSON) 으로
> 변환해서 저장한다.  
> 
> **부분 업데이트 성능**  
> MySQL 8.01 버전부터는 JSON 타입에 대해 부분 업데이트 기능을 제공한다. JSON 칼럼의 부분 업데이트 기능은 `JSON_SET()` 과 `JSON_REPLACE`, 
> `JSON_REMOVE()` 함수를 이용해 JSON 도큐먼트의 특정 필드 값을 변경하거나 삭제하는 경우에만 작동한다.  
> 
> 부분 업데이트 시 변경된 내용들만 바이너리 로그에 기록되도록 `binlog_row_value_option` 시스템 변수와 `binlog_row_image` 시스템 변수의 설정값을 
> 변경하면 JSON 칼럼의 부분 업데이트의 성능을 훨씬 더 빠르게 만들 수 있다.  
> ```sql
> SET binlog_format = ROW;
> SET binlog_row_value_options = PARTIAL_JSON;
> SET binlog_row_image = MINIMAL;
> ```
> 대략 13배 정도 UPDATE 성능이 개선된다.
> 
> JSON 칼럼에 저장되는 데이터와 JSON 칼럼으로부터 가공되어 나온 결괏값은 모두 `utf8mb4` 문자 집합과 `utf8mb4_bin` 콜레이션을 가진다.  
> 
> **MySQL 에서의 데이터 압축**  
> MySQL 서버의 압축은 디스크의 공간만 줄이는 수준이지 메모리의 사용 효율까지 높여주진 못한다. 또한 MySQL 서버의 데이터 압축은 다른 DBMS 와는 달리 
> 메모리에 압축된 페이지와 압축 해제된 페이지가 공존해야 하기 때문에 메모리 효율과 CPU 효율 모두를 떨어뜨릴 수도 있다.  

---

## 복제
### 개요
> 원본 데이터를 가진 서버를 `소스(Source) 서버`, 복제된 데이터를 가지는 서버를 `레플리카(Replica) 서버` 라고 부른다.  
> 복제 기능은 서비스의 메인 DB 서버인 소스 서버에 문제가 생겼을 때를 대비하려는 목적이 제일 크지만 그 외에도 이처럼 복제를 통한 레플리카 서버를 구축하는 데는
> 여러 가지 목적이 있다.  
> 
> * 스케일 아웃: 읽기 쿼리를 여러 레플리카 서버로 분산 처리할 수 있게 해준다.  
> * 데이터 백업: 소스 서버에서 데이터를 백업하지 않고 데이터 백업용 레플리카 서버를 만들어서 데이터를 백업하면 데이터 백업 중 발생하는 성능 영향을 줄일 수 있다.  
> * 데이터 분석: 차세대 비즈니스 모델을 발굴하기 위해서나 서비스를 좀 더 발전시킬 수 있는 인사이트를 얻기 위해 분석용 쿼리들을 실행하기도 한다.
> 이러한 분석용 쿼리는 대량의 데이터를 조회하는 경우가 많고, 또 집계 연산을 하는 등 쿼리 자체가 굉장히 복잡하고 무거운 경우가 대부분이라서 분석용 레플리카 서버를 
> 만들어서 실행하는 것이 좋다.  

### 바이너리 로그
> MySQL 서버에서 발생하는 모든 변경 사항은 별도의 로그 파일에 순서대로 기록되는데, 이를 바이너리 로그(Binary Log)라고 한다.  
> 바이너리 로그에 기록된 각 변경 정보들을 이벤트(Event)라고도 한다.  

### 복제 데이터 포맷
> MySQL 에서는 실행된 SQL 문을 바이너리 로그에 기록하는 Statement 방식과 변경된 데이터 자체를 기록하는 ROW 방식으로 두 종류의 바이너리 로그 포맷을 제공하며,
> 사용자는 `binlog_format` 시스템 변수를 통해 이 두 가지 종류 중 하나로 설정하거나 혹은 혼합된 형태로 사용하도록 설정할 수 있다.  
> 
> **Statement 기반 바이너리 로그 포맷**  
> Statement 기반 바이너리 포맷은 MySQL 에 바이너리 로그가 처음 도입됐을 때부터 존재해왔던 포맷이다.  
> Statement 포맷의 단점은 Row 포맷으로 복제될 때보다 데이터에 락을 더 많이 건다는 점이다.  
> Statement 기반 바이너리 로그 포맷은 사용할 때 한 가지 제한사항이 있는데, 바로 트랜잭션 격리 수준이 반드시 "REPEATABLE-READ" 이상이어야 한다는 점이다.  
> 
> **Row 기반 바이너리 로그 포맷**  
> Row 기반 바이너리 로그 포맷은 MySQL 5.1 버전부터 도입된 포맷으로, MySQL 서버에서 데이터 변경이 발생했을 때 변경된 값 자체가 바이너리 로그에 기록되는
> 방식이다.  
> Row 기반 바이너리 로그 포맷은 어떤 형태의 쿼리가 실행됐든 간에 복제 시 소스 서버와 레플리카 서버의 데이터를 일관되게 하는 가장 안전한 방식이다.  
> 또한 MySQL 5.7.7 버전부터는 바이너리 로그의 기본 포맷으로 지정되기도 했다.  
> Row 포맷에서는 쿼리가 실행되는 것이 아니라 변경된 데이터가 바로 적용되므로 어떤 변경 이벤트건 더 적은 락을 점유하며 처리된다.    
> 
> MySQL 서버에서 실행된 쿼리가 굉장히 많은 데이터를 변경한 경우에는 변경된 데이터가 전부 기록되므로 바이너리 로그 파일 크기가 단시간에 매우 커질 수 있다.  
> 
> Row 포맷은 모든 트랜잭션 격리 수준에서 사용 가능하며, MySQL 서버의 바이너리 로그 포맷이 Row 포맷으로 설정돼 있다 하더라도 사용자 계정 생성과
> 권한 부여 및 회수 등과 같은 DDL 문은 전부 Statement 포맷 형태로 바이너리 로그에 기록된다.  

### 복제 토폴로지
> **싱글 레플리카 복제 구성**  
> 싱글 레플리카 복제는 하나의 소스 서버에 하나의 레플리카 서버만 연결돼 있는 복제 형태를 말한다.  
> 이 복제 형태는 가장 기본적인 형태로, 제일 많이 사용되는 형태라고 할 수 있다. 이러한 복제 형태에서는 보통 애플리케이션 서버는 소스 서버에만 직접적으로
> 접근해 사용하고 레플리카 서버에는 접근하는 않으며, 레플리카 서버는 소스 서버에서 장애가 발생했을 때 사용될 수 있는 예비 서버 및 데이터 백업 수행을 위한
> 용도로 많이 사용된다. 만약 이 같은 형태에서 애플리케이션 서버가 레플리카 서버에서도 서비스용 읽기 쿼리를 실행한다고 하면 레플리카 서버에 문제가 발생한 경우 
> 서비스 장애 상황이 도래할 수 있다. 따라서 이렇게 소스 서버와 레플리카 서버가 일대일로 구성된 형태에서는 레플리카 서버를 정말 예비용 서버로서만 사용하는 게 
> 제일 적합하다고 할 수 있다. 물론 서비스와는 연관이 없는 배치 작업이나 어드민 툴에서 사용되는 쿼리들은 레플리카 서버에서 실행되도록 구현해도 무방하다. 이러한 쿼리들은
> 레플리카 서버에 문제가 생겨 쿼리 실행이 제대로 이뤄지지 않더라도 서비스 동작에 영향을 주지 않기 때문이다.  
> (다만 Amazon RDS 의 경우와 같이 클러스터를 구성해서 클러스터 엔드포인트를 가지는 경우에는 애플리케이션에서 레플리카 서버를 이용할 수 있어도 문제가 되지 않는다.
> 여기서 말하는 것은 이러한 클러스터 앤드포인트를 통한 레플리카 접근이 아닌 레플리카 호스트 주소를 사용한 직접 접근을 하면 위험하다는 것을 말한다.)
> 
> **멀티 레플리카 복제 구성**  
> 새로 오픈될 서비스에서 사용할 MySQL 서버를 설정할 때는 보통 싱글 레플리카 복제 구성으로 MySQL 서버를 구축한다. 서비스 오픈 초기에는 DB 서버로 유입되는 쿼리
> 요청이 매우 적기 때문이다. 이후 서비스의 트래픽이 크게 증가하면 소스 서버 한 대에서만 쿼리 요청을 처리하기에는 벅찰 수 있는데, 이렇게 증가된 쿼리 요청은
> 대부분의 경우 쓰기보다는 읽기 요청이 더 많으므로 사용자는 멀티 레플리카 형태로 복제 구성을 전환해 읽기 요청 처리를 분산시킬 수 있다.  
> 
> 배치나 통계, 분석 등의 여러 작업이 하나의 MySQL 서버 내에 있는 데이터에 대해 수행돼야 하는 경우에도 멀티 레플리카 형태로 복제를 구축해 용도별로 하나씩 
> 레플리카 서버를 나눠 전용으로 사용하게 할 수도 있다. 이처럼 여러 용도로 나누어 사용하는 경우와 더불어 서비스의 읽기 요청 처리를 분산하는 용도로 사용하는 경우
> 모두 레플리카 서버 한 대는 예비용으로 남겨두는 것이 좋다. 레플리카 서버로 서비스 읽기 요청이 들어오는 경우 해당 레플리카 서버는 소스 서버만큼 중요해지며, 그 외 다른
> 용도로 사용되는 레플리카 서버들도 지정된 시간 내에 쿼리 처리가 반드시 수행돼야 하는 등의 요건이 있을 수 있다. 따라서 이러한 레플리카 서버들은 장애가 발생했을 때
> 최대한 빠르게 복구돼야 하며, 그렇지 못한 경우에는 다른 레플리카 서버가 문제가 발생한 레플리카 서버로 유입되는 쿼리 요청을 전부 넘겨받아야 한다. 쿼리 요청을
> 넘겨받은 레플리카 서버는 별다른 문제가 없을 수도 있지만, 만약 넘겨진 쿼리 요청으로 인해 부하가 높아져 성능 저하가 발생하는 경우 기존에 유입되던 쿼리 요청 및
> 넘겨진 쿼리 요청들 모두 원할하게 처리되지 못할 수 있다. 따라서 이 같은 상황을 대비해 대체 서버 및 백업 수행 용도 외에는 최소한의 용도로만 사용되는
> 예비용 서버 한 대를 남겨놓는 것이 좋으며, 이렇게 예비용으로 남겨진 서버는 소스 서버의 대체 서버 겸 다른 레플리카 서버의 대체 서버로도 사용할 수 있다.  
> 
> **듀얼 소스 복제 구성**  
> 듀얼 소스 구성은 두 MySQL 서버 모두 쓰기가 가능하다는 것이 제일 큰 특징이며, 각 서버에서 변경한 데이터는 복제를 통해 다시 각 서버에 적용되므로 양쪽에서
> 쓰기가 발생하지만 두 서버는 서로 동일한 데이터를 갖게 된다. 듀얼 소스 구성에서는 목적에 따라 두 MySQL 서버를 ACTIVE-PASSIVE 또는 ACTIVE-ACTIVE 
> 형태로 사용할 수 있다.  
> 
> 듀얼 소스 구성은 트랜잭션 충돌로 인해 롤백이나 복제 멈춤 현상 등 역효과가 많은 편이다. 그래서 실제로 멀티 소스 복제 구성은 많이 사용되지는 않는 편이다.  
> 만약 쓰기 성능의 확장이 필요하다면 멀티 소스 복제 구성보다는 데이터베이스 서버를 샤딩(Sharding)하는 방법을 권장한다.  

---

## InnoDB 클러스터
### 개요
> MySQL 서버 자체적으로 페일오버(Failover)를 처리하는 기능을 제공하지 않으므로 사용자는 장애가 발생했을 때 레플리카 서버가 새로운 소스 서버가 될 수 있도록 
> 일련의 작업들을 수행해야 한다.
> MySQL 5.7.17 버전에서 빌트인 형태의 HA 솔루션인 InnoDB 클러스터가 도입되면서 사용자는 좀 더 쉽고 편리하게 고가용성을 실현할 수 있게 됐다.  
> 
> **InnoDB 클러스터 아키텍처**  
> * 그룹 복제: 클러스터 그룹을 의미한다.
> * MySQL 라우터: 그룹 복제로 쿼리를 로드밸런싱한다.  
> 
> 그룹 복제에서는 InnoDB 스토리지 엔진만 사용될 수 있으며, 구성할 때 고가용성을 위해 MySQL 서버를 최소 3대 이상으로 구성해야 한다. 
> 이는 3대로 구성했을 때 부터 MySQL 서버 한 대에 장애가 발생하더라도 복제 그룹이 정상적으로 동작하기 때문이다.  

### 그룹 복제(Group Replication)
> 그룹 복제에서는 각 서버들을 소스 혹은 레플리카 서버로 표현하지 않으며, "프라이머리"와 "세컨더리"라는 용어를 사용한다. 쓰기를 처리하는 서버를 프라이머리,
> 읽기 전용으로 동작하는 서버를 세컨더리라고 하며 그룹 복제에 참여하는 MySQL 서버들을 "그룹 멤버"라고 지칭한다.  
> 다음은 그룹 복제에서 제공하는 대표적인 기능이다. 
> * 그룹 멤버 관리
> * 그룹 단위의 정렬된 트랜잭션 적용 및 트랜잭션 충돌 감지
> * 자동 페일오버
> * 자동 분산 복구
> 
> 현재 그룹 복제에서 어떤 서버가 프라이머리인지는 다음과 같이 확인할 수 있다.  
> ```sql
> SELECT MEMBER_HOST, MEMBER_ROLE 
> FROM performance_schema.replication_group_members;
> ```

### 그륩 맴버 관리
> 그룹 멤버 상태 확인 쿼리
> ```sql
> SELECT * FROM performance_schema.replication_group_members \G
> ```

### 그룹 복제 요구사항
> 그룹 복제를 사용하려는 MySQL 서버에서는 다음 요구사항들을 충족해야 한다.
> * InnoDB 스토리지 엔진 사용
> * 프라이머리 키 사용: 그룹 복제될 모든 테이블들은 프라이머리 키를 가지고 있어야한다.
> * 원활한 네트워크 통신 환경
> * 바이너리 로그 활성화 
> * ROW 형태의 바이너리 로그 포맷 사용
> * lower_case_table_names 설정: 모든 그룹 멤버에서 동일한 값으로 설정돼야 한다. 
> * 이외는 도서에서 확인한다.

---

## Performance 스키마 & Sys 스키마
### 개요
> 어떤 경우든지 사용 중인 데이터베이스의 성능을 기존보다 향상시켜야 하는 상황에 놓이면 가장 먼저 해야 할 일은 현재 데이터베이스가 어떤 상태인지 분석하고 성능을
> 향상시킬 수 있는 튜닝 요소를 찾는 것이다.   
> MySQL 에서는 사용자가 데이터베이스 상태 분석을 좀 더 수월하게 할 수 있게 MySQL 내부에서 발생하는 이벤트에 대한 상세한 정보를 수집해서 한 곳에 모아
> 사용자들이 손쉽게 접근해서 확인할 수 있게 하는 기능을 제공한다. 이러한 기능이 바로 Performance 스키마와 Sys 스키마이며, 사용자는 이를 통해
> 일반 테이블에 저장된 데이터를 조회하는 것처럼 SQL 문을 사용해 수집된 정보를 조회할 수 있다.

### Performance 스키마란?
> Performance 스키마는 MySQL 서버가 기본적으로 제공하는 시스템 데이터베이스 중 하나로, MySQL 서버의 데이터베이스 목록에서 `performance_schema` 라는 이름의
> 데이터베이스로 확인할 수 있다.  
> 
> Performance 스키마에는 MySQL 서버 내부 동작 및 쿼리 처리와 관련된 세부 정보들이 저장되는 테이블들이 존재하며, 사용자는 이러한 테이블들을 통해 MySQL 서버의
> 성능을 분석하고 내부 처리 과정 등을 모니터링할 수 있다.  
> 
> Performance 스키마는 별도로 구현된 전용 스토리지 엔진인 PERFORMANCE_SCHEMA 스토리지 엔진에 의해 수행된다.  
> PERFORMANCE_SCHEMA 스토리지 엔진은 MySQL 서버가 동작 중인 상태에서 실시간으로 정보를 수집하며, 수집한 정보를 디스크가 아닌 메모리에 저장한다. 그러므로
> Performance 스키마가 활성화돼 있는 MySQL 서버에서는 Performance 스키마가 비활성화된 상태로 동작 중인 MySQL 서버보다 CPU 와 메모리 등의 서버 리소스를 
> 좀 더 소모하게 된다.  
> 앞서 언급한 것처럼 실제 데이터는 모두 메모리 상에서 관리되므로 MySQL 서버가 재시작하면 해당 데이터는 모두 초기화되어 복구할 수 없음에 유의해야 한다.  
> Performance 스키마에서 발생하는 데이터 변경은 MySQL 서버의 바이너리 로그에 기록되지 않기 때문에 복제로 연결된 레플리카 서버로 복제되지 않는다.  

### Performance 스키마 구성
> **Setup 테이블**    
> Performance 스키마의 데이터 수집 및 저장과 관련된 설정 정보가 저장돼 있으며, 사용자는 이 테이블을 통해 Performance 스키마의 설정을 동적으로 변경할 수 있다.  
> 
> **Lock 테이블**  
> MySQL 에서 발생한 잠금과 관련된 정보를 제공한다.  
> * data_locks: 현재 잠금이 점유됐거나 잠금이 요청된 상태에 있는 데이터 관련 락(레코드 락 및 갭 락)에 대한 정보를 보여준다.
> * data_lock_waits: 이미 점유된 데이터 락과 이로 인해 잠금 요청이 차단된 데이터 락 간의 관계 정보를 보여준다. 
> * metadata_locks
> * table_handles: 현재 잠금이 점유된 테이블 락들에 대한 정보를 보여준다.  

### Performance 스키마 설정
> Performance 스키마는 MySQL 5.6.6 버전부터 MySQL 구동 시 기본으로 기능이 활성화되도록 설정이 변경됐다.  
> 명시적으로 Performance 스키마 기능의 활성화 여부를 제어하고 싶은 경우에는 MySQL 설정 파일에 다음과 같이 옵션을 추가하면 된다.  
> ```text
> ## Performance 스키마 기능 비활성화
> [mysqld]
> performnace_schema=OFF
> 
> ## Performance 스키마 기능 활성화
> [mysqld]
> performnace_schema=ON
> ```
> 
> Performance 스키마 활성 상태 확인 쿼리
> ```sql
> SHOW GLOBAL VARIABLES LIKE 'performnace_schema';
> ```
> 
> 사용자는 Performance 스키마에 대해 크게 두 가지 부분으로 나누어 설정할 수 있다.  
> * 메모리 사용량 설정
> * 데이터 수집 및 저장 설정
> 
> Performance 스키마에서는 수집한 데이터를 모두 메모리에 저장하므로 Performance 스키마가 MySQL 서버 동작에 영향을 줄 만큼 과도하게 메모리를 사용하지 않게 
> 제한하는 것이 좋다. 또한 Performance 스키마를 수집 가능한 모든 이벤트에 대해 데이터를 수집하도록 설정하는 것보다는 사용자가 필요로 하는 이벤트들에 대해서만
> 수집하도록 설정하는 편이 MySQL 내부적인 오버헤드를 줄이고 MySQL 서버의 성능 저하를 유발하지 않는다.  

### 메모리 사용량 설정
> 메모리 사용량 제한 확인 쿼리
> ```sql
> SELECT VARIABLE_NAME, VARIABLE_VALUE
> FROM performance_schema.global_variables
> WHERE VARIABLE_NAME LIKE '%performance_schema%'
> AND VARIABLE_NAME NOT IN ('performance_schema', 'performance_schema_show_processlist');
> ```
> 쿼리 결과의 VARIABLE_VALUE 의 값 중 -1은 정해진 제한 없이 필요에 따라 자동으로 크기가 증가할 수 있음을 의미한다.  

### Sys 스키마 개요
> Sys 스키마는 Performance 스키마의 불편한 사용성을 보완하고자 도입됐으며, Performance 스키마 및 Information 스키마에 저장돼 있는 데이터를 사용자들이
> 더욱 쉽게 이해할 수 있는 형태로 출력하는 뷰와 스토어드 프로시저, 함수들을 제공한다.  
> 
> 사용자가 root 와 같이 MySQL 에 대해 전체 권한을 가진 DB 계정으로 접속한 경우 Sys 스키마에서 제공하는 모든 데이터베이스 객체를 자유롭게 사용할 수 있으나,
> 제한적인 권한을 가진 DB 계정에서는 Sys 스키마를 사용하기 위해 추가 권한이 필요할 수 있다. 그러한 DB 계정에서 Sys 스키마를 사용하고자 한다면 다음의 권한들을 
> 해당 계정에 추가한 후 Sys 스키마를 사용해야 한다.  
> ```sql
> GRANT PROCESS ON *.* TO `user`@`host`;
> GRANT SYSTEM_VARIABLES_ADMIN ON *.* TO `user`@`host`;
> GRANT ALL PREVILEGES ON `sys`.* TO `user`@`host`;
> GRANT SELECT, INSERT, UPDATE, DELETE, DROP ON `performance_schema`.* TO `user`@`host`; 
> ```

### Sys 스키마 구성
> **뷰**  
> * host_summary.x$host_summary: 호스트별로 쿼리 처리 및 파일 I/O 와 관련된 정보, 그리고 커넥션 수 및 메모리 사용량 등의 종합적인 정보가 출력된다.
> * x$host_summary_by_file_io: 호스트별로 발생한 파일 I/O 이벤트 총수와 대기 시간 총합에 대한 정보가 출력된다.  
> * x$innodb_buffer_stats_by_schema: 데이터베이스별로 사용 중인 메모리 및 데이터 양, 페시지 수 등에 대한 정보가 출력된다. 
> 이 뷰는 MySQL 서버 성능에 영향을 주므로 서비스에서 사용 중인 MySQL 서버에서 해당 뷰를 조회할 때 주의해야 한다. 
> * x$innodb_buffer_stats_by_table: 테이블별로 사용 중인 메모리 및 데이터 양, 페이지 수 등에 대한 정보가 출력된다. 
> 마찬가지로 MySQL 서버 성능에 영향을 주므로 서비스에서 사용 중인 MySQL 서버에서 해당 뷰를 조회할 때 주의해야 한다.  
> * x$innodb_lock_waits: 현재 실행 중인 트랜잭션에서 획득하기 위해 기다리고 있는 InnoDB 잠금에 대한 정보가 출력된다.   
> * x$schema_index_statistics: 테이블에 존재하는 각 인덱스의 통계 정보가 출력된다.  
> * schema_object_overview: 데이터베이스별로 해당 데이터베이스에 존재하는 객체들의 유형(테이블, 프로시저, 트리거 등)별 객체 수 정보가 출력된다.  
> * x$statement_analysis: MySQL 서버에서 실행된 전체 쿼리들에 대해 데이터베이스 및 쿼리 다이제스트별로 쿼리 처리와 관련된 통계 정보를 출력한다.  
> * x$statements_with_errors_or_warnings: 쿼리 실행 시 경고 또는 에러를 발생한 쿼리들에 대한 통계 정보를 출력한다.  

### Performance 스키마 및 Sys 스키마 활용 예제
> **호스트 접속 이력 확인**    
> ```sql
> SELECT * FROM performance_schema.hosts;
> ```
> `HOST` 칼럼이 NULL 인 데이터에는 MySQL 내부 스레드 및 연결 시 인증에 실패한 커넥션들이 포함된다. 
> `CURRENT_CONNECTIONS` 칼럼은 현재 연결된 커넥션 수를 의미하며, `TOTAL_CONNECTIONS` 칼럼은 연결됐던 커션의 총수를 의미한다.  
> 
> MySQL 에 원격으로 접속한 호스트들에 대해 호스트별로 현재 연결된 커넥션 수를 확인
> ```sql
> SELECT HOST, CURRENT_CONNECTIONS 
> FROM performance_schema.hosts
> WHERE CURRENT_CONNECTIONS > 0 
> AND HOST NOT IN ('NULL', '127.0.0.1')
> ORDER BY HOST;
> ```
> 
> **미사용 DB 계정 확인**  
> MySQL 서버가 구동된 시점부터 현재까지 사용되지 않은 DB 계정들을 확인하고자 할 때 다음의 쿼리를 사용할 수 있다. 
> 현재 MySQL 에 생성돼 있는 계정들을 대상으로 계정별 접속 이력 유무와 뷰, 또는 트리거, 스토어드 프로시저 같은 스토어드 프로그램들의 생성 유무를 확인해서
> 두 경우 모두에 해당되지 않는 계정들의 목록이 출력된다.
> ```sql
> SELECT DISTINCT m_u.user, m_u.host
> FROM mysql.user m_u
> LEFT JOIN performance_schema.accounts ps_a ON m_u.user = ps_a.user AND ps_a.host = m_u.host
> LEFT JOIN performance_schema.views is_v ON is_v.definer = CONCAT(m_u.user, '@', m_u.host) AND is_v.security_tyep = 'DEFINER'
> LEFT JOIN information_schema.routines is_r ON is_r.definer = CONCAT(m_u.user, '@', m_u.host) AND is_r.security_type = 'DEFINER'
> LEFT JOIN information_schema.events is_e ON is_e.definer = CONCAT(m_u.user, '@', m_u.host)
> LEFT JOIN information_schema.triggers is_t ON is_t.definer = CONCAT(m_u.user, '@', m_u.host)
> WHERE ps_a.user IS NULL
> AND is_v.definer IS NULL 
> AND is_r.definer IS NULL 
> AND is_e.definer IS NULL 
> AND is_t.definer IS NULL 
> ORDER BY m_u.user, m_u.host;
> ```
>
> **MySQL 총 메모리 사용량 확인**  
> ```sql
> SELECT * FROM sys.memory_global_total;
> ```
> 
> **미사용 인덱스 확인**  
> MySQL 서버가 구동된 시점부터 현재까지 사용되지 않은 인덱스 목록을 확인할 수 있다.
> ```sql
> SELECT * FROM sys.schema_unused_indexes;
> ```
> 
> 사용되지 않는 인덱스를 제거할 때는 안전하게 인덱스가 쿼리에 사용되지 않는 INVISIBLE 상태로 먼저 변경해서 일정 기간 동안 문제가 없음을 확인한 후
> 제거하는 것이 좋다.  
> ```sql
> -- 인덱스를 INVISIBLE 상태로 변경
> ALTER TABLE users ALTER INDEX ix_name INVISIBLE;
> 
> -- INVISIBLE 상태 확인
> SELECT TABLE_NAME, INDEX_NAME, IS_VISIBLE
> FROM information_schema.statistics
> WHERE TABLE_SCHEMA='DB1' 
> AND TABLE_NAME='users' 
> AND INDEX_NAME='idx_name';
> ```
> 
> **중복된 인덱스 확인**  
> ```sql
> SELECT * FROM sys.scheam_redundant_indexes LIMIT 1 \G
> ```
> 
> **변경이 없는 테이블 목록 확인**  
> MySQL 서버가 구동된 시점부터 현재까지 쓰기가 발생하지 않은 테이블 목록을 확인하고자 할 때 쿼리
> ```sql
> SELECT t.table_schema, t.table_name, t.table_rows, tio.count_read, tio.count_write
> FROM information_schema.tables AS t
> JOIN performance_schema.table_io_waits_summary_by_table AS tio
> ON tio.object_schema = t.table_schema AND tio.object_name = t.table_name
> WHERE t.table_schema NOT IN ('mysql', 'performance_schema', 'sys')
> AND tio.count_write = 0
> ORDER BY t.table_schema, t.table_name;
> ```
> MySQL 서버가 충분히 오랫동안 구동된 상태라면 지금까지 쓰기가 발생하지 않았으며 또한 저장된 데이터가 없는 테이블은 현재 사용되지 않고 있는 테이블일 가능성이 매우 높다.
> 그러므로 사용자는 위 쿼리를 통해 얻은 테이블 목록을 바탕으로 추가로 확인 작업을 거쳐 MySQL 서버에서 사용하지 않는 테이블들을 정리할 수 있다.  
> 
> **I/O 요청이 많은 테이블 목록 확인**  
> ```sql
> SELECT * FROM sys.io_global_by_file_by_bytes 
> WHERE file LIKE '%ibd'; 
> ```
> 
> **테이블별 작업량 통계 확인**  
> ```sql
> SELECT table_schema, table_name, rows_fetched, rows_inserted, rows_updated, rows_deleted, io_read, io_write
> FROM sys.schema_table_statistics
> WHERE table_schema NOT IN ('mysql', 'performance_schema', 'sys') \G
> ```
> 데이터 변경은 거의 없으나 데이터 조회는 빈번한 것으로 보이는 테이블이 존재하는 경우 해당 테이블에서 사용되는 조회 쿼리를 확인해서 캐싱을 적용해
> MySQL 서버로 불필요하게 조회 쿼리가 자주 실행되지 않게 개선할 수 있다.  
> 
> **자주 실행되는 쿼리 목록 확인**  
> ```sql
> SELECT db, exec_count, query 
> FROM sys.statement_analysis
> ORDER BY exec_count DESC;
> ```
> 자주 실행되는 쿼리 목록을 통해 주로 어떤 쿼리들이 사용되고 있는지 파악할 수 있으며, 예상한 것과 다르게 너무 과도하게 실행되고 있는 쿼리가 
> 존재하는지도 살펴볼 수 있다.
> 
> **실행 시간이 긴 쿼리 목록 확인**  
> ```sql
> SELECT query, exec_count, sys.format_time(avg_latency) as "formatted_avg_latency", 
> rows_sent_avg, rows_examined_avg, last_seen
> FROM sys.x$statement_analysis
> ORDER BY avg_latency DESC;
> ```
> 
> **정렬 작업을 수행한 쿼리 목록 확인**   
> 많은 양의 데이터를 읽은 후 내부적으로 정렬 작업을 수행하는 쿼리들의 경우 서버의 CPU 자원을 많이 소모한다. 이러한 쿼리들이 갑자기 대량으로 MySQL 서버에
> 유입되면 서버에 부하를 주어 문제가 발생할 수 있다. 따라서 정렬 작업을 수행하는 쿼리들을 확인해서 정렬이 발생하지 않게 쿼리를 수정하거나 테이블 인덱스를
> 조정해 새로운 인덱스를 추가하는 방안을 고려해보는 것이 좋다.
> ```sql
> SELECT * FROM sys.statements_with_sorting ORDER BY last_seen DESC LIMIT 1 \G
> ```
> 
> **임시 테이블을 생성하는 쿼리 목록 확인**  
> ```sql
> SELECT * FROM sys.statements_with_temp_tables LIMIT 10 \G
> ```
> 
> **데이터 락 대기 확인**  
> ```sql
> SELECT * FROM sys.innodb_lock_waits \G
> ```
