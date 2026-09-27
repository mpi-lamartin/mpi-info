import { useDoc } from "@docusaurus/plugin-content-docs/client";
import Button from "@site/src/components/Button";

interface FrontMatter {
  pdf?: string;
  cor?: boolean;
}

interface PdfModule {
  default: string;
}

interface PdfContext {
  (path: string): PdfModule;
}

const pdfs: PdfContext = require.context("@site/docs", true, /\.pdf$/);

export default function TD(): JSX.Element {
  const { frontMatter, metadata } = useDoc();
  const { pdf, cor } = frontMatter as FrontMatter;

  if (!pdf) {
    throw new Error("Le front matter d'un TD doit définir un PDF.");
  }

  const sourceDirectory = metadata.source.replace(/\/[^/]+$/, "");
  const pdfPath = `${sourceDirectory}/${pdf}.pdf`.replace("@site/docs", ".");
  const correctionPath = `${sourceDirectory}/${pdf}_cor.pdf`.replace(
    "@site/docs",
    ".",
  );

  return (
    <Button
      pdf={pdfs(pdfPath).default}
      cor={cor ? pdfs(correctionPath).default : undefined}
    />
  );
}