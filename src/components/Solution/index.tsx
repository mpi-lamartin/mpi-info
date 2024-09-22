import React from 'react';
import CodeBlock from '@theme/CodeBlock';
import clsx from 'clsx';
import { Details as DetailsGeneric } from '@docusaurus/theme-common/Details';
import MDXContent from '@theme/MDXContent';

import styles from './styles.module.css';

const InfimaClasses = 'alert alert--success';

export default ({ file, lang, show, children }): JSX.Element => {
  return (
    <div> {show &&
      <DetailsGeneric
        className={clsx(InfimaClasses, styles.details)} summary="Solution">
        {children && <MDXContent>{children}</MDXContent>}
        <CodeBlock language={lang}>{file}</CodeBlock>
      </DetailsGeneric>
    }
    </div>
  );
}
