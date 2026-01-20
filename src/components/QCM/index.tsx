import React, { useState } from 'react';
import styles from './styles.module.css';

interface Question {
  question: string;
  answers: string[];
  correct: number; // index of correct answer (0-based)
  explanation?: string;
}

interface QCMProps {
  questions: Question[];
  title?: string;
}

export default function QCM({ questions, title = "QCM" }: QCMProps): JSX.Element {
  const [selectedAnswers, setSelectedAnswers] = useState<(number | null)[]>(
    new Array(questions.length).fill(null)
  );
  const [showResults, setShowResults] = useState(false);
  const [score, setScore] = useState(0);

  const handleAnswerSelect = (questionIndex: number, answerIndex: number) => {
    if (showResults) return;
    const newAnswers = [...selectedAnswers];
    newAnswers[questionIndex] = answerIndex;
    setSelectedAnswers(newAnswers);
  };

  const handleSubmit = () => {
    let newScore = 0;
    questions.forEach((q, i) => {
      if (selectedAnswers[i] === q.correct) {
        newScore++;
      }
    });
    setScore(newScore);
    setShowResults(true);
  };

  const handleReset = () => {
    setSelectedAnswers(new Array(questions.length).fill(null));
    setShowResults(false);
    setScore(0);
  };

  const allAnswered = selectedAnswers.every((a) => a !== null);

  return (
    <div className={styles.qcmContainer}>
      <h3 className={styles.title}>{title}</h3>
      
      {questions.map((q, qIndex) => (
        <div key={qIndex} className={styles.questionCard}>
          <p className={styles.questionText}>
            <strong>Question {qIndex + 1}.</strong> {q.question}
          </p>
          <div className={styles.answers}>
            {q.answers.map((answer, aIndex) => {
              const isSelected = selectedAnswers[qIndex] === aIndex;
              const isCorrect = q.correct === aIndex;
              let answerClass = styles.answer;
              
              if (showResults) {
                if (isCorrect) {
                  answerClass = `${styles.answer} ${styles.correct}`;
                } else if (isSelected && !isCorrect) {
                  answerClass = `${styles.answer} ${styles.incorrect}`;
                }
              } else if (isSelected) {
                answerClass = `${styles.answer} ${styles.selected}`;
              }

              return (
                <label key={aIndex} className={answerClass}>
                  <input
                    type="radio"
                    name={`question-${qIndex}`}
                    checked={isSelected}
                    onChange={() => handleAnswerSelect(qIndex, aIndex)}
                    disabled={showResults}
                  />
                  <span className={styles.answerText}>{answer}</span>
                </label>
              );
            })}
          </div>
          {showResults && q.explanation && (
            <div className={styles.explanation}>
              <strong>Explication :</strong> {q.explanation}
            </div>
          )}
        </div>
      ))}

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
              Score : {score}/{questions.length} ({Math.round((score / questions.length) * 100)}%)
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
