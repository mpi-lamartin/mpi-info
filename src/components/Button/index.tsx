import React from "react";
import { useLocation } from "@docusaurus/router";
import Pdf from "@site/src/components/Pdf";

export default ({ pdf, cor }): JSX.Element => {
  const { search } = useLocation();
  const showCorrection = Boolean(cor) && new URLSearchParams(search).get("cor") === "1";

  return (
    <div>
      <Pdf pdf={showCorrection ? cor : pdf} td={true} />
    </div>
  );
};
