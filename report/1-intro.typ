#import "common.typ": *

= Introduction

This report concludes the work sponsored by the Innosuisse grant 101.292 IP-ICT aiming at formulating a proposal strengthening the privacy guarantees offered by Swiyu @Swiyu.

Throughout the last year and a half a lot has happened in the digital identity space.
Countries have debated and rolled-out age bans for social media, adult and gambling websites; on one-hand protecting a vulnerable population, on the other significantly
threatening the privacy of users.
In parallel, the staggering speed of LLM development has allowed the creation of convincing fake images of identity documents.
Academia, industry, and governing bodies have all produced work with a high impact on which technologies can be deployed to fend off these issues.

The first part, _Overview of our Solution_, chapter @what, of this report covers the context we considered for our work as well as some of the major publications proposing similar solutions for similar
contexts.
We make heavy use of the insights shared in our taxonomy document @EIDTaxonomy as well as the work published recently by major industry actors like Google's Longfellow-zk @FS24, Microsoft's Crescent @FFL25, Spartan @S19, Vega @KS25, as well as the Ethereum Foundation's OpenAC @ENRT26.

In the second part, _Specific Choices for Implementations_, chapter @why, we explain the technical factors that led to our design and implementation decisions.
Our main goal was to develop a solution which can be run on
mid-range mobile phones with acceptable performance to create and
send a proof.
The second goal was to make it possible to deploy our solution using
currently used digital identity schemes, and make it usable to
non-cryptography experts.
We show how our choices respect these two goals, and what we needed
to sacrifice in order to get there.

The third part, _If you want to use our code_, chapter @how, explains how our
work can be used for other research or products.
We give more detailed explanation of the
