# alibi

<p align="center">
  <img src="docs/assets/alibi-hero.jpg" alt="alibi — 증거판 앞에 선 형사" width="820">
</p>

<sub>🇬🇧 English → <a href="./README.md">README.md</a></sub>

> **git blame은 *누가*를 알려준다. alibi는 *왜*를 알려준다.**
>
> 🌐 **[소개 페이지 (KO)](https://dhha22.github.io/alibi/ko.html)** · **[Landing page (EN)](https://dhha22.github.io/alibi/)**

`alibi`는 Claude Code 스킬입니다. 20년 경력에 검거율은 0인 강력계 형사죠. 수상한 한 줄을
가리키면, blame이 애먼 사람에게 뒤집어씌우는 prettier 커밋들을 걷어내고, 그 줄의 *의미를
실제로 만든* 커밋까지 파고듭니다. 이어 PR·이슈·리뷰 스레드를 추적해 코드의 알리바이를
판결합니다.

- ⚖️ **JUSTIFIED (정당함)** — 이유가 여전히 유효하다. 건드리지 마라.
- ⌛ **EXPIRED (만료됨)** — 이유가 사라졌다. 제거해도 안전하다. 주의사항 첨부.
- 🕳️ **COLD CASE (미제)** — 이유를 못 찾았다. 최대한 신중히. 마지막 목격자 명단을 남긴다.

*유죄인 코드는 없다. 그저 과거가 있을 뿐.*

## 필요 조건

- [Claude Code](https://claude.com/claude-code)
- 히스토리가 있는 **git** 저장소 (alibi는 `git blame`·`git log`·`git show`를 읽습니다)
- 인증된 [`gh` CLI](https://cli.github.com/) — *권장이며, 필수는 아닙니다.*
  PR·리뷰 스레드 증거를 열어주며, 없으면 git 히스토리만으로 동작합니다.

## 설치

Claude Code 플러그인으로 설치 (프롬프트 두 번):

```
/plugin marketplace add dhha22/alibi
/plugin install alibi@alibi
```

또는 스킬 폴더를 직접 복사해서 설치할 수도 있습니다:

```bash
git clone https://github.com/dhha22/alibi
cp -r alibi/skills/alibi ~/.claude/skills/alibi
```

### `gh` CLI 연결 (권장)

alibi는 각 줄의 사연을 PR·이슈·리뷰 스레드까지 추적합니다 — git 객체 어디에도 남지 않는
그 *이유*들 말이죠. 여기에 닿으려면 [GitHub CLI](https://cli.github.com/)가 설치되고
인증돼 있어야 합니다. 없어도 alibi는 git 히스토리만으로 동작하며, 그 사실을 판결문에
명시합니다.

```bash
# gh CLI 설치 (macOS · Homebrew)
brew install gh

# GitHub 계정 인증 — 브라우저에서 한 번
gh auth login

# 연결 확인
gh auth status
```

## 이렇게 물어보세요

- "이 타임아웃 왜 30초야? `src/auth/session.ts:47`"
- "이 `setTimeout(resolve, 0)` 지워도 돼? 쓸모없어 보이는데."
- "누가 왜 이렇게 짰어 — prettier 커밋이라고 하지 말고"
- "커밋 4f2a91c 전체 사연 좀 — 이 변경이 왜 들어왔어?"

## 동작 방식

`git blame`은 그 줄을 *마지막으로 건드린* 사람을 지목합니다 — 그런데 그건 십중팔구
prettier 실행, lint 정리, 대량 rename이지, 줄에 의미를 부여한 사람이 아닙니다. alibi는
시니어 엔지니어가 손으로 할 발굴 작업을, 매번 똑같은 방식으로 실행합니다:

1. **제대로 무장한 blame** — 저장소에 `.git-blame-ignore-revs`가 있으면 반영해서
   `git blame -w`. 거짓말하는 맨몸 `git blame`은 절대 쓰지 않습니다.
2. **노이즈 판정 루프** — blame이 지목한 커밋이 실제로 줄을 저술했는지, 아니면 그냥
   재정렬만 했는지 판정합니다 (`prettier`/`lint`/`rename` 같은 메시지 패턴, 공백만 바뀐
   `-w` diff, 대량 변경 커밋). 노이즈면 제외하고 다시 blame. 이동·추출 커밋은
   `git log -S`로 파일 경계를 넘어 추적합니다. 줄을 진짜로 저술한 커밋 — **기원 커밋**에
   닿을 때까지 반복합니다.
3. **git 밖의 사연 추적** — 기원 커밋에서 `#123` 참조를 따라가고, (`gh` CLI가 연결돼
   있으면) 그 커밋을 담은 PR과 리뷰 스레드까지 봅니다. *이유*가 사는 곳이 바로 여기입니다 —
   반박, 시도됐다 기각된 대안, "나중에 지우자"던 약속. git 객체 어디에도 없는 것들이죠.
4. **판결** — 그 이유가 오늘도 유효한지 확인하고 판결을 내립니다:
   **JUSTIFIED / EXPIRED / COLD CASE**.

`gh`가 없거나 GitHub이 아닌 remote에서도 alibi는 멈추지 않습니다 — git 증거만으로 사건을
마무리하고 그 사실을 판결문에 밝힙니다. 도구가 없다고 죽어버리지 않습니다.

## 무엇을 돌려받나

모든 조사는 구조화된 사건 파일로 끝납니다 — 판결, 그 근거가 된 증거, 그리고 구체적인 다음
한 걸음 (결정은 당신 몫입니다):

```
🗂️  CASE #a1b2c3d — "이 connect 타임아웃은 왜 30초인가?"
────────────────────────────────────────────────────

⚖️ Verdict: JUSTIFIED — 우회 대상인 느린 broker 버그가 아직 열려 있음.

📋 Case summary
   2021-03 PR #812에서 도입. 첫 연결 수락까지 ~25초 걸리는 broker를
   버티기 위함. blame은 처음에 2023년 prettier 커밋을 지목했지만,
   진짜 저자는 #812의 @maria.

🧾 Exhibits
   E-1  commit 4f2a91c "raise connect timeout to 30s" (2021-03-11, @maria)
   E-2  PR #812 — broker cold-start이 20초를 넘길 수 있음
   E-3  broker changelog: cold-start 수정 아직 미출시

🗣️  Witness statements
   W-1  @lead (reviewer, 2021-03): "broker 수정 나올 때까지 유지하자"

∴  Deduction
   E-3 (수정 미출시)   ∴ 원래의 위험이 여전히 존재
   ∴  Verdict: JUSTIFIED

⚖️  Disposition recommendation (결정은 당신 몫)
   유지하라. broker cold-start 수정이 나오면 재검토.

🔗 Related
   SHA: 4f2a91c   PR: #812
```

## 조사 모드

| 모드 | 답하는 질문 | 출력 |
|---|---|---|
| **why-not-who** | "이 *줄*은 왜 있나 — 지워도 되나?" | 판결이 붙은 사건 파일 |
| **commit-to-story** | "이 *커밋/PR*은 왜 들어왔나 — 무슨 논쟁이 있었나?" | 도시에: 문제 → 논쟁 → 결정 → 여파 |
| **first-broken** | "*예전엔 됐는데* — 어느 커밋이 깨뜨렸나?" | 검증된 프로브 bisect → 범인 심문, 의도에 대한 판결 |
| **incident-trace** | "X에 무슨 *일*이 있었나 — 되돌려졌나, 어느 릴리스에 있었나?" | 사건 타임라인 + 릴리스별 노출 |
| **design-rationale** | "왜 이렇게 *설계*됐나 — 다른 방식은 시도했나?" | 선례 기록: 시대별 + 기각된 대안, 오늘에 대한 판결 |
| **repo-tour** | "이 저장소의 *역사*로 온보딩해줘 — 시체는 어디 묻혀 있나?" | 5장면 관할구역 투어 + 첫 수 배치 |

facebook/react 대상 실제 기록: [why-not-who](examples/transcripts/why-not-who-react.md) ·
[commit-to-story](examples/transcripts/commit-to-story-react.md)

---

상태: v4 — 6개 조사 모드 전부 출시됨.
