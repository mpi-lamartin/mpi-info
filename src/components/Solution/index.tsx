import React from "react";
import CodeBlock from "@theme/CodeBlock";
import clsx from "clsx";
import { Details } from "@docusaurus/theme-common/Details";
import { useLocation } from "@docusaurus/router";
import MDXContent from "@theme/MDXContent";

import styles from "./styles.module.css";

const InfimaClasses = "alert alert--success";

type SolutionProps = {
  file?: string;
  lang?: string;
  show: boolean;
  title?: string;
  part?: string | number;
  children?: React.ReactNode;
};

const extractPart = (file: string, part: string | number): string => {
  const lines = file.split("\n");
  const startMarker = `solution:${part}:start`;
  const endMarker = `solution:${part}:end`;
  const start = lines.findIndex((line) => line.includes(startMarker));
  const end = lines.findIndex(
    (line, index) => index > start && line.includes(endMarker),
  );

  if (start === -1 || end === -1) {
    throw new Error(`Solution part "${part}" not found`);
  }

  return lines
    .slice(start + 1, end)
    .join("\n")
    .trim();
};

export default ({
  file,
  lang,
  show,
  title = "Solution",
  part,
  children,
}: SolutionProps): JSX.Element => {
  const { search } = useLocation();
  const open = new URLSearchParams(search).get("cor") === "1";
  const visible = show && open;
  const code = part === undefined ? file : extractPart(file ?? "", part);

  return (
    <div>
      {" "}
      {visible && (
        <Details
          key={open ? "correction" : "statement"}
          className={clsx(InfimaClasses, styles.details)}
          summary={title}
          open={open}
        >
          {children && <MDXContent>{children}</MDXContent>}
          {code && <CodeBlock language={lang}>{code}</CodeBlock>}
        </Details>
      )}
    </div>
  );
};
