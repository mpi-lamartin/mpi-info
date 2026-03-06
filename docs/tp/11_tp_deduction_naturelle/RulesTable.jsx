const containerStyle = {
  overflowX: "auto",
};

const tableStyle = {
  width: "auto",
  minWidth: "980px",
  margin: "0 auto",
  tableLayout: "fixed",
  borderCollapse: "collapse",
  textAlign: "center",
};

const pairStyle = {
  display: "flex",
  justifyContent: "center",
  gap: "8px",
  flexWrap: "wrap",
};

const imageStyle = (height) => ({
  height,
  width: "auto",
  maxWidth: "100%",
});

const axiom = require("./rules/axiom.png").default;
const impIntro = require("./rules/imp_intro.png").default;
const andIntro = require("./rules/and_intro.png").default;
const orIntroLeft = require("./rules/or_intro_left.png").default;
const orIntroRight = require("./rules/or_intro_right.png").default;
const negIntro = require("./rules/neg_intro.png").default;
const impElim = require("./rules/imp_elim.png").default;
const andElimLeft = require("./rules/and_elim_left.png").default;
const andElimRight = require("./rules/and_elim_right.png").default;
const orElim = require("./rules/or_elim.png").default;
const negElim = require("./rules/neg_elim.png").default;

export default function RulesTable() {
  return (
    <div style={containerStyle}>
      <table style={tableStyle}>
        <thead>
          <tr>
            <th></th>
            <th>Axiome</th>
            <th>Implication</th>
            <th>Conjonction</th>
            <th>Disjonction</th>
            <th>Negation</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <th>Intro</th>
            <td>
              <img src={axiom} alt="axiom" style={imageStyle("29px")} />
            </td>
            <td>
              <img src={impIntro} alt="imp_intro" style={imageStyle("37px")} />
            </td>
            <td>
              <img src={andIntro} alt="and_intro" style={imageStyle("37px")} />
            </td>
            <td>
              <div style={pairStyle}>
                <img
                  src={orIntroLeft}
                  alt="or_intro_left"
                  style={imageStyle("35px")}
                />
                <img
                  src={orIntroRight}
                  alt="or_intro_right"
                  style={imageStyle("35px")}
                />
              </div>
            </td>
            <td>
              <img src={negIntro} alt="neg_intro" style={imageStyle("40px")} />
            </td>
          </tr>
          <tr>
            <th>Elim</th>
            <td></td>
            <td>
              <img src={impElim} alt="imp_elim" style={imageStyle("37px")} />
            </td>
            <td>
              <div style={pairStyle}>
                <img
                  src={andElimLeft}
                  alt="and_elim_left"
                  style={imageStyle("37px")}
                />
                <img
                  src={andElimRight}
                  alt="and_elim_right"
                  style={imageStyle("37px")}
                />
              </div>
            </td>
            <td>
              <img src={orElim} alt="or_elim" style={imageStyle("40px")} />
            </td>
            <td>
              <img src={negElim} alt="neg_elim" style={imageStyle("37px")} />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  );
}
