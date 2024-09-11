import React, { useState } from 'react';
import Button from '@mui/material/Button';
import Pdf from '@site/src/components/Pdf';

export default ({ pdf, cor }): JSX.Element => {
  const [bool, setBool] = useState(false);
  return (
    <div>
      <p>
        <center>
          <Button sx={{ mx: "auto", m: -2 }} variant="contained" onClick={() => { setBool((b) => !b) }}>{bool ? "Énoncé" : "Corrigé"}</Button>
        </center>
      </p>
      <Pdf pdf={bool ? cor : pdf} td={true} />
    </div>
  );
}
