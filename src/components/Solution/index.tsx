import React from "react";
import CodeBlock from "@theme/CodeBlock";
import clsx from "clsx";
import { Details } from "@docusaurus/theme-common/Details";
import { useLocation } from "@docusaurus/router";
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
  const { search } = useLocation();
  const open = new URLSearchParams(search).get("cor") === "1";
  const visible = show && open;

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
          <CodeBlock language={lang}>{file}</CodeBlock>
        </Details>
      )}
    </div>
  );
};
