import React, { useState } from 'react';

export default ({ pdf, td = false }): JSX.Element => {
  return (
    <div className={td ? "containerA4" : "container4x3"}>
      <iframe src={pdf + "#zoom=page-fit&pagemode=none"} className='responsive-iframe' allowFullScreen />
    </div>
  );
}
