import React from 'react';
import BlogPostItems from '@theme-original/BlogPostItems';
import type BlogPostItemsType from '@theme/BlogPostItems';
import type {WrapperProps} from '@docusaurus/types';

type Props = WrapperProps<typeof BlogPostItemsType>;

export default function BlogPostItemsWrapper(props: Props): JSX.Element {
  return (
    <>
    {/* <center>
    <iframe src="https://calendar.google.com/calendar/embed?height=400&wkst=1&ctz=Europe%2FParis&bgcolor=%23ffffff&showTitle=0&showPrint=0&showTabs=0&showCalendars=0&showTz=0&title=MPI&mode=MONTH&src=MzQwN2VjM2M3M2MzOWQxODQwNzZiN2U0ZWFkN2MzNDM2ODIyYzI0ZWJmYTZiM2YxMjBiNzk1ZWU1NmVmYjVlNkBncm91cC5jYWxlbmRhci5nb29nbGUuY29t&src=M2hha3JjZmVkMGswNTI2YXYzNzIwaWdqdW9nYTVsODFAaW1wb3J0LmNhbGVuZGFyLmdvb2dsZS5jb20&src=ZnIuZnJlbmNoI2hvbGlkYXlAZ3JvdXAudi5jYWxlbmRhci5nb29nbGUuY29t&color=%23E4C441&color=%23E4C441&color=%230B8043" style={{borderWidth:0}} width="600" height="400" frameborder="0" scrolling="no"></iframe>
    </center> */}
      <BlogPostItems {...props} />
    </>
  );
}
