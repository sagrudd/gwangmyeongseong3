# gwangmyeongseong3
This a redux of the Sputnik and OpenSputnik comparative genomics projects.

This is another vanity project aiming to rekindle some bioinformatics and coding passion.

## History - from Sputnik to openSputnik

As a postdoc at the turn of the millenium, I was tasked with adapting the PEDANT software (1)
for usage within comparative plant genomics. At the time we had a single plant genome
available (2) so the plan was to focus on strategies for the clustering, assembly and annotation of
plant EST sequences. The Sputnik (3) project was born in 2001 - it was implemented in Python
and used a PostgreSQL database at the backend to structure data and enable intelligent queries
of salient information.

In 2004 I moved to Finland to start my own research group. Sputnik couldn't travel with me so a new
project was born, OpenSputnik (4). This was a complete reimplementation of the original concepts
borrowed from PEDANT and offered a simpler (although still beastly) implementation based entirely in
JAVA. The software was intended to be open and there were contributions to 
[SourceForge](https://sourceforge.net/projects/opensputnik/files/) - I am not aware of the source code
being available anywhere or still existing - it has all been lost to time.

The OpenSputnik platform was used in a load of collaborations in a variery of different species but
I was recruited into the pharmaceutical industry in 2006 and my ambitions to further develop and
maintain the software were clipped.

A couple of collaborators have enquired about the persistence of their datasets and availability of
software in the 1.5 decades since ...

## Redux and Kwangmyŏngsŏng-3 Unit 2

The original Sputnik name was derived from the [title of a book](https://en.wikipedia.org/wiki/Sputnik_Sweetheart)
during a brainstorm with my mentor, Klaus FX Mayer. Although a very much better name for a microsatellite
detection software (5), the Sputnik name is used in more recent bioinformatics software (in R noless) for peak
analysis (6) and bioinformatics distributed computing (7).

We need a new name. I really like the `Lodestar` naming of Korean satellites but this 
[Lodestar nomenclature](http://ebispot.github.io/lodestar/lodestar.html) is already used by the EBI. I have thus
chosen to go with the Korean word for Lodestar. This is as already suggested a vanity project - in the event
that this project is actually used by anyone then apologies for the excessive `gwangmyeongseong3` name.

## References

1. Riley, M. L., Schmidt, T., Artamonova, I. I., Wagner, C., Volz, A., Heumann, K., Mewes, H. W., & Frishman, D. (2007). PEDANT genome database: 10 years online. Nucleic acids research, 35(Database issue), D354–D357. https://doi.org/10.1093/nar/gkl1005

2. Arabidopsis Genome Initiative (2000). Analysis of the genome sequence of the flowering plant Arabidopsis thaliana. Nature, 408(6814), 796–815. https://doi.org/10.1038/35048692

3. Rudd, S., Mewes, H. W., & Mayer, K. F. (2003). Sputnik: a database platform for comparative plant genomics. Nucleic acids research, 31(1), 128–132. https://doi.org/10.1093/nar/gkg075

4. Rudd S. (2005). openSputnik--a database to ESTablish comparative plant genomics using unsaturated sequence collections. Nucleic acids research, 33(Database issue), D622–D627. https://doi.org/10.1093/nar/gki040

5. Robinson, A. J., Love, C. G., Batley, J., Barker, G., & Edwards, D. (2004). Simple sequence repeat marker loci discovery using SSR primer. Bioinformatics (Oxford, England), 20(9), 1475–1476. https://doi.org/10.1093/bioinformatics/bth104

6. Inglese, P., Correia, G., Takats, Z., Nicholson, J. K., & Glen, R. C. (2019). SPUTNIK: an R package for filtering of spatially related peaks in mass spectrometry imaging data. Bioinformatics (Oxford, England), 35(1), 178–180. https://doi.org/10.1093/bioinformatics/bty622

7. Völkel, G., Lausser, L., Schmid, F., Kraus, J. M., & Kestler, H. A. (2015). Sputnik: ad hoc distributed computation. Bioinformatics (Oxford, England), 31(8), 1298–1301. https://doi.org/10.1093/bioinformatics/btu818
