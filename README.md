# 정처기 실기 트레이너 (Android)

기출 소진(1단계) → Gemini 응용 문제 생성(2단계) 순서로 출제하는 정보처리기사 실기 학습 앱.
UI·로직은 `app/src/main/assets/www/index.html` 한 파일(오프라인 동작, 라이브러리 인라인)이고, 안드로이드는 WebView 껍데기다.

## 빌드 / 설치
1. Android Studio(Koala 이상)에서 이 폴더를 `Open`
2. Gradle Sync 완료 후 휴대폰 연결(USB 디버깅) → ▶ Run
3. APK만 필요하면: `Build > Build App Bundle(s) / APK(s) > Build APK(s)` → `app/build/outputs/apk/debug/app-debug.apk`
   - CLI: `gradlew.bat assembleDebug` (Windows) / `./gradlew assembleDebug`

빌드 없이 써보려면 `index.html`을 휴대폰 Chrome에서 열어도 동작한다(데이터는 브라우저에 저장).

## 처음 설정
1. 설정 탭 → Gemini API 키 입력 → `연결 테스트`  (키: https://aistudio.google.com/apikey)
2. 문제은행 탭 → 파일 불러오기
   - `.md` : 기출 마크다운을 바로 파싱 (문제 번호·정답·해설 자동 인식)
   - `.json` : 아래 형식
   - `.pdf` : Gemini가 문제/정답을 추출 (19MB 이하)
   - 파일명에 `출제기준`이 들어간 PDF/MD : 출제 범위로 저장 → AI 출제 컨텍스트로 사용

## 기출을 앱에 내장하기 (선택)
`app/src/main/assets/www/questions/bank.json` 을 넣으면 첫 실행 시 자동 로드된다.
`questions/scope.md` 를 넣으면 출제기준 범위로 자동 로드된다.
앱에서 PDF/MD를 한 번 불러온 뒤 `JSON 내보내기` 한 파일을 그대로 bank.json으로 써도 된다.

```json
{ "questions": [
  { "source": "2023년 1회", "no": 1, "type": "코드", "lang": "c",
    "body": "다음 C 프로그램의 출력 결과를 쓰시오.\n```c\n...\n```",
    "answer": "5", "keywords": ["배열 인덱스"], "explanation": "..." }
]}
```
type: 단답형 | 서술형 | 코드 | SQL  (비우면 자동 판별)

## 마크다운 인식 규칙
- 회차: `## 2023년 1회` 처럼 `YYYY년 N회`가 들어간 제목
- 문제 시작(셋 중 3회 이상 등장하는 첫 패턴): `### 문제 3` / `### 3.` · `**문제 3.**` · `3. 본문`
- 정답: `정답:` `**정답**` `[정답]` `<details><summary>정답</summary>` 등
- 해설: `해설:` `풀이:`  · 키워드: `키워드: a, b`

## 사용
- 기본 모드: 답 입력 → 제출 → 채점(단답은 자동, 서술·코드·SQL은 `AI 채점`) → 정답·키워드·해설
- 빠른 확인: 상단 `⚡ 빠른 확인` 토글, 또는 답 칸에 `바로 정답` / `시간 없음` 입력 → 문제와 정답·키워드를 바로 표시
- 틀린 문제는 오답노트에 쌓이고, 2단계 `약점 위주` 출제 시 예시로 쓰인다.

## PC에서 바로가기로 실행 (Windows)
1. `install-shortcut.bat` 더블클릭 → 바탕화면·시작 메뉴에 `정처기 실기 트레이너` 바로가기 생성
2. 바로가기 실행 → 로컬 서버(localhost:8787)가 뜨고 Chrome(없으면 Edge) 앱 창으로 열림
3. 앱 창을 닫으면 서버도 자동 종료
- 학습 기록은 `%LOCALAPPDATA%\JcgTrainer\browser` 프로필에 저장된다. 폰↔PC 기록 이동은 `JSON 내보내기` → 다른 기기에서 불러오기.
- 설치 없이 한 번만 실행: `start.bat`

## 안드로이드 홈 화면 바로가기 (APK 없이, PWA)
`app/src/main/assets/www` 폴더를 HTTPS 주소에 올리면 Chrome에서 `홈 화면에 추가` → 앱처럼 실행된다(주소창 없음, 오프라인 실행).
1. GitHub 새 저장소 생성 → `Add file > Upload files` 로 www 폴더 **안의 내용**(index.html, manifest.webmanifest, sw.js, icons/)을 업로드
2. 저장소 `Settings > Pages` → Branch `main` / `(root)` → Save
3. 1~2분 뒤 `https://<아이디>.github.io/<저장소>/` 를 폰 Chrome에서 열기 → 메뉴(⋮) → `홈 화면에 추가` 또는 `앱 설치`
- API 키·학습 기록은 폰 브라우저 안에만 저장된다(저장소에 올라가지 않음).
- `questions/bank.json` 을 함께 올리면 첫 실행 때 자동 로드된다. 공개 저장소면 기출 파일도 공개되니, 원치 않으면 빼고 앱에서 직접 불러오기.

## 기출 파일을 앱에 넣어두기 (내장 기출)
`app/src/main/assets/www/questions/` 에 .md · .json · .pdf 파일을 넣으면 앱이 알아서 불러온다.
- GitHub Pages: 파일을 넣고 push → 앱을 다시 열면 새 파일·변경된 파일이 자동 반영 (GitHub API로 폴더 목록 확인, 시간당 60회 제한)
- PC 바로가기: 실행할 때 폴더 목록을 자동으로 만든다
- APK: 빌드할 때 `index.json`(파일 목록)이 자동 생성된다
- 파일명에 `출제기준` 또는 `scope`가 들어가면 출제 범위로 저장
- PDF는 Gemini로 추출하므로 API 키가 있어야 자동 반영된다
- 설정 > 내장 기출 불러오기: 폴더 경로 변경, 파일별 상태(새 파일/변경됨/불러옴) 확인 후 골라서 불러오기, 외부 URL 추가
