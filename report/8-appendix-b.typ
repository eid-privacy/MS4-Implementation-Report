#import "common.typ": *

= Appendix B - Innosuisse Questions Not Treated Elsewhere

== Note from Linus

This is the actual canvas given by Innosuisse.
We decided to do two parts:

1. a report we can put on github.com/eid-privacy, and can publish on the internet
2. the actual report required by Innosuisse

So you'll find some `Copy x.y` in this text, which will be a copy of the text
of that section.
The text we wrote in here will not be part of the public internet report.

== Question 1.1

// Summarize the progress of the activities in relation to the project planning and indicate to which degree the project objectives have been met

// - Summarize the (scientific) results of the project -

Copy @what

// - Refer to the measurable and quantified objectives of each milestone and provide data supporting your achievements, justify to what extent the planned work packages and activities have been completed or not

Copy @app-wp-ms

// - Have new risks been identified which could affect the future development activities?

The main risk with regard to using Zero Knowledge Proofs in electronic identities
is the slowness of the official solutions:
with every delay, the private actors will create solutions which are out of the
hand of the governments, and then there will need to be a new legislation to
regulate these solutions.
Currently the EU and Switzerland with Swiyu is still well positioned.
But the latest delays in Switzerland with the deployment of their solution,
due to security implications in the online registration process, shines a light
on the difficulty of deploying such a solution.
Unfortunately this also means that all the ecosystem around e-IDs will be delayed,
and that ZKPs will not be needed in the near future.

== Question 1.2

// Have scientific publications, inventions or patent applications been made? If yes, please give details regarding the status.

=== Taxonomy for Zero Knowledge Proofs in e-ID

- status: in preparation
- abstract: We present a taxonomy of digital identity systems as a discussion foundation. This taxonomy defines
the desired properties, the available cryptographic techniques, as well as the legal and technical
frameworks relevant to building digital identity systems.

=== Reading List for ZKPs

- status: online
- abstract: A knowledge vault covering Zero-Knowledge Proof papers, frameworks, cryptographic primitives, and tooling — from foundational theory to production-ready implementations. Built as an Obsidian notebook and mkDocs site, working toward a blog post on the most important elements of the ZKP ecosystem.

== Question 1.3

// Summarize the progress of the activities in relation to the implementation plan and assess the commercial, economic and/or social benefit

Copy @next-productisation

== Question 1.4

// What is the implementation partners’ strategy for (further) scaling and growth?

// - Are follow-up activities from the Innosuisse project planned, and if so, to what extent and which persons and/or partner/s will be involved?

We are currently discussing with Prof. Alessandro Chiesa, who supported our work at
EPFL, for a follow-up project including post-quantum secure ZKPs.
This project just started, and we're in the progress of writing down the
needed tools, to be able to understand what is still needed.
Our solution still relies on cryptography which will be broken once universal,
big, fast, quantum computers are available.
Once these quantum computers are available, it will be possible to create ZKPs
on any statement required by the prover.

Prof. Alessandro Chiesa has been working on ZKPs based on hashes, which have the
big advantage of not giving any advantage to quantum computers when it comes
to creating wrong statements.
We did write down the requirements, which was based on work we did during this
project, and are in the process to decide how to go forward with the research
and productisation.

Depending on the advancements of quantum computers, it will be required sooner or
later to be able to create ZKPs using cryptographic algorithms which are safe from
attacks.
It needs to be noted, however, that the problem of ZKPs and quantum computers is
different from the problem regarding transmission and encryption of data:
while encrypted data can be _stored now, decrypted later_, this is not possible
with a ZKP:
even once the required quantum computers are available, it will not be possible to
retrieve the original data.
Once our proposed algorithms break, it will only be possible to create fraudulent
proofs, but not decrypt previous proofs.

// - How do you see the economic market potential as well as the value creation potential of both the project and the innovation in the long run?

#todo(assignee: [Clement])[Fill in commercial]

== Question 1.5

// Describe the financial status of the project
//
// - Refer to the financial plan of the project
// - Indicate to which extent the budget provided by Innosuisse has been used up and to which extent the implementation partners’ own contributions have been provided
// - For projects with implementation partner/s: Has the cash contribution been provided? If not, please explain why the cash contribution has not been paid or will not be paid.
// - A detailed final financial report is to be submitted separately with all the necessary justifications

We used up most of the budget of the Innosuisse report.
The distribution between partners / EPFL did work out correctly, and the cash
contribution of our partner, SICPA, allowed us to have a high-quality security
proof of our implementation.
This is a really important part of our work, and will allow SICPA to go on with
the commercialisation of their product, knowing that the indicated problems
have been solved in the meantime.

== Question 1.6

// How do you assess the impact of the project in terms of ecological sustainability?
//
// - For example, refer to:
//   - Ecological sustainability
//   - Sustainable resource use (commodities, materials)
//   - Climate change mitigation (energy use, greenhouse gas emissions)
//   - Biodiversity and restoration of natural habitats (land and water)
//   - Prevention of pollution (waste, air pollution)
// - Social sustainability
//   - Social cohesion (expansion of “soft” and “hard” (public) infrastructure)
//   - Reduction of gender-specific and/or social inequalities in the population
//   - Social coexistence and participation
//   - Quality of education
//   - Fighting poverty
//   - Development assistance/promotion and cooperation
//   - Creation of social benefits / reduction of social costs

Our work shows how technology can be used to increase privacy of users in the
era of the internet.
If the government is willing to protect its citizens, and give them the tools
to protect themselves, solutions like ours can enable these governments to make
something privacy-preserving for their citizens.
Having this privacy can allow citizens to overcome some of the gender-specific
or social inequalities you can find, e.g., when applying for a job with a
foreign-sounding name, or subscribing for a service as a women.

It is important to note that our technology in itself does nothing to increase
the privacy of the citizens.
Technology is only a tool for a society to get to its goals, it cannot replace
the will of the society to get to these goals.
But given the current willingness of the Swiss government, as well as the EU,
to protect their citizens, I believe that our solution is an important milestone
in showing what is possible now.

== Question 1.7

// How successful was the project overall?
// - Are you satisfied with the way the project concluded?
// - Would you do anything differently if you had the opportunity to do so?
// - How do you assess the results of the project? What are your learnings?
// - What were your main challenges and how did you overcome them?

Copy @conclusion
