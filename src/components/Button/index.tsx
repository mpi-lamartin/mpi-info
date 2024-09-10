import React, {useState} from 'react';
import {useLocation} from '@docusaurus/router';
import Button from '@mui/material/Button';

export default function MyComponent({pdf, cor}) {
  const [bool, setBool] = useState(false);
  const location = useLocation();
  return (
    <div>
      <p>
        <center>
        <Button sx={{ mx: "auto", m: -2 }} variant="contained" onClick={() => {console.log(pdf.replace(".pdf", "_cor.pdf")); setBool((b) => !b)}}>{bool ? "Corrigé" : "Énoncé"}</Button>
        </center>
      </p>
      <div className="containerA4">
      <iframe src={bool ? pdf : cor} className='responsive-iframe' allowFullScreen></iframe>
      </div>
    </div>
  );
}
