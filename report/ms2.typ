#import "@preview/dashy-todo:0.1.3": todo
#set heading(numbering: "1.")
#show table.cell.where(y: 0): strong

#let formatFloat(n, d: 1) = {
  let s = str(calc.round(n, digits: d))
  if not s.contains(".") { s + ".0" } else { s }
}

#let addTime(a, b, d: 1) = {
  formatFloat(float(a) + float(b), d: d) + "s"
}

#let roundSize(a) = {
  str(calc.round(int(a) / 1024)) + "kB"
}

#let timeNoir(wp) = {
  let stats = csv("stats_noir.csv").at(wp)
  addTime(stats.at(4), stats.at(5))
}
#let sizeNoir(wp) = {
  let stats = csv("stats_noir.csv").at(wp)
  roundSize(stats.at(6))
}
#let timeDock(wp) = {
  let stats = csv("stats_dock.csv").at(wp)
  addTime(stats.at(2), stats.at(3), d: 2)
}
#let sizeDock(wp) = {
  let stats = csv("stats_dock.csv").at(wp)
  roundSize(stats.at(4))
}

#let Pub_holder = $"Pub"_"holder"$
#let Pub_issuer = $"Pub"_"issuer"$
#let challenge = $"Challenge"$
#let credential = $"Credential"$
#let revocation_list = $"Revocation List"$
#let timestamp_now = $"Current Date"$
#let Sig_cred = $"Sig"_"cred"$
#let Sig_ch = $"Sig"_"ch"$
#let Sig_list = $"Sig"_"list"$
#let Pr_holder = $"proof"_"holder"$
#let Pr_sig_ch = $"proof"_#Sig_ch$
#let Pr_Pub_holder = $"proof"_#Pub_holder$
#let Pr_sig_cred = $"proof"_#Sig_cred$
#let Pr_predicate = $"proof"_"predicate"$
#let Pr_non-rev = $"proof"_"non-rev"$
#let Sig_valid(pub, sig, msg) = $"signature_valid"( #pub, #sig, #msg )$

#let link_zkp_pocs_noir(text, test) = link(
  "https://github.com/eid-privacy/zkp-pocs/blob/main/noir/" + test + "/src/main.nr",
  text
)
#let link_zkp_pocs_dock(text, test) = link(
  "https://github.com/eid-privacy/zkp-pocs/blob/main/docknetwork/tests/" + test + ".rs",
  text
)

= Report MS2

This report is the G0.2 for the milestone 2 of the Innosuisse grant 101.292 IP-ICT,
*Secure and Privacy-Preserving Credentials for E-ID*.
It recaps the results we gained from building a Proof-of-Concept for an anonymous,
unlinkable credential which has the following capabilities:

/ device/holder binding: proving that the credential is stored on a specific smartphone,
  see @proof_device_binding
/ issuer signature: proving that the credential has been signed by the issuer,
  see @proof_issuer_signature
/ predicates: proving specific attributes for equality, comparison, or revelation,
  see @proof_predicate
/ non-revocation: proving that the credential is still valid, see @proof_non_revocation

The report starts with a summary and recap of the terms used, problems encountered, and
solutions tried.
Then it goes through the WP 3 to 6, and presents the solutions we propose.
It links to our different technical blog posts @EIDBlog, our taxonomy whitepaper @EIDTaxonomy,
and the implementations we wrote.

== Summary of Results

In @table_summary you can find the different solutions we propose in the work packages.
As every solution has their advantages and drawbacks, it is not yet clear which
ones are to be chosen.
In the second half of the grant, we will discuss with our partners which of these make
the most sense to implement.

#figure(
  table(
    columns: 4,
    table.header([Work Package], [Solution], [Overall Time / Proof Size], [Links]),
    table.cell(rowspan:3)[WP3 - Device Binding],
    [Noir], [#timeNoir(1) / #sizeNoir(1)], [#link_zkp_pocs_noir("holder_binding", "c03_holder_binding")],
    [Docknetwork/ZKAttest], [#timeDock(1) / #sizeDock(1)], [#link_zkp_pocs_dock("holder_binding", "c03_holder_binding")],
    [Longfellow], [1s / 300kb], [@FS24],

    table.cell(rowspan:3)[WP4 - Issuer Signature],
    [Noir], [#timeNoir(2) / #sizeNoir(2)], [#link_zkp_pocs_noir("issuer_signature", "c04_issuer_signature")],
    [Docknetwork/BBS], [#timeDock(2) / #sizeDock(2)], [#link_zkp_pocs_dock("issuer_signature", "c04_issuer_signature")],
    [Longfellow], [1s / 300kb], [@FS24],

    table.cell(rowspan:3)[WP5 - Predicates],
    [Noir], [#timeNoir(3) / #sizeNoir(3)], [#link_zkp_pocs_noir("age_verification", "c05_age_verification")],
    [Docknetwork/Bulletproofs], [#timeDock(4) / #sizeDock(4)], [#link_zkp_pocs_dock("age_verification", "c05_age_verification")],
    [Longfellow], [.47s / 300kb], [@FS24],

    table.cell(rowspan:2)[WP6 - Non-Revocation],
    [Noir], [#timeNoir(4) / #sizeNoir(4)], [#link_zkp_pocs_noir("non_revocation", "c06_non_revocation")],
    [Docknetwork/Accumulators], [#timeDock(5) / #sizeDock(5)], [#link_zkp_pocs_dock("non_revocation", "c06_non_revocation")],

    table.cell(rowspan:2)[WP3..WP6],
    [Noir], [#timeNoir(5) / #sizeNoir(5)], [#link_zkp_pocs_noir("full_proof", "c09_full_proof")],
    [Docknetwork/All], [#timeDock(6) / #sizeDock(6)], [#link_zkp_pocs_dock("full_proof", "c09_full_proof")],
  ),
  caption: [Summary of our proof-of-concepts]
) <table_summary>

== Recap of Cryptography

We will use the following terms in this report, which you can find explained in
more details in our Taxonomy Paper @EIDTaxonomy.

/ One-way functions: the basic building block of asymmetric cryptography:
  functions which
  apply to two or more domains, are easy to calculate in one direction, but very
  difficult to reverse, and with homomorphic properties between the domains
/ RSA: one of the first *one-way function* used in cryptography, still widely
  used in 2025
/ Elliptic Curves: smaller than *RSA* but with the same security guarantees,
  they provide more functionality to create interesting cryptographic operations
/ Hash functions: can be used as a *one-way function*, but mostly used as an
  *oracle* to link a given message to a random, but deterministic, identifier
/ Post-quantum security: abbreviated as *PQS* or simply *PQ*, signifies that
  the given algorithm is secure, even in the presence of universal, big,
  error-free, and fast quantum computers
/ Signature: a cryptographic algorithm where the holder of a private key
  can create a proof (the signature) linked to a message. This proof can then
  be verified using the public key of the holder

== Recap of Zero-Knowledge Proofs

Throughout our work we make extensive use of Zero-Knowledge Proofs (ZKP).
In the most generic terms, a ZKP is a protocol between a *Prover*, which has
a secret *Witness*, and a *Verifier*, which wants to be sure that the
witness satisfies an agreed-upon *Statement*, without learning
more about the witness.
An example for e-ID is a holder (prover) with their credential (witness),
which creates a *Proof* that they are 18 years old or older (statement),
to convince an internet service (verifier), without the service learning the exact
age or any other information that uniquely identify the credential or the holder.

The challenges in ZKPs are manyfold:

/ Size of the proof: some ZKPs create proof sizes in the range of gigabytes,
  which is too big to be sent from a holder to a verifier in an e-ID
  scenario. We consider everything below 1MB to be acceptable
/ Proof creation time: depending on the algorithms, this can be sub-second or
  take many minutes. We consider everything faster than 1s to be acceptable
/ Auditability: there is little standardization of ZKPs, so optimizations are
  often only done in academic papers and rarely go through extensive
  security reviews
/ Composability: as ZKPs are very complex, it is difficult for non-expert
  software engineers to create such proofs and use them

In @table_zkp_comparison we give a short overview for the algorithms
presented in this report and how they fare for the operations used.
It is to be noted that this evaluation can greatly differ depending on the
goals for these algorithms.
Also, when writing Noir, we refer ourselves to the version 1.0.0-beta15
with the Barretenberg backend using UltraHONK @UltraHONK.

#figure(
  table(
    columns: 5,
    table.header([Algorithm], [Proof size], [Proof time], [Auditability], [Composability]),

    [ZKAttest], [OK], [OK], [OK], [Limited],
    [Noir], [OK], [OK], [Some], [OK],
    [Longfellow], [OK], [OK], [Some], [No],
    [Bulletproof], [OK], [OK], [OK..Some], [Some (range proofs)],
    [BBS], [OK], [OK], [OK], [Some]
  ),
  caption: [Short comparison of algorithms used in this report]
) <table_zkp_comparison>

We can recap the three main solutions explored here like the following:

/ Noir: Written in an easy-to learn language which is very close to Rust.
  Fast verification time, but slower proving time compared to specialized solutions like
  Docknetwork.
/ ZKAttest: Simple proof, understandable and verifiable with reasonable level of expertise.
  Uses BBS, a non-standardized credential format which is not PQS.
/ Longfellow: Fast, post-quantum secure. But circuit auditing and writing is difficult.

== Recap of Credentials

An e-ID system is based on *Credentials* which hold the information about a user
and are signed by the issuers.
In EU and CH, but also some places in the USA, the following credential types are
used:

/ mDoc / mDL: mobile driving license credential based on ISO/IEC 18013-5:2021
/ SD-JWT: generic credential with selective disclosure capabilities

For our tests, we also used the following types credentials:

/ BBS: a special signature type which allows to create simple proofs about the
  attributes of a credential
/ Flat: simple credentials where every attribute is contained within fixed-sized fields
  in a byte-array

=== Flat Credentials

In this MS2, we considered a *Flat* credential with fixed-size fields.
This is not how current SD-JWT and mDoc are used, but gave us an easy way
to test if our algorithms work.
The information stored in the credentials consists of:

- *First Name* - up to 32 characters
- *Last Name* - up to 32 characters
- *Date of Birth* - stored as a unix timestamp in seconds, 10 characters
- *#Pub_holder* - the x and y co-ordinates in hex format, 2 \* 32 characters
- *Credential ID* - a unique ID of the credential for revocation, 16
  characters

This gives a total of 218 bytes for the credential.
We also worked with SD-JWT credentials and are able to write noir circuits to prove statements about them.
For the proof-of-concept however, we stayed with the *Flat* credential.
It is also important to note that these credentials never leave the
phone of the holder, as the credential is always used for the *private input*
of the noir circuit (see @Noir_101).
So only the information chosen by the holder is being sent to the
verifier, plus the proof that the circuit is correct.


=== Privacy in Swiyu

Holder's privacy in the current version of Swiyu (and the EUID) hinges on two mechanisms when it comes to the
credential format:
/ Selective disclosure: the credential contains hashes of the holder's attribute value rather than the values
  themselves. This allows the holder to share actual values on a granular and case-by-case basis,
  and the holder to verify that these values match the hashes signed by the issuer of the credential.
/ Batch issuance: an SD-JWT or mDoc credential holds uniquely identifying data, whether technical or related
  to the physical person it describes. To avoid issuers and verifiers tracking users across interactions by keeping
  track of these unique pieces of data, Swiyu (and the EU) plan on issuing batches of single-use credentials to holders.
  The implementation intent for Swiyu is described in the
  #link("https://github.com/swiyu-admin-ch/community/blob/main/tech-concepts/e-id-key-management-batch-issuance-and-renewal.md")[Key Management for e-ID - Batch Issuance and Renewal] technical paper.
  Each credential is meant to be presented once to prevent reappearance of these uniquely identifying values. While this
  solution technically works, it involves a sizeable overhead for issuers (more cryptographic work), and holders
  (careful keys and credentials management).

== Recap of Needed Elements

Throughout this report we'll reference the following elements between the
issuer, the holder, and the verifier.
For every WP, the corresponding proofs need to be valid, but so far we did not
create a proof over all WPs.

/ #credential: the data stored on the mobile device of the holder containing
  various attributes and signed by the issuer
/ #Pub_holder: the public key of the secure element of the holder - needs to be
  kept secret
/ #Pub_issuer: the public key of the issuer, supposed to be known by all parties
/ #challenge: a random string sent by the verifier to avoid replay attacks.
  Is known to both the verifier and the holder.
/ #Sig_cred: the signature of the credential, verifiable with the #Pub_issuer
/ #Sig_ch: the signature of the challenge, verifiable with the #Pub_holder
/ #Pr_holder: ZKP that the #credential is still on the same device, composed of
  the following proofs: (@proof_device_binding)
  / #Pr_sig_ch: ZKP of a signature on the #challenge, verifiable by #Pub_holder
  / #Pr_Pub_holder: ZKP that #Pub_holder is in the #credential
/ #Pr_sig_cred: ZKP that the #credential has been signed by #Pub_issuer,
  which is publicly known (@proof_issuer_signature)
/ #Pr_predicate:ZKP that the predicate is true for #credential (@proof_predicate)
/ #Pr_non-rev: ZKP that #credential has not been revoked and is still valid
  (@proof_non_revocation)
/ #Sig_valid("public key", "signature", "message"): whether the $"public key"$
  can verify the $"signature"$ over the $"message"$


== Frameworks used for our Proof-of-Concepts

While developing our Proof-of-Concepts we were looking for a framework / library which
can be used for the implementation of a privacy-preserving presentation of e-ID
attributes.
From all the libraries presented in WP2, we tried out two and participate actively
in their development:

/ Docknetwork@docknetwork: is the most complete library available for our purposes
  and has been developed regularly up to early 2025.
  Unfortunately, development on this library has been stopped to a halt, and our last
  change requests took very long to be included.
  It is written in the Rust language, which is considered as one of the most appropriate
  programming language for cryptographic libraries, as it allows the programmers to
  express constraints on the data which help to catch errors very early in development.
/ Noir@noir_lang: has been developed for the blockchain world, with the goal to be
  *The Programming Language for Private Apps*.
  It suits our use-case, as it allows writing programs on a very abstract level,
  which are then turned into ZKP circuits and proofs.
  While its development is fast, and allows outside contributions like ours, it is
  geared towards blockchains.
  Noir is currently optimized for fast verification time, which makes sense in a blockchain,
  but for our purposes we're investigating to rewrite a prover and optimize for
  fast prover time.

=== Docknetwork <Docknetwork_101>

This library is a collection of the most popular algorithms around privacy preserving
algorithms, and includes libraries to use various credential formats, electronic
signatures, and proof systems.
It includes enough tests to make sure its functionality is correct, and has both a
rust and a typescript interface, which makes it ready for wide use.
There is also a ZKP framework based on LegoGroth @CFQ19, which allows to link several
proofs like

- The #Sig_cred on #credential can be verified by #Pub_issuer
- The number 'birth_date' is more than 25 years before the #timestamp_now
- The number 'birth_date' is the same as the value of the field 'birth_date'
  in the #credential

where only #Pub_issuer and #timestamp_now are public.

=== Noir <Noir_101>

With Noir it is relatively easy to create ZKPs on complex statements,
and use them in independent products.
Like with all cryptography, it is important to know the caveats and how to optimize
the program.
For our proof-of-concepts, we concentrated on the right things to prove,
and will concentrate on the speed in the second half of the grant.
When defining a ZKP with Noir, the following parts are important:

/ Secret Inputs: are only known to the *prover*, and need to be linked to a
  publicly known root.
  Most often this is done with a signature which can be verified using a
  trusted public key.
  Examples are the credential, a signature of the secure element, the revocation
  list used.
/ Public Inputs: are known by the *prover* and the *verifier*, but are needed
  in the calculation of the proof.
  Examples are known public keys, challenges sent by the *verifier*, the date and time.
  It is important to chose the public inputs in a way that multiple ZKPs cannot
  be used to link the holder!
/ Derived: are values derived from the secret and/or public inputs.
  We must be sure that all derived values are based on other values which are
  linked to a publicly known root.
/ Outputs: can be created by Noir, but internally an output is the same as a public
  input, where the internal calculation proves that they are the same.
/ Proof: in our PoC consist of `assert` statements which enforce comparisons
  or boolean values.
  Examples are valid signature verification, hash equalities, value comparisons.

= Proof of Concept Code

All the code for the Proof of Concept can be found in the public github
repository #link("https://github.com/eid-privacy/zkp-pocs")[github.com/eid-privacy/zkp-pocs].
It contains both the code for the docknetwork and the noir PoCs.
We made sure to make it as reproducible as possible.

== Reproducing Measurements

You can reproduce the measurements on your own machines by following the
instructions in #link("https://github.com/eid-privacy/zkp-pocs")[github.com/eid-privacy/zkp-pocs].
To make the system as reproducible as possible, we use the
#link("https://www.jetify.com/docs/devbox/installing-devbox")[DevBox]
system.
Once installed, it allows to easily run various tools on your computer to
reproduce our experiments.
The TLDR after the devbox installation is:

#v(1em)
```bash
git clone https://github.com/eid-privacy/zkp-pocs
cd zkp-pocs
devbox run dock-all # Runs all docknetwork tests
devbox run noir-all # Runs all noir examples
```
#v(1em)

After the tests and examples have been run, you can find the results
in the `docknetwork/stats.csv` and `noir/stats.csv` files.
Of course they will differ from the results we have here, unless
you have the same machine as the one we used to run these
experiments.

= G3.2 - Proof of Device (Holder) Binding <proof_device_binding>

For this first work package where we created a proof-of-concept, we had to
solve the following problem:
in order to prevent fraud by copying credentials from one device to another,
the holder must provide a signature created by the *Secure Element* of their mobile phone.
As it's technically very difficult to move the private key from one
secure element to another, the verifier can suppose that this signature
proves that the holder presents a credential that was issued to the same phone that is presenting.
The following two problems exist with this solution:

1. Current secure elements can only produce signatures of a specific type:
   ECDSA over P-256. Unfortunately these signatures are difficult to integrate
   in ZKPs.
2. To verify the signature, the verifier must know the public key,
   but this information is uniquely identifying and can be used to track the holder.

== Proof of Concept 1: Noir

For our Noir circuit to create a proof of holder binding, we have the following
arguments:

#table(
  columns: 2,
  table.header([Argument], [Elements]),
  [Secret], [
    - #credential of the holder
    - #Sig_ch over the verifier challenge
  ],
  [Public], [
    - $"Sha256"(#challenge)$ for easier signature verification
  ],
  [Derived], [
    - #Pub_holder from #credential
  ],
  [Proof],[
    - #Sig_valid([#Pub_holder], [#Sig_ch], [#challenge])
  ]
)

This means that the verifier only learns that the holder knows a signature over
the #challenge, which can be verified by the #Pub_holder.
But as the only public input is the #challenge, the verifier doesn't learn
anything which allows it to link two proofs with each other.

The performance of this circuit can be found in the summary of this section.

== Proof of Concept 2: Docknetwork and BBS, ZKAttest

SHIELDS has been developed by Ubique @SHIELDS and is based on the
ZKAttest @zkattest work by Cloudflare.
It can be used to create #Pr_holder and #Pr_sig_cred in a reasonable time
and size.
The credential used is *BBS*, and the ZKP is of the type *Sigma-Protocol*.
We presented this work in our hands-on workshop @how_eid_privacy_25 to our
partners.
We used the docknetwork-library, which we extended with the necessary
methods, to create the full proofs.

While the ZKP is easy to understand, and security audits are available for
some of the libraries, BBS is not standardized, and it is not clear if
it ever will be.
During the discussions to include BBS in the EUDI-ARF @EUDI-ARF, there
were multiple comments about standardization and security of the BBS
protocol in the discussion at @EUDI-ARF-BBS-1.
A team of mostly European cryptographers published an open letter and
proposed the BBS family of anonymous credentials, which sparked a new
discussion and more interest in this protocol: @EUDI-ARF-BBS-2.
In the following process for the EUDI-ARF, it has been decided to open
*Topics* for subsequent versions for the EUDI, and BBS has been included
as one potential signature scheme - discussion at @EUDI-ARF-BBS-3, and
the *Topic G* at @EUDI-ARF-TOPIC-G.
Finally, if a standardization by NIST would be required, this would run
counter their stated goal to deprecate non-PQS algorithms by
2030 and disallow them by 2035, as written in @NIST-IR-8547.

== Longfellow

Longfellow is the name given to the implementation of "Anonymous Credentials from ECDSA" @FS24.
Both the code and publication are work by Google.
The open-source code provided demonstrates the presentation of an mDL credential, complete with
holder binding and proof of non-revocation.

The circuits are well-optimized but also hard to read/understand/audit.
As a result they are hard to adapt to other scenarios such as presenting an SD-JWT.

The prover time for an mDoc presentation, as benchmarked in the paper, sits at 1.2s with a proof size under
1MB (although no details are provided on this) and the verifier time is recorded as 0.7s.

There is no benchmark specific to the holder binding proof.
Verifying an ECDSA signature is benchmarked at 80ms on a Pixel Pro 6 phone
and holder binding can be reasonably expected within this order of magnitude.
The author's toy credential (same concept as our "flat" credential) presentation size is around 300kb,
which we can see as an upperbound on the proof length for holder binding.

== Summary

#figure(
  table(
    columns: 4,
    align:(left),
    table.header([Algorithm], [Overall \ time], [Proof \ size], [Specific Comments]),
    [Noir], [#timeNoir(1)], [#sizeNoir(1)],
      [Only includes the #Pr_sig_ch, not the #Pr_sig_cred],
    [Docknetwork/ \ ZKAttest], [#timeDock(1)], [#sizeDock(1)],
      [Only works with BBS from the issuer side],
    [Longfellow], [\~0.08s], [\<300kb],
      [None],
  ),
  caption: [Summary of G3.2]
)

= G4.2 - Proof of Credential Signing <proof_issuer_signature>

In our observed e-ID systems, the #credential of the holder is always signed by
the issuer to mark it as valid.
Because this #Sig_cred is unique to each #credential, it must be avoided to
send the signature as-is to the verifier.
Swiyu solves this problem with *Batch Issuance*, where each holder gets a certain
number of one-use #credential, so that consecutive presentation of the #credential
doesn't leave a trail of the use of the #credential.

To reduce the load of the server, and make the holders more independent of the
issuer, we propose to have a unique #credential for the holder, which must never
be sent as-is to the verifier.
For this proof we also created two proof of concepts: one using Noir, and one
using BBS.

== Proof of Concept 1: Noir

For our Noir circuit to create a proof of credential signing, we have the following
arguments:

#table(
  columns: 2,
  table.header([Argument], [Elements]),
  [Secret], [
    - #credential of the holder
    - #Sig_cred over the #credential
  ],
  [Public], [
    - #Pub_issuer of the issuer
  ],
  [Derived], [
    - $"cred_hash" = "Sha256"( #credential )$ to verify the signature
  ],
  [Proof],[
    - #Sig_valid([#Pub_issuer], [#Sig_cred], "cred_hash")
  ]
)

This means that the verifier only learns that the holder has a #credential
which is signed by the issuer, as it's verifiable using the #Pub_issuer,
and nothing else.
In the second half of the project, this verification will have to be
performed for every proof, to assure the verifier that the holder is
using a valid #credential.

You can find the performance of this circuit in the summary of this section.

== Proof of Concept 2: Docknetwork and BBS

As can be seen in @BBS04, this is the specific problem that the BBS
signature solves: how to prove that a credential has a valid signature
without revealing the signature.
So it is to be expected that the overall time and the proof size are
optimal for docknetwork in this use case.

== Longfellow <proof_issuer_signature_longfellow>

The longfellow paper @FS24 benchmarks the presentation of a credential
comparable to our flat credential in section 6.1.
The reported prover time is 470ms on a Pixel Pro 6 for a proof size of 291kb.
This includes:
  - parsing the credential and extracting: holder key, age attribute, valid_from, and valid_until timestamps
  - proving the credential is well signed for a given issuer key
  - the proof that the credential holder is older than 18
  - proof that the credential is still valid (using the parsed timestamps)
This benchmark provides an upper-bound that we can compare to other solutions.

== Summary

#figure(
  table(
    columns: 4,
    align:(left),
    table.header([Algorithm], [Overall \ time], [Proof \ size], [Specific Comments]),
    [Noir], [#timeNoir(2)], [#sizeNoir(2)],
      [Uses the secp256k1 curve instead of the secp256r1],
    [Docknetwork/ \ BBS], [#timeDock(2)], [#sizeDock(2)],
      [Optimal use-case for BBS],
    [Longfellow], [0.470s], [291kb],
      [6.1 in @FS24, includes the scanning of the mdoc and a selective disclosure]
  ),
  caption: [Summary of G4.2]
)

= G5.2 - Proof of Predicates <proof_predicate>

For the verifier, ensuring the honest possession of a credential is not an end in itself.
Before it can offer a service to the holder, the verifier actually wants to learn about one or more of the attributes
from the holder's credential.
Instead of revealing the full attribute, the holder can also disclose only
a predicate, a statement about the actual attribute's value, to the verifier, and thus retain more privacy.
In our proof-of-concept, we consider the following revelations by the holder:

/ Selective Disclosure: allows the holder to fully reveal one or more of
  their attributes stored in the credential.
  This can be their full name, the address, or any other of the attributes
  present in the credential.
/ Set Membership: for an attribute can be used to prove that the credential
  is part of a set, e.g., prove that the citizenship is part of the EU,
  without revealing which country.
  It can also be used to show that the credential has not been revoked,
  by proving a missing membership of the credential in the list of
  revoked credentials.
/ Comparison: with numerical attributes.
  The most cited comparison is the age verification: the holder creates
  a proof that their date of birth is 18 years or more in the past.
  With additional credentials other comparisons, like salary ranges,
  are also possible.

In the upcoming Swiyu project, *selective disclosure* is done using SD-JWTs,
where the attribute is stored as $"sha256"( "salt" | "attribute_value" )$
in the credential.
To disclose the $"attribute_value"$, the holder sends it together with
the $"salt"$ to the verifier, which can calculate the hash.

*Set membership* and *comparisons* are only available for pre-defined
attribute relationships: the credential holds a list of pre-computed
comparisons, like `age <= 25`, `age <= 35`, and so on.
The holder can then reveal one or more of these entries to the verifier.

One of the big disadvantages of using this salted-hashes approach for selective disclosure in
this way is the linkability of the presentations:
every time a holder presents their credential, the verifier can look
at the hashes, and create a unique fingerprint of the holder, and then
compare this with other presentations from other verifiers.
The current Swiyu project uses *Batch Issuance* to avoid this linkability:
instead of a single credential, the holder gets a batch (usually 10) of
one-use credentials, which are deleted once they have been used.

== Proof of Concept 1: Noir

For our Noir circuit to create a proof of credential signing, we have the following
arguments:

#table(
  columns: 2,
  table.header([Argument], [Elements]),
  [Secret], [
    - #credential of the holder
  ],
  [Public], [
    - $"current_date"$ given in seconds since the Unix Epoch
  ],
  [Derived], [
    - $"date_of_birth"$ from the #credential
  ],
  [Proof],[
    - $"date_of_birth" + 18 "years" <= "current_date"$
  ]
)

Here the verifier only learns that the circuit used the $"current_date"$ to
do its calculations, but nothing specific about the birthday or the
full age.
It is to be noted that more complex age verifications pose no problem at all:
verifying that the holder is 18 years or older, but not older than 25, is easily
realizable.
To convince the verifier that the credential is valid, and that it belongs to
the holder, this should be combined with @proof_device_binding and
@proof_issuer_signature.

== Proof of Concept 2: Docknetwork and Bulletproofs

For docknetwork, we use its bulletproof implementation, which allows to do
a similar proof to the Noir proof:

- there exists a #credential which is signed by #Pub_issuer
- the same #credential has a value
- this value is more than 18 years before the #timestamp_now

Again, only the #Pub_issuer and the #timestamp_now are publicly disclosed,
while the #credential itself stays private.

== Longfellow

We use the numbers from @FS24 section 6.1 again.
For a breakdown of what the proof performs see @proof_issuer_signature_longfellow.
As a reminder, the prover time is 570ms and the proof size 291kb long.

To get a more precise idea of the time require we can deduct 80ms per signature verification to get
410ms of prover time but it is difficult to account for the rest of the checks that we don't perform
in other variants.

== Summary

#figure(
  table(
    columns: 4,
    align:(left),
    table.header([Algorithm], [Overall \ time], [Proof \ size], [Specific Comments]),
    [Noir], [#timeNoir(3)], [#sizeNoir(3)],
      [Only range-proof],
    [Docknetwork/ \ Bulletproofs], [#timeDock(4)], [#sizeDock(4)],
      [The credential is presented as a BBS],
    [Longfellow], [410ms], [291kb],
      [From @FS24 section 6.1 on a phone, deducting the signature verification time for precision.]
  ),
  caption: [Summary of G3.2]
)

= G6.2 - Proof of Non-Revocation <proof_non_revocation>

One of the last elements in presenting a credential is the proof of
validity, or proof of non-revocation: the verifier must be convinced
that the credential is still valid.
This test includes two steps: first it must be proven that the validity
field is in the future, then it must be proven that the credential ID
is not in the revocation list.
For the validity field, we already saw the comparison in @proof_predicate,
so we'll concentrate here for the prove that the credential ID is not
in the revocation list.

There are two ways to prove that the ID of a credential is still valid:

/ Accumulators@docknetwork_accumulator:
  are a cryptographic structure which allows to compress
  IDs into a fixed length field, and then have a proof for each ID to
  be absent or present in this field.
  For the proof of non-revocation, this would be the proof that the ID
  of the credential is not included in the field.
  The disadvantage of this solution is that each time the accumulator is
  updated, all holders must update their proof of non-inclusion.
/ Revocation List@Swiyu_status_list:
  in its simplest form is an array where every ID of a credential is an
  index and points to $0$ for *non-revoked* or $1$ for *revoked*.
  The Swiyu project proposes the IETF format@token_status_list, and splits
  the list in small packets.
  The size of these packets must be chosen big enough to avoid
  identification when the lists are requested, but also small enough
  that the download does not require too much resources.

== Proof of Concept 1: Noir

In our PoC we used the *revocation list* approach.
But instead of sending the ID from the holder to the verifier, we let
the holder download the revocation list, and then create
a ZKP that the ID of the credential is not in the list.
For this to be feasible, the list must not be too large, else the
time to create the proof can be many seconds.

#table(
  columns: 2,
  table.header([Argument], [Elements]),
  [Secret], [
    - #credential of the holder
    - #revocation_list corresponding to the #credential
  ],
  [Public], [
    - #Pub_issuer of the issuer
    - #timestamp_now in seconds since Unix epoch
  ],
  [Derived], [
    - $"cred_id"$, the unique ID of the #credential
    - From the #revocation_list, the following information is extracted:
      - $"start_list"$, the first ID on this list
      - $"revocation_flags"$, the bitfield with a "1" indicating revocation
      - $"signature_time"$ by the issuer to certify correctness of the list
      - #Sig_list
      - $"sig_hash" = "Sha256"(#revocation_list)$
  ],
  [Proof],[
    - $"cred_id"$ is in the range of $"start_list".."start_list" + "LIST_SIZE"$
    - the corresponding bit-entry of $"cred_id"$ in the $"revocation_flags"$ is 0 (non-revoked)
    - $"signature_time" + 7 "days" >= #timestamp_now$
    - #Sig_valid([#Pub_issuer], [#Sig_list], "sig_hash")
  ]
)

== Proof of Concept 2: Docknetwork and Cryptographic Accumulators

For this proof, we use the cryptographic accumulators present in the
docknetwork library.
Then we produce a proof for:

- there exists a #credential which is signed by #Pub_issuer
- the same #credential has a value
- this value is not present in the cryptographic accumulator

The big downside with using a cryptographic accumulator is that it
needs to be kept up-to-date both by the issuer and all the holders.
This operation can get quite big and expensive time-wise, once
there are many (more than 10'000) holders present.

== Longfellow

The publication @FS24 and the measurements published there do not include
proof of non revocation.
The published code includes the proof that a credential is not revoked
on a given status list but there are no formal measurements for this proof.

== Summary

#figure(
  table(
    columns: 4,
    align:(left),
    table.header([Algorithm], [Overall \ time], [Proof \ size], [Specific Comment]),
    [Noir], [#timeNoir(4)], [#sizeNoir(4)],
      [Uses a specific revocation-list format],
    [Docknetwork/ \ Accumulators], [#timeDock(5)], [#sizeDock(5)],
      [Updates to the non-revocation proofs on the holder side are expensive],
    [Longfellow], [], [],
      [Even though there is code available in the repository that includes revocation, we were not able
        to run it]
  ),
  caption: [Summary of G3.2]
)

= Just Because - All of the Above

Because the time for all of these proofs were already so close to what we
expected, we added a fifth proof which combines all of the above.
It proves all of the elements of G3.2-G6.2 at the same time, and the
performance on a MacBook pro is outstanding:

#figure(
  table(
    columns: 4,
    align:(left),
    table.header([Algorithm], [Overall \ time], [Proof \ size], [Specific Comment]),
    [Noir], [#timeNoir(5)], [#sizeNoir(5)], [],
    [Docknetwork], [#timeDock(6)], [#sizeDock(6)], [],
    [Longfellow], [1.170s\*], [\<1MB\*\*], [\*Does not include revocation verification.
      \*\*No formal numbers, just a comparison to Android's intent buffer. From @FS24 Section 6.2.]
  ),
  caption: [Summary of the full proof]
)

While Docknetwork demonstrates competitive performance, particularly excelling in specialized proofs like
credential signing and non-revocation, we will continue to pursue Noir due to its superior composability
and developer accessibility. We aim to optimize Noir's proving time to be more competitive with
specialized solutions.

= Byproducts

== Participation in OSS Development

During our evaluation of different libraries, we also participated in
the development of two of them.
This allowed us to gauge the possibility of pushing new pull requests,
and to see whether the project is alive.

For #link("https://github.com/docknetwork/crypto")[Docknetwork], the experience
was a mixed bag: in the beginning, the main author, lovesh, was employed
by the startup behind the library.
During this time, changes were readily evaluated and then merged.
Starting in early 2025, lovesh changed employer, and was less available
to oversee changes to the libraries.
This led us to re-evaluate our goal of using the docknetwork library
as the basis for our work.

Regarding #link("https://noir-lang.org/")[Noir], it is supported by a much
larger community, and also has backing from a diverse community, see
#link("https://aztec.network/basics")[Investors].
The repository for the #link("https://github.com/noir-lang/noir")[noir language]
is active and allowed us to participate easily with fast response
times from the community.
Also the fact that noir has a much easier and accessible system to
create proofs make us believe that it is the good way to go.

== Discussions and Meetings

As a response to our reports, blog posts, and visits at conferences
we had various discussions with our partners and other entities:
- #link("https://www.bit.admin.ch/en")[FOITT] and #link("https://www.bj.admin.ch/bj/en/home.html")[FOJ],
  who are developing Swiyu, allowed us to get feedback on our current
  implementation and ideas.
  The discussions were also important because it allowed us to learn
  new challenges for them, and get a first impression of our proposed
  algorithms.
- #link("https://ubique.ch/")[Ubique] are working on their
  #link("https://heidi-universe.ch/en/index.html")[Heidi] implementation of the
  e-ID, supported by the #link("https://www.sprind.org/en/words/magazine/eudi-wallet-prototypes-third-stage")[SPRIN-D]
  Federal Agency from Germany.
  They published the code using ZKAttest, and gave us valuable feedback
  on our choices and search in new algorithms.
- Professors from UniBe and ETHZ gave us feedback and questions on
  our blog-post.
  This allowed us to better understand what is difficult to grasp
  and which elements of the e-ID still need to be made better.
- Human Colossus discussed the fundamentals of social and ethical
  requirements for digital societies, in particular e-ID.

== Hands-on Workshop

In June 2025 we held a hands-on workshop on our current understanding of
the privacy-preserving algorithms available for e-ID.
The code and slides are available on the github repo
#link("https://github.com/c4dt/how-2025-06-eID")[c4dt/how-2025-06-eID].
Around 20 people from C4DT partners and the Swiss government agencies
were present and gave us valuable feedback.

== Whitepaper

To help discussions regarding e-ID and making sure we use the correct terms
when talking about the different parts of the system, we set out to write
a Taxonomy of digital identity systems @EIDTaxonomy.
In 2026 we will update this whitepaper and turn it into a full systematization
of knowledge paper by measuring various solutions proposed for privacy-preserving
solutions.

== Blog Posts

We wrote a number of blog posts to be used as a basis of discussion with
interested parties in e-ID:

- #link("https://eid-privacy.github.io/wp1,/wp2/2025/05/23/swiyu-demo-announcement.html")[2025/05/23 - Open Source SWIYU Demo application]
- #link("https://eid-privacy.github.io/wp1/2025/06/10/taxonomy-101.html")[2025/06/10 - Taxonomy 101]
- #link("https://eid-privacy.github.io/wp4/2025/10/20/overview.html")[2025/10/20 - Overview of Privacy and Unlinkability]
- #link("https://eid-privacy.github.io/wp1/2025/09/17/taxonomy-of-digital-identity-systems.html")[2025/09/17 - Taxonomy of digital identity systems]
- #link("https://eid-privacy.github.io/wp2/2025/09/17/privacy-enhancing-resources.html")[2025/09/17 - Resources on Zero-knowledge Systems and Proofs]
- #link("https://eid-privacy.github.io/wp1/2025/10/21/comparing-implemented-zk-systems.html")[2025/10/21 - Comparing ZK systems]
- #link("https://eid-privacy.github.io/wp0/2025/11/28/crescent-longfellow-showdown.html")[2025/11/28 - Crescent and Longfellow]

= Future Work

Our next work items will involve deploying a prover and verifier for our Noir circuits on SICPA's identity platform and,
if relevant, Longfellow prover and verifier as well.
This in order to identify and research-engineering gap remaining as well as to start identify resources/performance
trade-off for such solutions in enterprise products.

We also aim at optimizing the proving time to reach acceptably smooth interactions for holders.

We will further investigate possibilities to bring prover-friendly proof systems to the Noir backends as well as
follow Google and Dyne.org's work on a programmer/auditor friendly language for circuit writing compatible with
Longfellow.

Specifically for Noir, we will need to implement a verification using the secp256r1 curve, which is used
in the issuer and the device signature. The current verification is on a secp256k1 curve, which is popular
because it is used in bitcoin.
