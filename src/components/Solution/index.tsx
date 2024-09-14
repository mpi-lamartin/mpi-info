import React from 'react';
import CodeBlock from '@theme/CodeBlock';
import clsx from 'clsx';
import { Details as DetailsGeneric } from '@docusaurus/theme-common/Details';

import styles from './styles.module.css';

const InfimaClasses = 'alert alert--success';

export default ({ file, lang, show }): JSX.Element => {
  return (
    <div> {show &&
      <DetailsGeneric
        className={clsx(InfimaClasses, styles.details)} summary="Solution">
        <CodeBlock language={lang}>{file}</CodeBlock>
      </DetailsGeneric>
    }
    </div>
  );
}
