export default ({ pdf, td = false }): JSX.Element => {
  return (
    <div className={td ? "containerA4" : "container4x3"}>
      <iframe
        src={pdf + "#view=Fit&pagemode=none"}
        className="responsive-iframe"
        allowFullScreen
      />
    </div>
  );
};
