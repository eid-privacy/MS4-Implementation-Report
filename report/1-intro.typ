#import "common.typ": *

= Introduction

This report concludes the work sponsored by the Innosuisse grant 101.292 IP-ICT aiming at formulating a proposal strengthening the privacy guarantees offered by Swiyu @Swiyu.

Throughout the last year and a half a lot has happened in the digital identity space.
Countries have debated and rolled-out age bans for social media, adult and gambling websites, on one-hand protecting a vulnerable population, on the other significantly
threatening the privacy of users.
In parallel, the staggering speed of LLM development has allowed the creation of very convincing fake images of identity documents.
Academia, industry, and governing bodies have all produced work with a high impact on which technologies can be deployed to fend off these issues.

The first part -- _What_ -- of this reports covers the context we considered for our work as well as some of the major publications proposing similar solutions for similar
contexts.
We make heavy use of the insights shared in our taxonomy document @EIDTaxonomy as well as the analyses of work published recently by major industry actors with Google's Longfellow-zk @FS24, Microsoft's Crescent @FFL25, Spartan @S19, Vega @KS25, as well as the Ethereum Foundation's OpenAC @ENRT26.

In the second part, _Why_, we explain the technical factors that led to our design and implementation decisions.
The main driver was the performance we tried to get from consumer-grade hardware such as mid-range mobile phone. Then came the real-world deployment factors
that constrain the implementation of a nation-wide digital identity scheme.
We go through how we tried to provide a proposal that does not sacrifice the
accessibility of the solution to third-parties while retaining appropriate performance.

The last chapter provides the _How_ for people who want to use and extend the work we're describing here.

