import React, { useState } from "react";
import styles from "./styles.module.css";
import katex from "katex";
import useBaseUrl from "@docusaurus/useBaseUrl";

interface Question {
  question: string;
  answers: string[];
  correct: number | number[]; // index or indices of correct answers (0-based)
  explanation?: string;
}

interface QCMProps {
  questions: Question[];
  title?: string;
}

function isMultiple(correct: number | number[]): correct is number[] {
  return Array.isArray(correct);
}

function getCorrectSet(correct: number | number[]): Set<number> {
  return new Set(isMultiple(correct) ? correct : [correct]);
}

// Function to render LaTeX and inline code in text
function renderMath(text: string, baseUrl: string): string {
  // Replace fenced code blocks ```...```
  let result = text.replace(/```([^`]+)```/g, (_, code) => {
    const escaped = code
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
    return `<pre style="background:var(--ifm-color-emphasis-100);padding:8px 12px;border-radius:6px;font-size:0.9em;margin:6px 0;overflow-x:auto;"><code>${escaped}</code></pre>`;
  });

  // Replace display math $$...$$ first
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

  // Replace inline math $...$
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

  // Replace inline code `...`
  result = result.replace(/`([^`]+)`/g, (_, code) => {
    return `<code>${code}</code>`;
  });

  // Replace newlines with <br>, but not inside <pre> blocks
  const parts = result.split(/(<pre[\s\S]*?<\/pre>)/g);
  result = parts
    .map((part, i) => {
      if (part.startsWith("<pre")) return part;
      return part.replace(/\n/g, "<br>");
    })
    .join("");

  // Fix image src paths: prepend baseUrl to absolute paths like /img/...
  result = result.replace(/src='\/([^']+)'/g, (_, path) => {
    return `src='${baseUrl}${path}'`;
  });
  result = result.replace(/src="\/([^"]+)"/g, (_, path) => {
    return `src="${baseUrl}${path}"`;
  });

  return result;
}

// Component to render text with math
function MathText({ text }: { text: string }): JSX.Element {
  const baseUrl = useBaseUrl("/");
  const rendered = renderMath(text, baseUrl);
  return <span dangerouslySetInnerHTML={{ __html: rendered }} />;
}

export default function QCM({
  questions,
  title = "QCM",
}: QCMProps): JSX.Element {
  const [selectedAnswers, setSelectedAnswers] = useState<Set<number>[]>(() =>
    questions.map(() => new Set<number>()),
  );
  const [showResults, setShowResults] = useState(false);
  const [score, setScore] = useState(0);

  const handleAnswerSelect = (questionIndex: number, answerIndex: number) => {
    if (showResults) return;
    const newAnswers = selectedAnswers.map((s, i) => new Set(s));
    const multi = isMultiple(questions[questionIndex].correct);
    if (multi) {
      // Checkbox: toggle
      if (newAnswers[questionIndex].has(answerIndex)) {
        newAnswers[questionIndex].delete(answerIndex);
      } else {
        newAnswers[questionIndex].add(answerIndex);
      }
    } else {
      // Radio: single selection
      newAnswers[questionIndex] = new Set([answerIndex]);
    }
    setSelectedAnswers(newAnswers);
  };

  const isQuestionCorrect = (q: Question, selected: Set<number>): boolean => {
    const correctSet = getCorrectSet(q.correct);
    if (selected.size !== correctSet.size) return false;
    let allMatch = true;
    correctSet.forEach((idx) => {
      if (!selected.has(idx)) allMatch = false;
    });
    return allMatch;
  };

  const handleSubmit = () => {
    let newScore = 0;
    questions.forEach((q, i) => {
      if (isQuestionCorrect(q, selectedAnswers[i])) {
        newScore++;
      }
    });
    setScore(newScore);
    setShowResults(true);
  };

  const handleReset = () => {
    setSelectedAnswers(questions.map(() => new Set<number>()));
    setShowResults(false);
    setScore(0);
  };

  const allAnswered = selectedAnswers.every((s) => s.size > 0);

  return (
    <div className={styles.qcmContainer}>
      <h3 className={styles.title}>{title}</h3>

      {questions.map((q, qIndex) => {
        const multi = isMultiple(q.correct);
        const correctSet = getCorrectSet(q.correct);
        return (
          <div key={qIndex} className={styles.questionCard}>
            <p className={styles.questionText}>
              <strong>Question {qIndex + 1}.</strong>{" "}
              <MathText text={q.question} />
              {multi && (
                <span className={styles.multiHint}>
                  {" "}
                  (plusieurs réponses possibles)
                </span>
              )}
            </p>
            <div className={styles.answers}>
              {q.answers.map((answer, aIndex) => {
                const isSelected = selectedAnswers[qIndex].has(aIndex);
                const isCorrect = correctSet.has(aIndex);
                let answerClass = styles.answer;

                if (showResults) {
                  if (isSelected && isCorrect) {
                    answerClass = `${styles.answer} ${styles.correct}`;
                  } else if (isSelected && !isCorrect) {
                    answerClass = `${styles.answer} ${styles.incorrect}`;
                  } else if (!isSelected && isCorrect) {
                    answerClass = `${styles.answer} ${styles.missed}`;
                  }
                } else if (isSelected) {
                  answerClass = `${styles.answer} ${styles.selected}`;
                }

                return (
                  <label key={aIndex} className={answerClass}>
                    <input
                      type={multi ? "checkbox" : "radio"}
                      name={`question-${qIndex}`}
                      checked={isSelected}
                      onChange={() => handleAnswerSelect(qIndex, aIndex)}
                      disabled={showResults}
                    />
                    <span className={styles.answerText}>
                      <MathText text={answer} />
                    </span>
                  </label>
                );
              })}
            </div>
            {showResults && q.explanation && (
              <div className={styles.explanation}>
                <strong>Explication :</strong> <MathText text={q.explanation} />
              </div>
            )}
          </div>
        );
      })}

      <div className={styles.actions}>
        {!showResults ? (
          <button
            className={styles.submitButton}
            onClick={handleSubmit}
            disabled={!allAnswered}
          >
            Valider
          </button>
        ) : (
          <>
            <div className={styles.scoreDisplay}>
              Score : {score}/{questions.length} (
              {Math.round((score / questions.length) * 100)}%)
            </div>
            <button className={styles.resetButton} onClick={handleReset}>
              Recommencer
            </button>
          </>
        )}
      </div>
    </div>
  );
}
