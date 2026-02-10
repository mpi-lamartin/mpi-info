import React, { useState } from "react";
import styles from "./styles.module.css";
import katex from "katex";
import useBaseUrl from "@docusaurus/useBaseUrl";

interface Question {
  question: string;
  answers: string[];
  correct: number;
  explanation?: string;
}

interface QCMRandomProps {
  questions: Question[];
  title?: string;
}

function renderMath(text: string, baseUrl: string): string {
  let result = text.replace(/```([^`]+)```/g, (_, code) => {
    const escaped = code
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
    return `<pre style="background:var(--ifm-color-emphasis-100);padding:8px 12px;border-radius:6px;font-size:0.9em;margin:6px 0;overflow-x:auto;"><code>${escaped}</code></pre>`;
  });
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
  result = result.replace(/`([^`]+)`/g, (_, code) => `<code>${code}</code>`);
  result = result.replace(/\n/g, "<br>");
  result = result.replace(/src='\/([^']+)'/g, (_, p) => `src='${baseUrl}${p}'`);
  result = result.replace(/src="\/([^"]+)"/g, (_, p) => `src="${baseUrl}${p}"`);
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

export default function QCMRandom({
  questions,
  title = "QCM Algorithmes",
}: QCMRandomProps): JSX.Element {
  const [order, setOrder] = useState<number[]>(() =>
    shuffle(questions.map((_, i) => i)),
  );
  const [current, setCurrent] = useState(0);
  const [selected, setSelected] = useState<number | null>(null);
  const [validated, setValidated] = useState(false);
  const [correctCount, setCorrectCount] = useState(0);
  const [answeredCount, setAnsweredCount] = useState(0);
  const [finished, setFinished] = useState(false);

  const q = questions[order[current]];

  const handleSelect = (idx: number) => {
    if (validated) return;
    setSelected(idx);
  };

  const handleValidate = () => {
    if (selected === null) return;
    setValidated(true);
    const isCorrect = selected === q.correct;
    setAnsweredCount((c) => c + 1);
    if (isCorrect) setCorrectCount((c) => c + 1);
  };

  const handleNext = () => {
    if (current + 1 >= order.length) {
      setFinished(true);
      return;
    }
    setCurrent((c) => c + 1);
    setSelected(null);
    setValidated(false);
  };

  const handleRestart = () => {
    setOrder(shuffle(questions.map((_, i) => i)));
    setCurrent(0);
    setSelected(null);
    setValidated(false);
    setCorrectCount(0);
    setAnsweredCount(0);
    setFinished(false);
  };

  const pct =
    answeredCount > 0 ? Math.round((correctCount / answeredCount) * 100) : 0;

  if (finished) {
    return (
      <div className={styles.container}>
        {/* <h3 className={styles.title}>{title}</h3> */}
        <div className={styles.finalScore}>
          <p>QCM terminé !</p>
          <p className={styles.scoreText}>
            Score final :{" "}
            <strong>
              {correctCount}/{answeredCount}
            </strong>{" "}
            ({pct}%)
          </p>
          <button className={styles.btnPrimary} onClick={handleRestart}>
            Recommencer
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className={styles.container}>
      <h3 className={styles.title}>{title}</h3>

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
        <p className={styles.questionText}>
          <MathText text={q.question} />
        </p>
        <div className={styles.answers}>
          {q.answers.map((answer, aIdx) => {
            let cls = styles.answer;
            if (validated) {
              if (aIdx === q.correct)
                cls = `${styles.answer} ${styles.correct}`;
              else if (aIdx === selected)
                cls = `${styles.answer} ${styles.incorrect}`;
            } else if (aIdx === selected) {
              cls = `${styles.answer} ${styles.selected}`;
            }
            return (
              <label
                key={aIdx}
                className={cls}
                onClick={() => handleSelect(aIdx)}
              >
                <input
                  type="radio"
                  name="qcm-random-answer"
                  checked={selected === aIdx}
                  onChange={() => handleSelect(aIdx)}
                  disabled={validated}
                />
                <span className={styles.answerText}>
                  <MathText text={answer} />
                </span>
              </label>
            );
          })}
        </div>
        {validated && q.explanation && (
          <div className={styles.explanation}>
            <strong>Explication :</strong> <MathText text={q.explanation} />
          </div>
        )}
      </div>

      <div className={styles.actions}>
        {!validated ? (
          <button
            className={styles.btnPrimary}
            onClick={handleValidate}
            disabled={selected === null}
          >
            Valider
          </button>
        ) : (
          <button className={styles.btnPrimary} onClick={handleNext}>
            {current + 1 >= order.length
              ? "Voir le résultat"
              : "Question suivante →"}
          </button>
        )}
        <button className={styles.btnSecondary} onClick={handleRestart}>
          Recommencer
        </button>
      </div>
    </div>
  );
}
