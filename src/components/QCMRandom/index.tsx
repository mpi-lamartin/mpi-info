import React, { useEffect, useMemo, useState } from "react";
import styles from "./styles.module.css";
import katex from "katex";
import useBaseUrl from "@docusaurus/useBaseUrl";
import { Prism as PrismRenderer } from "prism-react-renderer";

interface Question {
  question: string;
  answers: string[];
  correct: number | number[]; // single index or array of indices (0-based)
  explanation?: string;
}

interface QCMRandomProps {
  questions: Question[];
  title?: string;
  repoOwner?: string;
  repoName?: string;
}

interface PersistedQCMState {
  signature: string;
  order: number[];
  current: number;
  selected: number[];
  validated: boolean;
  correctCount: number;
  answeredCount: number;
  finished: boolean;
}

const STORAGE_VERSION = "v2";

function isMultiple(correct: number | number[]): correct is number[] {
  return Array.isArray(correct);
}

function getCorrectSet(correct: number | number[]): Set<number> {
  return new Set(isMultiple(correct) ? correct : [correct]);
}

function escapeHtml(input: string): string {
  return input
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

function renderMath(text: string, baseUrl: string): string {
  const codeBlocks: string[] = [];
  let result = text.replace(
    /```([a-zA-Z0-9_-]+)?\n([\s\S]*?)```/g,
    (_, lang, code) => {
      const language = lang || "text";
      const grammar =
        PrismRenderer.languages[language] || PrismRenderer.languages.markup;
      let highlighted = code;
      try {
        highlighted = PrismRenderer.highlight(code, grammar, language);
      } catch {
        highlighted = escapeHtml(code);
      }
      const block = `<pre class="prism-code language-${language}" style="margin:6px 0;"><code class="language-${language}">${highlighted}</code></pre>`;
      const marker = `@@CODEBLOCK_${codeBlocks.length}@@`;
      codeBlocks.push(block);
      return marker;
    },
  );
  result = result.replace(/\$\$([^$]+)\$\$/g, (_, tex) => {
    try {
      return katex.renderToString(tex, {
        throwOnError: false,
        displayMode: true,
      });
    } catch {
      return `$$${tex}$$`;
    }
  });
  result = result.replace(/\$([^$]+)\$/g, (_, tex) => {
    try {
      return katex.renderToString(tex, {
        throwOnError: false,
        displayMode: false,
      });
    } catch {
      return `$${tex}$`;
    }
  });
  result = result.replace(
    /`([^`]+)`/g,
    (_, code) => `<code>${escapeHtml(code)}</code>`,
  );
  result = result.replace(/\n/g, "<br>");
  result = result.replace(/src='\/([^']+)'/g, (_, p) => `src='${baseUrl}${p}'`);
  result = result.replace(/src="\/([^"]+)"/g, (_, p) => `src="${baseUrl}${p}"`);
  result = result.replace(
    /@@CODEBLOCK_(\d+)@@/g,
    (_, idx) => codeBlocks[Number(idx)],
  );
  return result;
}

function MathText({ text }: { text: string }): JSX.Element {
  const baseUrl = useBaseUrl("/");
  return (
    <span dangerouslySetInnerHTML={{ __html: renderMath(text, baseUrl) }} />
  );
}

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function getQuestionsSignature(questions: Question[]): string {
  const raw = JSON.stringify(
    questions.map((q) => ({
      question: q.question,
      answers: q.answers,
      correct: q.correct,
      explanation: q.explanation || "",
    })),
  );

  let h1 = 0xdeadbeef ^ raw.length;
  let h2 = 0x41c6ce57 ^ raw.length;
  for (let i = 0; i < raw.length; i++) {
    const code = raw.charCodeAt(i);
    h1 = Math.imul(h1 ^ code, 2654435761);
    h2 = Math.imul(h2 ^ code, 1597334677);
  }

  h1 = Math.imul(h1 ^ (h1 >>> 16), 2246822507);
  h1 ^= Math.imul(h2 ^ (h2 >>> 13), 3266489909);
  h2 = Math.imul(h2 ^ (h2 >>> 16), 2246822507);
  h2 ^= Math.imul(h1 ^ (h1 >>> 13), 3266489909);

  return `${questions.length}:${(h2 >>> 0).toString(16)}:${(h1 >>> 0).toString(16)}`;
}

function isValidOrder(order: number[], size: number): boolean {
  if (order.length !== size) return false;
  const seen = new Set<number>();
  for (const value of order) {
    if (!Number.isInteger(value) || value < 0 || value >= size) return false;
    if (seen.has(value)) return false;
    seen.add(value);
  }
  return true;
}

export default function QCMRandom({
  questions,
  title = "QCM Algorithmes",
  repoOwner = "mpi-lamartin",
  repoName = "mpi-info",
}: QCMRandomProps): JSX.Element {
  const [order, setOrder] = useState<number[]>(() =>
    shuffle(questions.map((_, i) => i)),
  );
  const [current, setCurrent] = useState(0);
  const [selectedSet, setSelectedSet] = useState<Set<number>>(new Set());
  const [validated, setValidated] = useState(false);
  const [correctCount, setCorrectCount] = useState(0);
  const [answeredCount, setAnsweredCount] = useState(0);
  const [finished, setFinished] = useState(false);
  const [hydrated, setHydrated] = useState(false);

  const questionsSignature = useMemo(
    () => getQuestionsSignature(questions),
    [questions],
  );

  const storageKey = useMemo(() => {
    if (typeof window === "undefined") return null;
    return `qcm-random:${STORAGE_VERSION}:${window.location.pathname}:${title}`;
  }, [title]);

  const q = questions[order[current]];
  const correctSet = getCorrectSet(q.correct);
  const multi = isMultiple(q.correct);
  const singleChoice = !multi;

  const isAnswerCorrect = (sel: Set<number>): boolean => {
    if (sel.size !== correctSet.size) return false;
    let ok = true;
    correctSet.forEach((idx) => {
      if (!sel.has(idx)) ok = false;
    });
    return ok;
  };

  const doValidate = (sel: Set<number>) => {
    setValidated(true);
    setAnsweredCount((c) => c + 1);
    if (isAnswerCorrect(sel)) setCorrectCount((c) => c + 1);
  };

  const handleSelect = (idx: number) => {
    if (validated) return;
    if (multi) {
      // Checkbox toggle
      const next = new Set(selectedSet);
      if (next.has(idx)) next.delete(idx);
      else next.add(idx);
      setSelectedSet(next);
    } else {
      const next = new Set([idx]);
      setSelectedSet(next);
      doValidate(next);
    }
  };

  const handleValidate = () => {
    doValidate(selectedSet);
  };

  const handleNext = () => {
    if (current + 1 >= order.length) {
      setFinished(true);
      return;
    }
    setCurrent((c) => c + 1);
    setSelectedSet(new Set());
    setValidated(false);
  };

  const handleRestart = () => {
    setOrder(shuffle(questions.map((_, i) => i)));
    setCurrent(0);
    setSelectedSet(new Set());
    setValidated(false);
    setCorrectCount(0);
    setAnsweredCount(0);
    setFinished(false);
  };

  const handleReportError = () => {
    const sourceQuestionIndex = order[current] + 1;
    const questionPreview =
      q.question.length > 1200 ? `${q.question.slice(0, 1200)}...` : q.question;
    const titleText = `QCM : erreur potentielle question #${sourceQuestionIndex}`;
    const correctIndexes = isMultiple(q.correct) ? q.correct : [q.correct];
    const bodyText = [
      "## Contexte",
      `Index question (fichier source): ${sourceQuestionIndex}`,
      "",
      "## Question concernée",
      "```text",
      questionPreview,
      "```",
      "",
      "## Réponses possibles",
      q.answers.map((a, i) => `  ${i + 1}. ${a}`),
      "",
      "## Réponses correctes sur le site",
      correctIndexes.map((idx) => `  ${idx + 1}. ${q.answers[idx]}`),
      "",
      "## Problème",
      "...",
    ].join("\n");

    const url = `https://github.com/${repoOwner}/${repoName}/issues/new?title=${encodeURIComponent(titleText)}&body=${encodeURIComponent(bodyText)}`;
    window.open(url, "_blank", "noopener,noreferrer");
  };

  const pct =
    answeredCount > 0 ? Math.round((correctCount / answeredCount) * 100) : 0;

  useEffect(() => {
    if (!storageKey) {
      setHydrated(true);
      return;
    }

    try {
      const raw = window.localStorage.getItem(storageKey);
      if (!raw) {
        setHydrated(true);
        return;
      }

      const saved = JSON.parse(raw) as PersistedQCMState;
      if (saved.signature !== questionsSignature) {
        setHydrated(true);
        return;
      }
      if (!isValidOrder(saved.order, questions.length)) {
        setHydrated(true);
        return;
      }

      const safeCurrent = Math.min(
        Math.max(saved.current, 0),
        Math.max(saved.order.length - 1, 0),
      );
      const currentQuestion = questions[saved.order[safeCurrent]];
      const maxAnswerIndex = currentQuestion.answers.length - 1;
      const safeSelected = (saved.selected || []).filter(
        (idx) => Number.isInteger(idx) && idx >= 0 && idx <= maxAnswerIndex,
      );

      setOrder(saved.order);
      setCurrent(safeCurrent);
      setSelectedSet(new Set(safeSelected));
      setValidated(Boolean(saved.validated));
      setCorrectCount(Math.max(0, saved.correctCount || 0));
      setAnsweredCount(Math.max(0, saved.answeredCount || 0));
      setFinished(Boolean(saved.finished));
    } catch {
    } finally {
      setHydrated(true);
    }
  }, [questions, questionsSignature, storageKey]);

  useEffect(() => {
    if (!hydrated || !storageKey) return;

    const payload: PersistedQCMState = {
      signature: questionsSignature,
      order,
      current,
      selected: Array.from(selectedSet),
      validated,
      correctCount,
      answeredCount,
      finished,
    };

    try {
      window.localStorage.setItem(storageKey, JSON.stringify(payload));
    } catch {}
  }, [
    answeredCount,
    correctCount,
    current,
    finished,
    hydrated,
    order,
    questionsSignature,
    selectedSet,
    storageKey,
    validated,
  ]);

  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      const isValidateShortcut =
        (event.ctrlKey || event.metaKey) && event.key === "Enter";
      if (!isValidateShortcut) return;
      if (finished) return;

      if (validated) {
        handleNext();
        event.preventDefault();
        return;
      }

      handleValidate();
      event.preventDefault();
    };

    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [finished, validated, singleChoice, selectedSet]);

  if (finished) {
    return (
      <div className={styles.container}>
        <div className={styles.finalScore}>
          <p>QCM terminé !</p>
          <p className={styles.scoreText}>
            Score final :{" "}
            <strong>
              {correctCount}/{answeredCount}
            </strong>{" "}
            ({pct}%)
          </p>
          <div className={styles.actions}>
            <button className={styles.btnSecondary} onClick={handleRestart}>
              Recommencer
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className={styles.container}>
      <div className={styles.progressBar}>
        <div
          className={styles.progressFill}
          style={{ width: `${((current + 1) / order.length) * 100}%` }}
        />
      </div>
      <div className={styles.progressLabel}>
        Question {current + 1} / {order.length} &nbsp;—&nbsp; Score :{" "}
        {correctCount}/{answeredCount} ({pct}%)
      </div>

      <div className={styles.questionCard}>
        <div className={styles.questionText}>
          <MathText text={q.question} />
          {multi && (
            <span className={styles.multiHint}>
              {" "}
              (plusieurs réponses possibles)
            </span>
          )}
        </div>
        <div className={styles.answers}>
          {q.answers.map((answer, aIdx) => {
            const isSelected = selectedSet.has(aIdx);
            const isCorrectAnswer = correctSet.has(aIdx);
            const userMark =
              validated && isSelected ? (isCorrectAnswer ? "✅" : "❌") : null;
            let cls = styles.answerBtn;

            if (validated) {
              if (isCorrectAnswer) {
                cls = `${styles.answerBtn} ${styles.correct}`;
              } else if (isSelected) {
                cls = `${styles.answerBtn} ${styles.incorrect}`;
              }
            } else if (isSelected) {
              cls = `${styles.answerBtn} ${styles.selected}`;
            }

            return (
              <button
                key={aIdx}
                className={cls}
                onClick={() => handleSelect(aIdx)}
                disabled={validated}
              >
                <span className={styles.answerContent}>
                  <MathText text={answer} />
                </span>
                {userMark && (
                  <span className={styles.answerMark}>{userMark}</span>
                )}
              </button>
            );
          })}
        </div>
        {validated && q.explanation && (
          <div className={styles.explanation}>
            <strong>Explication :</strong> <br />
            <MathText text={q.explanation} />
          </div>
        )}
      </div>

      <div className={styles.actions}>
        {!validated ? (
          !singleChoice && (
            <button className={styles.btnPrimary} onClick={handleValidate}>
              Valider (Ctrl+Enter)
            </button>
          )
        ) : (
          <button className={styles.btnPrimary} onClick={handleNext}>
            {current + 1 >= order.length
              ? "Voir le résultat"
              : "Question suivante (Ctrl+Enter)"}
          </button>
        )}
        <button className={styles.btnSecondary} onClick={handleReportError}>
          Erreur ?
        </button>
        <button className={styles.btnSecondary} onClick={handleRestart}>
          Recommencer
        </button>
      </div>
    </div>
  );
}
