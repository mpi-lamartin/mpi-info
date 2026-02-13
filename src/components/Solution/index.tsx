import React from "react";
import CodeBlock from "@theme/CodeBlock";
import clsx from "clsx";
import { Details } from "@docusaurus/theme-common/Details";
import MDXContent from "@theme/MDXContent";

import styles from "./styles.module.css";

const InfimaClasses = "alert alert--success";

export default ({
  file,
  lang,
  show,
  title = "Solution",
  children,
}): JSX.Element => {
  return (
    <div>
      {" "}
      {show && (
        <Details
          className={clsx(InfimaClasses, styles.details)}
          summary={title}
        >
          {children && <MDXContent>{children}</MDXContent>}
          <CodeBlock language={lang}>{file}</CodeBlock>
        </Details>
      )}
    </div>
  );
};
