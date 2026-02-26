import { useColorMode } from '@docusaurus/theme-common';

export default ({ pdf, td = false }): JSX.Element => {
  const { colorMode } = useColorMode();
  const isDark = colorMode === 'dark';

  return (
    <div className={td ? "containerA4" : "container4x3"}>
      <iframe
        src={pdf + "#view=Fit&pagemode=none"}
        className="responsive-iframe"
        style={isDark ? { filter: 'invert(0.9) hue-rotate(180deg)' } : {}}
        allowFullScreen
      />
    </div>
  );
};
