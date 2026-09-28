import React from "react";
import clsx from "clsx";
import { ThemeClassNames } from "@docusaurus/theme-common";
import { isActiveSidebarItem } from "@docusaurus/plugin-content-docs/client";
import Link from "@docusaurus/Link";
import isInternalUrl from "@docusaurus/isInternalUrl";
import { useHistory, useLocation } from "@docusaurus/router";
import IconExternalLink from "@theme/Icon/ExternalLink";

import styles from "./styles.module.css";

function LinkLabel({ label }) {
  return (
    <span title={label} className={styles.linkLabel}>
      {label}
    </span>
  );
}

export default function DocSidebarItemLink({
  item,
  onItemClick,
  activePath,
  level,
  ...props
}) {
  const { href, label, className, autoAddBaseUrl, customProps } = item;
  const isActive = isActiveSidebarItem(item, activePath);
  const isInternalLink = isInternalUrl(href);
  const hasCorrection = customProps?.cor === true;
  const location = useLocation();
  const history = useHistory();
  const showCorrection =
    isActive &&
    hasCorrection &&
    new URLSearchParams(location.search).get("cor") === "1";
  const correctionHref = `${href}?cor=1`;

  function toggleCorrection() {
    const searchParams = new URLSearchParams(location.search);

    if (showCorrection) {
      searchParams.delete("cor");
    } else {
      searchParams.set("cor", "1");
    }

    history.push({
      pathname: location.pathname,
      search: searchParams.toString(),
      hash: location.hash,
    });
  }

  return (
    <li
      className={clsx(
        ThemeClassNames.docs.docSidebarItemLink,
        ThemeClassNames.docs.docSidebarItemLinkLevel(level),
        "menu__list-item",
        className,
      )}
      key={label}
    >
      <div
        className={clsx(styles.itemContent, {
          [styles.itemContentActive]: isActive,
          [styles.itemContentCorrectionActive]: showCorrection,
        })}
      >
        <Link
          className={clsx(
            "menu__link",
            !isInternalLink && styles.menuExternalLink,
            {
              "menu__link--active": isActive,
            },
          )}
          autoAddBaseUrl={autoAddBaseUrl}
          aria-current={isActive ? "page" : undefined}
          to={href}
          {...(isInternalLink && {
            onClick: onItemClick ? () => onItemClick(item) : undefined,
          })}
          {...props}
        >
          <LinkLabel label={label} />
          {!isInternalLink && <IconExternalLink />}
        </Link>
        {hasCorrection && (
          isActive ? (
            <button
              className={clsx(styles.correctionToggle, {
                [styles.correctionToggleActive]: showCorrection,
              })}
              type="button"
              aria-pressed={showCorrection}
              aria-label={showCorrection ? "Afficher l'énoncé" : `Afficher le corrigé de ${label}`}
              onClick={toggleCorrection}
            >
              corrigé
            </button>
          ) : (
            <Link
              className={styles.correctionToggle}
              aria-label={`Afficher le corrigé de ${label}`}
              to={correctionHref}
            >
              corrigé
            </Link>
          )
        )}
      </div>
    </li>
  );
}