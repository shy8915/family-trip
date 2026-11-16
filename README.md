# 우리 가족 여행수첩

여행을 건별로 기록하고, 일자별 일정·지도 동선·이동 시간·날씨 예보·준비물을 한곳에서 보는 가족용 웹앱입니다.
서버 없이 `index.html` 하나로 동작하며, API 키는 저장소가 아니라 각자 기기의 **설정** 화면에 넣습니다.

## 쓰는 API

| 기능 | API | 인증 |
| --- | --- | --- |
| 지도, 장소 검색 | 카카오맵 JavaScript SDK (`services` 라이브러리) | JavaScript 키 + 도메인 등록 |
| 자가용 경로·소요시간·통행료 | 카카오모빌리티 자동차 길찾기 `GET https://apis-navi.kakaomobility.com/v1/directions` | REST API 키 |
| 대중교통 경로 | 카카오맵 `GET https://dapi.kakao.com/v2/routing/publictraffic` | REST API 키 |
| 도보 경로 | 카카오맵 `GET https://dapi.kakao.com/v2/routing/walk` | REST API 키 |
| 날씨 예보 | 기상청 단기예보 조회서비스 `getVilageFcst` (공공데이터포털) | 서비스 키 |
| 가족 실시간 공유 | Firebase Firestore + 익명 로그인 | Firebase 웹 앱 구성 |

출처: [카카오맵 이해하기](https://developers.kakao.com/docs/ko/kakaomap/common), [카카오맵 REST API](https://developers.kakao.com/docs/ko/kakaomap/rest-api), [카카오내비 REST API](https://developers.kakao.com/docs/latest/en/kakaonavi/rest-api), [기상청_단기예보 조회서비스](https://www.data.go.kr/data/15084084/openapi.do)

## 1. 카카오 키 발급

1. [카카오디벨로퍼스](https://developers.kakao.com/)에서 앱을 만듭니다.
2. 앱 관리 페이지의 [카카오맵] > [사용 설정]에서 상태를 ON으로 바꿉니다. 개발자 계정에서 처음 활성화한 앱에만 무료 쿼터가 제공됩니다.
3. JavaScript 키의 JavaScript SDK 도메인에 `https://shy8915.github.io` 를 등록합니다.
4. JavaScript 키와 REST API 키를 복사해 둡니다.

## 2. 기상청 서비스 키 발급

1. [공공데이터포털](https://www.data.go.kr/)에 로그인합니다.
2. [기상청_단기예보 조회서비스](https://www.data.go.kr/data/15084084/openapi.do)에서 활용신청을 합니다.
3. 마이페이지에서 인증키를 복사합니다. 인코딩 키와 디코딩 키 어느 쪽이든 앱에 넣을 수 있습니다.

## 3. 가족 공유(Firebase) 설정

1. [Firebase 콘솔](https://console.firebase.google.com/)에서 프로젝트를 만들고 웹 앱을 추가해 `firebaseConfig`를 복사합니다.
2. Authentication > 로그인 방법에서 **익명**을 사용 설정합니다.
3. Authentication > 설정 > 승인된 도메인에 `shy8915.github.io` 를 추가합니다.
4. Firestore Database를 만들고 규칙을 아래로 바꿉니다.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /families/{family}/trips/{trip} {
      allow read, write: if request.auth != null;
    }
  }
}
```

가족 구분은 앱이 만드는 긴 무작위 **가족 코드**로 합니다. 코드를 아는 기기만 같은 여행을 봅니다.

## 4. 앱에 넣기

1. 앱 오른쪽 위 **설정**에 키 세 개와 `firebaseConfig`를 붙여 넣고 **연결 테스트**를 누릅니다.
2. **저장** 후 **가족 초대 링크 복사**로 만든 링크를 가족에게 보냅니다. 가족은 링크를 한 번 열면 같은 설정이 저장됩니다.
3. 폰 브라우저 메뉴의 "홈 화면에 추가"로 앱처럼 쓸 수 있습니다.

## 알아둘 점

- 초대 링크와 각 기기 브라우저에는 API 키가 들어 있습니다. 가족 외에는 링크를 공유하지 마세요.
- 경로 API와 기상청 API를 브라우저에서 직접 호출하는 구조입니다. 키 발급 후 **연결 테스트**에서 실패가 나오면 해당 기능은 카카오맵 길찾기 링크와 기상청 날씨누리 링크로 대체됩니다.
- 단기예보 범위 밖의 날짜는 예보가 표시되지 않습니다. 여행일이 가까워지면 자동으로 나타납니다.
- 경로 조회 결과는 저장하지 않고 화면을 열 때마다 새로 조회합니다.
